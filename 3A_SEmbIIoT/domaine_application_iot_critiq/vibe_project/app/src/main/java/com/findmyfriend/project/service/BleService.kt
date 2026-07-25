package com.findmyfriend.project.service

import android.annotation.SuppressLint
import android.app.Service
import android.bluetooth.*
import android.bluetooth.le.*
import android.content.Context
import android.content.Intent
import android.os.Binder
import android.os.IBinder
import android.os.Looper
import android.os.Handler
import android.os.ParcelUuid
import android.util.Log
import com.findmyfriend.mesh.DistanceVectorRouter
import com.findmyfriend.project.mesh.AndroidMeshNetwork
import com.findmyfriend.project.mesh.BleTransport
import com.findmyfriend.project.viewmodel.MainViewModel
import java.util.UUID
import kotlin.math.pow

@SuppressLint("MissingPermission")
class BleService : Service(), BleTransport {

    companion object {
        private const val TAG = "BleService"
        val MESH_SERVICE_UUID: UUID = UUID.fromString("0000AB21-0000-1000-8000-00805F9B34FB")
        val INBOX_CHAR_UUID: UUID = UUID.fromString("00001101-0000-1000-8000-00805F9B34FC")
    }

    private val binder = LocalBinder()
    private var bluetoothManager: BluetoothManager? = null
    private var bluetoothAdapter: BluetoothAdapter? = null
    private var gattServer: BluetoothGattServer? = null
    private var bluetoothLeScanner: BluetoothLeScanner? = null
    private var bluetoothLeAdvertiser: BluetoothLeAdvertiser? = null
    private var viewModel: MainViewModel? = null

    private lateinit var meshNetwork: AndroidMeshNetwork
    private lateinit var router: com.findmyfriend.mesh.LinkStateRouter

    private val discoveredDevices = mutableMapOf<String, ScanResult>()
    private val connectedNeighbors = mutableMapOf<String, BluetoothGatt>()
    private val pendingConnections = mutableSetOf<String>()
    private val connectionCoolDown = mutableMapOf<String, Long>()
    private val rssiBuffers = mutableMapOf<String, java.util.LinkedList<Int>>()
    
    private val MAX_CONNECTIONS = 7
    private val COOL_DOWN_MS = 10_000L

    // ... (rest of the members)

    fun connect(device: BluetoothDevice) {
        val deviceAddress = device.address
        if (connectedNeighbors.containsKey(deviceAddress) || pendingConnections.contains(deviceAddress)) return
        
        // Check if we are in cool-down for this device
        val lastAttempt = connectionCoolDown[deviceAddress] ?: 0L
        if (System.currentTimeMillis() - lastAttempt < COOL_DOWN_MS) return

        if (connectedNeighbors.size >= MAX_CONNECTIONS) {
            return
        }

        Log.i(TAG, "Connecting to $deviceAddress")
        pendingConnections.add(deviceAddress)
        connectionCoolDown[deviceAddress] = System.currentTimeMillis()
        
        // Force TRANSPORT_LE for better compatibility
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.M) {
            device.connectGatt(this, false, gattClientCallback, BluetoothDevice.TRANSPORT_LE)
        } else {
            device.connectGatt(this, false, gattClientCallback)
        }
    }
    private val rssiHandler = Handler(Looper.getMainLooper())
    private val RSSI_READ_INTERVAL = 2000L // Read RSSI every 2 seconds
    private val MAX_RSSI_SAMPLES = 30
    private val RSSI_SMOOTHING_SAMPLE_COUNT = 6

    /**
     * Calcule une distance approximative en mètres à partir d'un signal RSSI.
     * @param rssi La force du signal mesurée.
     * @param txPower La force du signal de référence à 1 mètre (typiquement entre -59 et -65).
     * @return La distance estimée en mètres.
     */
    private fun calculateDistance(rssi: Int, txPower: Double = -59.0): Double {
        val ratio = rssi.toDouble() / txPower
        return if (ratio < 1.0) {
            ratio.pow(10)
        } else {
            (0.89976) * ratio.pow(7.7095) + 0.111
        }
    }


    // --- Routing Timer ---
    private val routingHandler = Handler(Looper.getMainLooper())
    private lateinit var routingRunnable: Runnable
    private val ROUTING_BROADCAST_INTERVAL = 1000L // 1 second
    private val UI_UPDATE_INTERVAL = 500L // Faster UI refresh

    private val uiUpdateRunnable = object : Runnable {
        override fun run() {
            val topology = router.getTopologySnapshot()
            viewModel?.updateTopology(topology.map { 
                com.findmyfriend.project.viewmodel.TopologyLink(it.node1.value, it.node2.value, it.cost) 
            })
            routingHandler.postDelayed(this, UI_UPDATE_INTERVAL)
        }
    }

    inner class LocalBinder : Binder() {
        fun getService(): BleService = this@BleService
    }

    override fun onBind(intent: Intent): IBinder = binder

    private val diagnosticRunnable = object : Runnable {
        override fun run() {
            val connected = connectedNeighbors.keys.toList()
            val discovered = connected.filter { 
                connectedNeighbors[it]?.getService(MESH_SERVICE_UUID) != null 
            }
            
            Log.w(TAG, "--- DIAGNOSTIC ---")
            Log.w(TAG, "Neighbors (GATT Connected): ${connected.size} -> $connected")
            Log.w(TAG, "Services Ready (Ready to Write): ${discovered.size} -> $discovered")
            Log.w(TAG, "Pending Connections: $pendingConnections")
            Log.w(TAG, "------------------")
            
            routingHandler.postDelayed(this, 5000L)
        }
    }

    override fun onCreate() {
        super.onCreate()
        initializeBluetooth()
        initializeMesh()
        startRoutingBroadcasts()
        routingHandler.post(uiUpdateRunnable)
        routingHandler.post(diagnosticRunnable)
    }

    override fun onDestroy() {
        super.onDestroy()
        routingHandler.removeCallbacks(routingRunnable)
        routingHandler.removeCallbacks(uiUpdateRunnable)
        routingHandler.removeCallbacks(diagnosticRunnable)
        disconnect()
    }

    fun setViewModel(viewModel: MainViewModel) {
        this.viewModel = viewModel
        // Immediately update the view model with our ID
        viewModel.updateMyNodeId(meshNetwork.myId.toString())
        
        if (bluetoothAdapter?.isEnabled == false) {
            viewModel.updateAdvertisingStatus("Bluetooth désactivé")
        } else {
            viewModel.updateAdvertisingStatus("Prêt")
        }
    }

    private fun initializeBluetooth() {
        Log.d(TAG, "Initializing Bluetooth...")
        bluetoothManager = getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
        bluetoothAdapter = bluetoothManager?.adapter
        if (bluetoothAdapter == null) {
            Log.e(TAG, "Bluetooth not supported on this device.")
            return
        }
        if (!bluetoothAdapter!!.isEnabled) {
            Log.w(TAG, "Bluetooth is not enabled. Please enable Bluetooth.")
            // In a real app, you'd prompt the user to enable Bluetooth here.
        }
        bluetoothLeScanner = bluetoothAdapter?.bluetoothLeScanner
        bluetoothLeAdvertiser = bluetoothAdapter?.bluetoothLeAdvertiser

        if (bluetoothLeScanner == null) {
            Log.e(TAG, "Bluetooth LE Scanner not available.")
            // Handle this error, perhaps update ViewModel status to indicate failure
        }
        if (bluetoothLeAdvertiser == null) {
            Log.e(TAG, "Bluetooth LE Advertiser not available.")
            // Handle this error
        }
        setupGattServer()
        Log.d(TAG, "Bluetooth initialization complete.")
    }

    private fun initializeMesh() {
        meshNetwork = AndroidMeshNetwork(applicationContext, this)
        router = com.findmyfriend.mesh.LinkStateRouter(meshNetwork)
        meshNetwork.router = router
        Log.i(TAG, "Mesh Network initialized with LinkStateRouter. My NodeId: ${meshNetwork.myId}")
    }
    
    private fun startRoutingBroadcasts() {
        // Stop any existing loop first to avoid double-ticking
        if (::routingRunnable.isInitialized) {
            routingHandler.removeCallbacks(routingRunnable)
        }

        routingRunnable = object : Runnable {
            override fun run() {
                // Listen Before Talk: If we are receiving data, wait.
                if (meshNetwork.isReceiving()) {
                    Log.d(TAG, "Network busy receiving, skipping broadcast.")
                    val nextDelay = 500L + (Math.random() * 500).toLong()
                    routingHandler.postDelayed(this, nextDelay)
                    return
                }

                Log.i(TAG, "Routing tick (connected=${connectedNeighbors.size})...")
                
                val neighborsMap = mutableMapOf<com.findmyfriend.mesh.NodeId, Int>()
                
                // Build map only for connected neighbors with a valid 8-char NodeId
                connectedNeighbors.forEach { (mac, _) ->
                    val nodeId = discoveredDevices.entries.find { 
                        it.value.device.address == mac && it.key.length <= 8 
                    }?.key
                    
                    if (nodeId != null) {
                        val rssi = rssiBuffers[mac]?.lastOrNull() ?: -70
                        neighborsMap[com.findmyfriend.mesh.NodeId(nodeId)] = meshNetwork.calculateLinkMetric(rssi)
                    } else {
                        Log.w(TAG, "Neighbor $mac has no valid NodeId yet. Skipping.")
                    }
                }

                if (neighborsMap.isNotEmpty()) {
                    Log.d(TAG, "Broadcasting links for ${neighborsMap.size} neighbors")
                    router.broadcastMyLinks(neighborsMap)
                } else if (connectedNeighbors.isNotEmpty()) {
                    Log.w(TAG, "Neighbors connected but NO valid NodeIds found!")
                }
                
                // Add Jitter (Random delay) to avoid collisions (TDMA-style)
                // Random between 2s and 4s
                val nextDelay = 2000L + (Math.random() * 2000).toLong()
                routingHandler.postDelayed(this, nextDelay)
            }
        }
        routingHandler.post(routingRunnable)
    }

    private fun setupGattServer() {
        Log.d(TAG, "Setting up GATT server...")
        gattServer = bluetoothManager?.openGattServer(this, gattServerCallback)
        if (gattServer == null) {
            Log.e(TAG, "Failed to open GATT server.")
            return
        }
        val service = BluetoothGattService(MESH_SERVICE_UUID, BluetoothGattService.SERVICE_TYPE_PRIMARY)
        val inboxChar = BluetoothGattCharacteristic(
            INBOX_CHAR_UUID,
            BluetoothGattCharacteristic.PROPERTY_WRITE or BluetoothGattCharacteristic.PROPERTY_WRITE_NO_RESPONSE,
            BluetoothGattCharacteristic.PERMISSION_WRITE
        )
        service.addCharacteristic(inboxChar)
        gattServer?.addService(service)
        Log.d(TAG, "GATT server setup complete. Service UUID: $MESH_SERVICE_UUID")
    }

    fun startAdvertising() {
        Log.d(TAG, "Attempting to start advertising...")
        viewModel?.updateAdvertisingStatus("Démarrage...")
        
        if (bluetoothLeAdvertiser == null) {
            bluetoothLeAdvertiser = bluetoothAdapter?.bluetoothLeAdvertiser
        }

        if (bluetoothLeAdvertiser == null) {
            Log.e(TAG, "Bluetooth LE Advertiser is null (BT might be off).")
            viewModel?.updateAdvertisingStatus("Échec: Bluetooth OFF")
            return
        }

        val settings = AdvertiseSettings.Builder()
            .setAdvertiseMode(AdvertiseSettings.ADVERTISE_MODE_BALANCED)
            .setConnectable(true)
            .setTxPowerLevel(AdvertiseSettings.ADVERTISE_TX_POWER_MEDIUM)
            .build()

        // Packet 1: Service UUID (allows the scanner filter to work)
        val data = AdvertiseData.Builder()
            .setIncludeDeviceName(false)
            .addServiceUuid(ParcelUuid(MESH_SERVICE_UUID))
            .build()

        // Packet 2: NodeId (sent only if a scanner requests it)
        val scanResponse = AdvertiseData.Builder()
            .addServiceData(
                ParcelUuid(MESH_SERVICE_UUID),
                meshNetwork.myId.value.toByteArray(Charsets.UTF_8)
            )
            .build()

        bluetoothLeAdvertiser?.startAdvertising(settings, data, scanResponse, advertiseCallback)
        Log.d(TAG, "Advertising start command sent (Balanced/Medium with Scan Response).")
    }

    private val advertiseCallback = object : AdvertiseCallback() {
        override fun onStartSuccess(settingsInEffect: AdvertiseSettings?) {
            Log.i(TAG, "Advertising started successfully.")
            viewModel?.updateAdvertisingStatus("Émission active")
        }
        override fun onStartFailure(errorCode: Int) {
            Log.e(TAG, "Advertising failed: $errorCode")
            viewModel?.updateAdvertisingStatus("Échec de l'émission: $errorCode")
        }
    }

    fun startScanning() {
        Log.d(TAG, "Starting continuous scan in BALANCED mode...")
        viewModel?.updateIsScanning(true)
        
        val scanSettings = ScanSettings.Builder()
            .setScanMode(ScanSettings.SCAN_MODE_BALANCED) // Balanced to avoid throttling
            .build()
            
        bluetoothLeScanner?.startScan(null, scanSettings, scanCallback)
    }

    fun disconnect() {
        Log.i(TAG, "Disconnecting from all devices")
        connectedNeighbors.values.forEach { it.close() }
        connectedNeighbors.clear()
    }

    override fun sendToDevice(macAddress: String, data: ByteArray) {
        val gatt = connectedNeighbors[macAddress]
        if (gatt == null) return
        
        val service = gatt.getService(MESH_SERVICE_UUID)
        val characteristic = service?.getCharacteristic(INBOX_CHAR_UUID) ?: return

        characteristic.writeType = BluetoothGattCharacteristic.WRITE_TYPE_NO_RESPONSE

        // Fragmentation Logic: Split into 20-byte chunks
        val chunkSize = 20
        val chunks = data.toList().chunked(chunkSize).map { it.toByteArray() }
        
        // Use a background thread/handler to send chunks sequentially
        val handler = Handler(Looper.getMainLooper())
        chunks.forEachIndexed { index, chunk ->
            handler.postDelayed({
                if (connectedNeighbors.containsKey(macAddress)) {
                    characteristic.value = chunk
                    val success = gatt.writeCharacteristic(characteristic)
                    if (!success) Log.w(TAG, "Failed to write chunk $index to $macAddress")
                }
            }, index * 100L) // 100ms delay between chunks to avoid congestion
        }
        
        Log.d(TAG, "Queueing ${data.size} bytes in ${chunks.size} chunks for $macAddress")
    }

    override fun broadcast(data: ByteArray) {
        val neighbors = connectedNeighbors.keys.toList()
        if (neighbors.isEmpty()) return
        
        Log.d(TAG, "Broadcasting to ${neighbors.size} neighbors sequentially...")
        
        // Use a background handler to avoid blocking the main thread
        val handler = Handler(Looper.getMainLooper())
        neighbors.forEachIndexed { index, mac ->
            handler.postDelayed({
                sendToDevice(mac, data)
            }, index * 200L) // 200ms gap between neighbors
        }
    }

    private fun processRssi(deviceAddress: String, rssi: Int) {
        val buffer = rssiBuffers.getOrPut(deviceAddress) { java.util.LinkedList() }
        buffer.add(rssi)
        if (buffer.size > MAX_RSSI_SAMPLES) {
            buffer.removeFirst()
        }

        // Smoothing: Keep the strongest signals (closest to 0) which represent best line-of-sight
        val filteredRssi = if (buffer.size >= RSSI_SMOOTHING_SAMPLE_COUNT) {
            val sorted = buffer.sortedDescending() // Max to Min (e.g., -40, -50, -80...)
            val topSamples = sorted.subList(0, RSSI_SMOOTHING_SAMPLE_COUNT)
            topSamples.average()
        } else {
            buffer.average()
        }

        val distance = calculateDistance(filteredRssi.toInt())
        Log.d(TAG, "Device: $deviceAddress, RSSI: $rssi, Filtered: ${"%.2f".format(filteredRssi)}, Distance: ${"%.2f".format(distance)}m")
        viewModel?.updateDeviceDistance(deviceAddress, distance)
    }

    private val gattClientCallback = object : BluetoothGattCallback() {
        override fun onConnectionStateChange(gatt: BluetoothGatt, status: Int, newState: Int) {
            val deviceAddress = gatt.device.address
            pendingConnections.remove(deviceAddress) // Remove from pending regardless of result

            if (status == BluetoothGatt.GATT_SUCCESS) {
                if (newState == BluetoothProfile.STATE_CONNECTED) {
                    Log.i(TAG, "Successfully connected to $deviceAddress. Requesting MTU and discovering services...")
                    connectedNeighbors[deviceAddress] = gatt
                    
                    // Request a larger MTU for routing tables
                    if (!gatt.requestMtu(512)) {
                        // If MTU request fails immediately, proceed to discovery
                        gatt.discoverServices()
                    }
                    
                    // Start periodic RSSI reading
                    val rssiReadRunnable = object : Runnable {
                        override fun run() {
                            if (connectedNeighbors.containsKey(deviceAddress)) {
                                gatt.readRemoteRssi()
                                rssiHandler.postDelayed(this, RSSI_READ_INTERVAL)
                            }
                        }
                    }
                    rssiHandler.post(rssiReadRunnable)
                } else if (newState == BluetoothProfile.STATE_DISCONNECTED) {
                    Log.w(TAG, "Successfully disconnected from $deviceAddress")
                    connectedNeighbors.remove(deviceAddress)
                    gatt.close()
                }
            } else {
                Log.e(TAG, "GATT Error ($status) for $deviceAddress. status=$status, newState=$newState")
                connectedNeighbors.remove(deviceAddress)
                gatt.close()
            }
        }

        override fun onMtuChanged(gatt: BluetoothGatt, mtu: Int, status: Int) {
            Log.d(TAG, "MTU changed to $mtu for ${gatt.device.address}, status: $status")
            // Proceed to service discovery after MTU negotiation
            gatt.discoverServices()
        }

        override fun onServicesDiscovered(gatt: BluetoothGatt, status: Int) {
            if (status == BluetoothGatt.GATT_SUCCESS) {
                Log.i(TAG, "Services discovered for ${gatt.device.address}. Waiting for stability...")
                
                // Delay slightly to ensure stability before first write
                Handler(Looper.getMainLooper()).postDelayed({
                    val neighborsMap = mutableMapOf<com.findmyfriend.mesh.NodeId, Int>()
                    connectedNeighbors.keys.forEach { mac ->
                        val nodeId = discoveredDevices.entries.find { it.value.device.address == mac }?.key
                        if (nodeId != null) {
                            val rssi = rssiBuffers[mac]?.lastOrNull() ?: -70
                            neighborsMap[com.findmyfriend.mesh.NodeId(nodeId)] = meshNetwork.calculateLinkMetric(rssi)
                        }
                    }
                    Log.d(TAG, "Sending initial routing update to ${gatt.device.address}")
                    router.broadcastMyLinks(neighborsMap)
                }, 500)
            } else {
                Log.w(TAG, "onServicesDiscovered received: $status")
            }
        }

        override fun onReadRemoteRssi(gatt: BluetoothGatt, rssi: Int, status: Int) {
            if (status == BluetoothGatt.GATT_SUCCESS) {
                processRssi(gatt.device.address, rssi)
            } else {
                Log.w(TAG, "Failed to read RSSI for ${gatt.device.address} with status $status")
            }
        }
    }

    private val gattServerCallback = object : BluetoothGattServerCallback() {
        override fun onConnectionStateChange(device: BluetoothDevice, status: Int, newState: Int) {
            if (newState == BluetoothProfile.STATE_CONNECTED) {
                Log.i(TAG, "Device ${device.address} connected to our GATT server. Triggering reciprocal broadcast.")
                // Symmetry: when someone connects to us, broadcast our links so they get our info too
                Handler(Looper.getMainLooper()).postDelayed({
                    routingRunnable.run() 
                }, 1000)
            } else if (newState == BluetoothProfile.STATE_DISCONNECTED) {
                Log.w(TAG, "Device ${device.address} disconnected from our GATT server.")
            }
        }

        override fun onCharacteristicWriteRequest(
            device: BluetoothDevice,
            requestId: Int,
            characteristic: BluetoothGattCharacteristic,
            preparedWrite: Boolean,
            responseNeeded: Boolean,
            offset: Int,
            value: ByteArray
        ) {
            if (characteristic.uuid == INBOX_CHAR_UUID) {
                if (responseNeeded) {
                    gattServer?.sendResponse(device, requestId, BluetoothGatt.GATT_SUCCESS, 0, null)
                }
                Log.i(TAG, "SERVER: Data received from ${device.address} (${value.size} bytes)")
                
                // Try to get the last known RSSI for this device to have a better link metric
                val lastRssi = rssiBuffers[device.address]?.lastOrNull() ?: -70 
                meshNetwork.onDataReceived(device.address, value, lastRssi)
            }
        }
    }
    private val scanCallback = object : ScanCallback() {
        override fun onScanResult(callbackType: Int, result: ScanResult) {
            val scanRecord = result.scanRecord ?: return
            val serviceData = scanRecord.getServiceData(ParcelUuid(MESH_SERVICE_UUID))
            val deviceAddress = result.device.address

            if (serviceData != null) {
                // We have the NodeId: this is our primary key
                val nodeId = String(serviceData, Charsets.UTF_8)
                
                // Cleanup: remove any temporary MAC-based entry for this device
                discoveredDevices.remove(deviceAddress)
                
                // Update or add the device using its NodeId
                discoveredDevices[nodeId] = result
                
                // CRITICAL: Tell the mesh network which MAC address belongs to this NodeId
                meshNetwork.onDeviceConnected(deviceAddress, com.findmyfriend.mesh.NodeId(nodeId))
                
                Log.v(TAG, "FMF Device updated: $nodeId at $deviceAddress")
                
                // CRITICAL: Inform the router about this neighbor immediately from scan data
                val linkMetric = meshNetwork.calculateLinkMetric(result.rssi)
                router.updateLinkLocallyFromApp(
                    meshNetwork.myId,
                    com.findmyfriend.mesh.NodeId(nodeId),
                    linkMetric
                )

                // Update UI and RSSI
                viewModel?.updateDiscoveredDevices(discoveredDevices.values.toList())
                processRssi(deviceAddress, result.rssi)

                // Trigger automatic connection for mesh networking
                connect(result.device)
            } else {
                // No NodeId yet, check if it's one of our services via UUID
                val serviceUuids = scanRecord.serviceUuids ?: emptyList()
                if (serviceUuids.contains(ParcelUuid(MESH_SERVICE_UUID))) {
                    // Only add as temporary MAC entry if we don't already know its NodeId
                    val isAlreadyKnownByNodeId = discoveredDevices.keys.any { key ->
                        val entry = discoveredDevices[key]
                        entry?.device?.address == deviceAddress && key.length > 17 // NodeIds are usually shorter or different format than MAC
                    }
                    
                    if (!isAlreadyKnownByNodeId) {
                        discoveredDevices[deviceAddress] = result
                        viewModel?.updateDiscoveredDevices(discoveredDevices.values.toList())
                    }
                    processRssi(deviceAddress, result.rssi)
                }
            }
        }
        override fun onScanFailed(errorCode: Int) {
            Log.e(TAG, "Scan failed with error: $errorCode. NOT restarting automatically to avoid throttling.")
            viewModel?.updateIsScanning(false)
            // Do NOT call startScanning() here.
        }
    }
}

