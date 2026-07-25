package com.findmyfriend.mesh

/**
 * Interface defining the behavior of a mesh routing algorithm.
 */
interface Router {
    /**
     * Called when a packet is received from a neighbor.
     * @param packet The received packet.
     * @param fromNeighbor The immediate neighbor who sent this packet.
     * @param linkMetric An optional metric representing the quality or distance of the link (e.g., derived from RSSI).
     */
    fun onPacketReceived(packet: MeshPacket, fromNeighbor: NodeId, linkMetric: Int = 0)

    /**
     * Called when we want to initiate sending a message.
     */
    fun sendPacket(packet: MeshPacket)
}

/**
 * Interface for the Router to interact with the underlying system (hardware or simulation).
 */
interface NetworkInterface {
    /**
     * Gets the ID of the current node.
     */
    val myId: NodeId

    /**
     * Sends a packet to a specific direct neighbor.
     * If the neighbor is not in range, this might fail (silently or with error).
     */
    fun sendToNeighbor(neighborId: NodeId, packet: MeshPacket)

    /**
     * Broadcasts a packet to all currently known direct neighbors.
     */
    fun broadcastToNeighbors(packet: MeshPacket)
    
    /**
     * Delivers the packet to the local application (message reached destination).
     */
    fun deliverToApp(packet: MeshPacket)
}
