package com.findmyfriend.project

import android.Manifest
import android.bluetooth.BluetoothDevice
import android.bluetooth.le.ScanResult
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.content.pm.PackageManager
import android.os.Bundle
import android.os.IBinder
import android.os.ParcelUuid
import android.util.Log
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.viewModels
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.List
import androidx.compose.material.icons.filled.Place
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.core.app.ActivityCompat
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.findmyfriend.project.service.BleService
import com.findmyfriend.project.ui.TopologyView
import com.findmyfriend.project.ui.RoutingTableScreen
import com.findmyfriend.project.viewmodel.MainViewModel
import java.nio.charset.Charset

class MainActivity : ComponentActivity() {

    private val TAG = "MainActivity"
    private val viewModel: MainViewModel by viewModels()

    // --- BLE Service ---
    private var bleService: BleService? = null
    private var isServiceBound = false

    private val serviceConnection = object : ServiceConnection {
        override fun onServiceConnected(name: ComponentName?, service: IBinder?) {
            val binder = service as BleService.LocalBinder
            bleService = binder.getService()
            bleService?.setViewModel(viewModel)
            isServiceBound = true
            Log.i(TAG, "BleService connected")
            startBleOperations()
        }

        override fun onServiceDisconnected(name: ComponentName?) {
            bleService = null
            isServiceBound = false
            Log.w(TAG, "BleService disconnected")
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            val uiState by viewModel.uiState.collectAsStateWithLifecycle()
            var selectedTab by remember { mutableIntStateOf(0) }

            FindMyFriendTheme {
                Scaffold(
                    bottomBar = {
                        TabRow(selectedTabIndex = selectedTab) {
                            Tab(
                                selected = selectedTab == 0,
                                onClick = { selectedTab = 0 },
                                icon = { Icon(Icons.Default.List, contentDescription = null) },
                                text = { Text("Liste") }
                            )
                            Tab(
                                selected = selectedTab == 1,
                                onClick = { selectedTab = 1 },
                                icon = { Icon(Icons.Default.Place, contentDescription = null) },
                                text = { Text("Topologie") }
                            )
                            Tab(
                                selected = selectedTab == 2,
                                onClick = { selectedTab = 2 },
                                icon = { Icon(Icons.Default.Refresh, contentDescription = null) },
                                text = { Text("Routage") }
                            )
                        }
                    }
                ) { paddingValues ->
                    Surface(
                        modifier = Modifier.fillMaxSize().padding(paddingValues),
                        color = MaterialTheme.colorScheme.background
                    ) {
                        when (selectedTab) {
                            0 -> DeviceListScreen(
                                devices = uiState.discoveredDevices,
                                distances = uiState.deviceDistances,
                                isScanning = uiState.isScanning,
                                advertisingStatus = uiState.advertisingStatus,
                                myNodeId = uiState.myNodeId,
                                onDeviceClick = { device -> connectToDevice(device) }
                            )
                            1 -> TopologyView(uiState = uiState)
                            2 -> RoutingTableScreen(uiState = uiState)
                        }
                    }
                }
            }
        }
        requestBlePermissions()
    }
    
    override fun onDestroy() {
        super.onDestroy()
        if (isServiceBound) {
            unbindService(serviceConnection)
            isServiceBound = false
        }
    }

    private fun connectToDevice(device: BluetoothDevice) {
        bleService?.connect(device)
    }

    // --- Permissions Handling ---
    
    private fun requestBlePermissions() {
        val permissionsToRequest = if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.S) {
            arrayOf(
                Manifest.permission.BLUETOOTH_SCAN,
                Manifest.permission.BLUETOOTH_ADVERTISE,
                Manifest.permission.BLUETOOTH_CONNECT,
                Manifest.permission.ACCESS_FINE_LOCATION
            )
        } else {
            arrayOf(Manifest.permission.ACCESS_FINE_LOCATION)
        }
        
        if (!hasPermissions(*permissionsToRequest)) {
            ActivityCompat.requestPermissions(this, permissionsToRequest, 1337)
        } else {
            Log.d(TAG, "Permissions already granted.")
            bindBleService()
        }
    }

    private fun hasPermissions(vararg permissions: String): Boolean {
        return permissions.all { checkSelfPermission(it) == PackageManager.PERMISSION_GRANTED }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == 1337 && grantResults.all { it == PackageManager.PERMISSION_GRANTED }) {
            Log.d(TAG, "Permissions granted by user.")
            bindBleService()
        } else {
            Log.e(TAG, "Permissions denied. The application cannot function.")
            Toast.makeText(this, "Permissions BLE refusées", Toast.LENGTH_LONG).show()
        }
    }

    private fun bindBleService() {
        Intent(this, BleService::class.java).also { intent ->
            bindService(intent, serviceConnection, Context.BIND_AUTO_CREATE)
        }
    }

    private fun startBleOperations() {
        bleService?.startAdvertising()
        bleService?.startScanning()
    }
}

// --- UI Components ---

@Composable
fun DeviceListScreen(
    devices: List<ScanResult>,
    distances: Map<String, Double>,
    isScanning: Boolean,
    advertisingStatus: String,
    myNodeId: String,
    onDeviceClick: (BluetoothDevice) -> Unit
) {
    Box(modifier = Modifier.fillMaxSize()) {
        Column(modifier = Modifier.fillMaxSize().padding(16.dp)) {
            Text(text = "Appareils Find My Friend", style = MaterialTheme.typography.headlineMedium)
            
            if (isScanning && devices.isEmpty()) {
                Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        CircularProgressIndicator()
                        Text("Scan en cours...", modifier = Modifier.padding(top = 8.dp))
                    }
                }
            } else if (!isScanning && devices.isEmpty()) {
                Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                    Text("Aucun appareil trouvé.")
                }
            } else {
                LazyColumn {
                    items(devices) { scanResult ->
                        val distance = distances[scanResult.device.address]
                        DeviceItem(
                            scanResult = scanResult,
                            distance = distance,
                            onClick = { onDeviceClick(scanResult.device) }
                        )
                    }
                }
            }
        }
        Column(
            modifier = Modifier.align(Alignment.BottomCenter).padding(16.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(
                text = "ID: $myNodeId",
                color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f),
                style = MaterialTheme.typography.bodySmall
            )
            Spacer(modifier = Modifier.height(4.dp))
            Text(
                text = "Statut : $advertisingStatus",
                color = if (advertisingStatus.contains("Échec")) MaterialTheme.colorScheme.error else MaterialTheme.colorScheme.primary,
                fontWeight = FontWeight.Bold,
                style = MaterialTheme.typography.bodyMedium
            )
        }
    }
}

private fun getShortNodeId(result: ScanResult): String {
    return result.scanRecord
        ?.getServiceData(ParcelUuid(BleService.MESH_SERVICE_UUID))
        ?.let { String(it, Charsets.UTF_8) }
        ?: "Inconnu"
}

@Composable
fun DeviceItem(scanResult: ScanResult, distance: Double?, onClick: () -> Unit) {
    val nodeId = getShortNodeId(scanResult)
    val rssi = scanResult.rssi
    val distanceText = if (distance != null) {
        " | ${"%.2f".format(distance)}m"
    } else {
        ""
    }

    Text(
        text = "$nodeId ($rssi dBm)$distanceText",
        modifier = Modifier
            .padding(vertical = 8.dp)
            .fillMaxWidth()
    )
}

@Composable
fun FindMyFriendTheme(content: @Composable () -> Unit) {
    MaterialTheme {
        content()
    }
}

@Preview(showBackground = true)
@Composable
fun DefaultPreview() {
    FindMyFriendTheme {
        DeviceListScreen(
            devices = emptyList(),
            distances = emptyMap(),
            isScanning = true,
            advertisingStatus = "Émission active",
            myNodeId = "preview-id",
            onDeviceClick = {}
        )
    }
}