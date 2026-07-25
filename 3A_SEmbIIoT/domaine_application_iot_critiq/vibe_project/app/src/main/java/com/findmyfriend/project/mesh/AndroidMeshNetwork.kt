package com.findmyfriend.project.mesh

import android.util.Log
import com.findmyfriend.mesh.MeshPacket
import com.findmyfriend.mesh.NetworkInterface
import com.findmyfriend.mesh.NodeId
import com.findmyfriend.mesh.Router
import java.nio.charset.Charset
import java.util.UUID

/**
 * Interface defining the low-level BLE transport capabilities required by the mesh network.
 * This should be implemented by the class managing BluetoothGatt.
 */
interface BleTransport {
    /**
     * Sends raw bytes to a specific device identified by its MAC address.
     */
    fun sendToDevice(macAddress: String, data: ByteArray)

    /**
     * Broadcasts raw bytes to all connected devices.
     */
    fun broadcast(data: ByteArray)
}

/**
 * The bridge between the pure Kotlin Mesh Core and the Android Bluetooth system.
 */
class AndroidMeshNetwork(
    private val context: android.content.Context,
    private val bleTransport: BleTransport
) : NetworkInterface {

    private val PREFS_NAME = "MeshNetworkPrefs"
    private val NODE_ID_KEY = "myNodeId"

    override val myId: NodeId

    init {
        val prefs = context.getSharedPreferences(PREFS_NAME, android.content.Context.MODE_PRIVATE)
        val storedId = prefs.getString(NODE_ID_KEY, null)

        myId = if (storedId != null) {
            NodeId(storedId.take(8))
        } else {
            val newId = NodeId.random()
            prefs.edit().putString(NODE_ID_KEY, newId.value).apply()
            newId
        }
        Log.i(TAG, "Initialized Mesh Network with NodeId: $myId (Persistent: ${storedId != null})")
    }

    // Mapping between Mesh NodeId and Bluetooth MAC Address
    // In a real scenario, this map is populated during the handshake/connection phase.
    private val nodeToMacMap = mutableMapOf<NodeId, String>()
    private val macToNodeMap = mutableMapOf<String, NodeId>()

    // The router logic (will be set after initialization)
    var router: Router? = null

    companion object {
        private const val TAG = "AndroidMeshNetwork"
    }

    /**
     * Called when a new device connects via BLE.
     * We associate its MAC address with a temporary or exchanged NodeId.
     */
    fun onDeviceConnected(macAddress: String, nodeId: NodeId) {
        nodeToMacMap[nodeId] = macAddress
        macToNodeMap[macAddress] = nodeId
        Log.d(TAG, "Device connected: Node=$nodeId, Mac=$macAddress")
    }

    // Buffer for reassembling fragmented packets: MacAddress -> ByteArrayOutputStream
    private val reassemblyBuffers = mutableMapOf<String, java.io.ByteArrayOutputStream>()

    fun isReceiving(): Boolean {
        return reassemblyBuffers.values.any { it.size() > 0 }
    }

    /**
     * Called when raw data is received from BLE.
     */
    fun onDataReceived(macAddress: String, data: ByteArray, rssi: Int) {
        val buffer = reassemblyBuffers.getOrPut(macAddress) { java.io.ByteArrayOutputStream() }
        buffer.write(data)

        // Check for delimiter '\n' (byte 10)
        val bytes = buffer.toByteArray()
        val delimiterIndex = bytes.indexOf(10.toByte())

        if (delimiterIndex != -1) {
            // We have a complete message
            val fullMessageBytes = bytes.copyOfRange(0, delimiterIndex)
            val remainingBytes = if (delimiterIndex + 1 < bytes.size) {
                bytes.copyOfRange(delimiterIndex + 1, bytes.size)
            } else {
                byteArrayOf()
            }

            // Process the message
            try {
                val packet = MeshPacket.fromByteArray(fullMessageBytes)
                Log.i(TAG, "Reassembled Packet from $macAddress: type=${packet.type}")
                
                val linkMetric = calculateLinkMetric(rssi)
                val senderNodeId = macToNodeMap[macAddress] ?: packet.source
                router?.onPacketReceived(packet, senderNodeId, linkMetric)
            } catch (e: Exception) {
                Log.e(TAG, "Error processing reassembled packet", e)
            }

            // Reset buffer with remainder
            buffer.reset()
            buffer.write(remainingBytes)
        }
    }

    fun calculateLinkMetric(rssi: Int): Int {
        // We convert the RSSI to an estimated distance in decimeters (10cm units)
        // to keep it as an Integer for the mesh protocol while maintaining precision.
        val ratio = rssi.toDouble() / -59.0
        val distanceMeters = if (ratio < 1.0) {
            Math.pow(ratio, 10.0)
        } else {
            (0.89976) * Math.pow(ratio, 7.7095) + 0.111
        }
        return (distanceMeters * 10).toInt().coerceAtLeast(1)
    }

    override fun sendToNeighbor(neighborId: NodeId, packet: MeshPacket) {
        val mac = nodeToMacMap[neighborId]
        if (mac != null) {
            bleTransport.sendToDevice(mac, packet.toByteArray()) // Assuming a method to serialize
        } else {
            Log.w(TAG, "No MAC address found for neighbor $neighborId")
        }
    }

    override fun broadcastToNeighbors(packet: MeshPacket) {
        bleTransport.broadcast(packet.toByteArray()) // Assuming a method to serialize
    }
    
    override fun deliverToApp(packet: MeshPacket) {
        // Handle the final delivery of the packet to the app's logic
        Log.i(TAG, "Packet delivered to app: ${String(packet.payload)}")
    }
}
