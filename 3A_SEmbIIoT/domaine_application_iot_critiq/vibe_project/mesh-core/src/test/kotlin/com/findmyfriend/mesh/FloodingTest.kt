package com.findmyfriend.mesh

import org.junit.jupiter.api.Test
import org.junit.jupiter.api.Assertions.*

class FloodingTest {

    // A simple mock of the network interface for testing
    class TestNetwork(override val myId: NodeId) : NetworkInterface {
        val receivedPackets = mutableListOf<MeshPacket>()
        val sentBroadcasts = mutableListOf<MeshPacket>()

        override fun sendToNeighbor(neighborId: NodeId, packet: MeshPacket) {
            // Not used in pure flooding usually, but good to have
        }

        override fun broadcastToNeighbors(packet: MeshPacket) {
            sentBroadcasts.add(packet)
        }

        override fun deliverToApp(packet: MeshPacket) {
            receivedPackets.add(packet)
        }
    }

    @Test
    fun `test source sends packet`() {
        val myId = NodeId("nodeA")
        val network = TestNetwork(myId)
        val router = FloodingRouter(network)

        val packet = MeshPacket(
            source = myId,
            destination = NodeId("nodeB"),
            payload = "Hello".toByteArray()
        )

        router.sendPacket(packet)

        // The router should have broadcasted the packet
        assertEquals(1, network.sentBroadcasts.size)
        assertEquals(packet.id, network.sentBroadcasts[0].id)
    }
}
