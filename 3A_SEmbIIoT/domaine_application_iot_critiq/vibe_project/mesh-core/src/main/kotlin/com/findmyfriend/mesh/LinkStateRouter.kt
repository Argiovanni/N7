package com.findmyfriend.mesh

import java.util.concurrent.ConcurrentHashMap

/**
 * A Link-State Router that maintains a global map of the network topology.
 * Each node broadcasts its direct neighbors, and these "link states" are flooded.
 */
class LinkStateRouter(
    private val network: NetworkInterface
) : Router {

    data class Link(
        val node1: NodeId,
        val node2: NodeId,
        val measurements: MutableMap<NodeId, Int>, // ReporterNode -> MeasuredCost
        val timestamp: Long,
        val hops: Int = 0
    )

    // Global map of all known links in the network
    private val globalTopology = ConcurrentHashMap<String, Link>()
    
    // To avoid infinite flooding
    private val seenPackets = mutableSetOf<String>()
    
    private val LINK_TIMEOUT_MS = 60_000L // Links expire after 1 minute

    override fun onPacketReceived(packet: MeshPacket, fromNeighbor: NodeId, linkMetric: Int) {
        if (packet.id in seenPackets) return
        seenPackets.add(packet.id)

        when (packet.type) {
            PacketType.ROUTING_UPDATE -> {
                handleLinkStateUpdate(packet)
                // Always relay new routing packets to all neighbors to ensure full network coverage
                println("[${network.myId}] Flooding packet ${packet.id} from ${packet.source}")
                network.broadcastToNeighbors(packet)
            }
            PacketType.DATA -> handleDataPacket(packet)
            else -> {}
        }
    }

    private fun handleLinkStateUpdate(packet: MeshPacket) {
        try {
            val payload = String(packet.payload)
            println("[${network.myId}] LSA received from ${packet.source}")
            val entries = payload.split(",")

        for (entry in entries) {
            val parts = entry.split(":")
            if (parts.size >= 3) {
                val id1 = parts[0].trim()
                val id2 = parts[1].trim()
                
                // Strict validation: ID must be 8 chars (or at least reasonable length)
                if (id1.length != 8 || id2.length != 8) {
                    println("[${network.myId}] Ignored malformed link: $id1 <-> $id2")
                    continue
                }

                val n1 = NodeId(id1)
                val n2 = NodeId(id2)
                val cost = parts[2].toIntOrNull() ?: continue
                    val incomingHops = if (parts.size == 4) parts[3].toIntOrNull() ?: 0 else 0
                    
                    val linkKey = if (n1.value < n2.value) "${n1.value}-${n2.value}" else "${n2.value}-${n1.value}"
                    
                    val link = globalTopology.getOrPut(linkKey) {
                        Link(n1, n2, mutableMapOf(), System.currentTimeMillis(), incomingHops + 1)
                    }
                    
                    // Store the measurement from the packet source
                    link.measurements[packet.source] = cost
                }
            }
        } catch (e: Exception) {
            println("[${network.myId}] Error parsing LSA: ${e.message}")
        }
    }

    private fun handleDataPacket(packet: MeshPacket) {
        if (packet.destination == network.myId) {
            network.deliverToApp(packet)
        } else if (packet.ttl > 0) {
            val nextHop = findNextHop(packet.destination)
            if (nextHop != null) {
                network.sendToNeighbor(nextHop, packet.decrementTtl())
            }
        }
    }

    private fun findNextHop(destination: NodeId): NodeId? {
        val links = globalTopology.values
        links.find { (it.node1 == network.myId && it.node2 == destination) || 
                     (it.node2 == network.myId && it.node1 == destination) }
            ?.let { return destination }

        return links.find { it.node1 == destination || it.node2 == destination }?.let {
             if (it.node1 == destination) it.node2 else it.node1
        }
    }

    fun broadcastMyLinks(neighbors: Map<NodeId, Int>) {
        // 1. Update our direct links (0 hops from us)
        neighbors.forEach { (id, cost) ->
            updateLinkLocally(network.myId, id, cost, 0)
        }

        // 2. Share ALL known links to ensure full network propagation
        val linksToShare = globalTopology.values.toList()
        
        if (linksToShare.isEmpty()) {
            println("[${network.myId}] Topology empty, nothing to broadcast.")
            return
        }

        println("[${network.myId}] Broadcasting topology with ${linksToShare.size} links.")

        val payload = linksToShare.joinToString(",") { link ->
            val avgCost = if (link.measurements.isEmpty()) 0 else link.measurements.values.average().toInt()
            "${link.node1.value}:${link.node2.value}:$avgCost:${link.hops}"
        }

        val packet = MeshPacket(
            source = network.myId,
            destination = NodeId("BROADCAST"),
            payload = payload.toByteArray(),
            type = PacketType.ROUTING_UPDATE,
            ttl = 10
        )
        
        // Use a random ID to ensure it's processed as a new update
        val uniquePacket = packet.copy(id = java.util.UUID.randomUUID().toString())
        
        seenPackets.add(uniquePacket.id)
        network.broadcastToNeighbors(uniquePacket)
    }

    override fun sendPacket(packet: MeshPacket) {
        seenPackets.add(packet.id)
        handleDataPacket(packet)
    }

    fun updateLinkLocallyFromApp(n1: NodeId, n2: NodeId, cost: Int) {
        updateLinkLocally(n1, n2, cost, 0)
    }

    private fun updateLinkLocally(n1: NodeId, n2: NodeId, cost: Int, hops: Int) {
        val linkKey = if (n1.value < n2.value) "${n1.value}-${n2.value}" else "${n2.value}-${n1.value}"
        val link = globalTopology.getOrPut(linkKey) {
            Link(n1, n2, mutableMapOf(), System.currentTimeMillis(), hops)
        }
        link.measurements[network.myId] = cost
    }

    fun getTopologySnapshot(): List<com.findmyfriend.mesh.TopologySnapshotLink> {
        // Cleanup old links
        val now = System.currentTimeMillis()
        globalTopology.values.removeIf { now - it.timestamp > LINK_TIMEOUT_MS }
        
        return globalTopology.values.map { link ->
            val avgCost = if (link.measurements.isEmpty()) 0 else link.measurements.values.average().toInt()
            com.findmyfriend.mesh.TopologySnapshotLink(link.node1, link.node2, avgCost)
        }
    }
}

data class TopologySnapshotLink(val node1: NodeId, val node2: NodeId, val cost: Int)
