package com.findmyfriend.mesh

class FloodingRouter(
    private val network: NetworkInterface
) : Router {

    // Cache to remember packets we've already processed to avoid infinite loops
    private val seenPackets = mutableSetOf<String>()

    override fun onPacketReceived(packet: MeshPacket, fromNeighbor: NodeId, linkMetric: Int) {
        // TODO: Implement the flooding logic here based on MESH_SPECS.md
        // 1. Check if packet was already seen.
        // 2. Check if I am the destination.
        // 3. Check TTL.
        // 4. Relay if needed.
    }

    override fun sendPacket(packet: MeshPacket) {
        // When we originate a packet, we just broadcast it to everyone we see
        seenPackets.add(packet.id)
        network.broadcastToNeighbors(packet)
    }
}
