package com.findmyfriend.mesh

class DistanceVectorRouter(
    private val network: NetworkInterface
) : Router {

    data class RouteEntry(
        val nextHop: NodeId,
        val distance: Int,
        val sequenceNumber: Int,
        val lastUpdated: Long
    )

    // My knowledge of the world: Destination -> Route Info
    private val routingTable = mutableMapOf<NodeId, RouteEntry>()
    
    // My own sequence number
    private var mySequenceNumber = 0

    // To avoid processing the same packet multiple times
    private val seenPackets = mutableSetOf<String>()
    
    // Configuration
    private val ROUTE_TIMEOUT_MS = 30_000L // 30 seconds

    override fun onPacketReceived(packet: MeshPacket, fromNeighbor: NodeId, linkMetric: Int) {
        if (packet.id in seenPackets) return
        seenPackets.add(packet.id)

        // Update direct neighbor contact time
        touchRoute(fromNeighbor)

        when (packet.type) {
            PacketType.DATA -> handleDataPacket(packet)
            PacketType.ROUTING_UPDATE -> handleRoutingUpdate(packet, fromNeighbor, linkMetric)
            PacketType.HANDSHAKE -> { /* Do nothing for now */ }
        }
    }

    override fun sendPacket(packet: MeshPacket) {
        seenPackets.add(packet.id)
        routePacket(packet)
    }

    private fun handleDataPacket(packet: MeshPacket) {
        if (packet.destination == network.myId) {
            network.deliverToApp(packet)
        } else {
            if (packet.ttl > 0) {
                routePacket(packet.decrementTtl())
            }
        }
    }

    private fun routePacket(packet: MeshPacket) {
        purgeStaleRoutes() // Lazy cleanup
        
        val route = routingTable[packet.destination]
        if (route != null) {
            network.sendToNeighbor(route.nextHop, packet)
        } else {
            println("[${network.myId}] No route to ${packet.destination}, dropping packet.")
        }
    }

    private fun handleRoutingUpdate(packet: MeshPacket, fromNeighbor: NodeId, linkMetric: Int) {
        val payloadString = String(packet.payload)
        println("[${network.myId}] Received routing update from $fromNeighbor: $payloadString")
        if (payloadString.isEmpty()) return

        val entries = payloadString.split(",")
        var tableChanged = false
        val now = System.currentTimeMillis()

        for (entry in entries) {
            val parts = entry.split(":")
            if (parts.size == 3) {
                val destId = NodeId(parts[0])
                val dist = parts[1].toIntOrNull() ?: continue
                val seqNum = parts[2].toIntOrNull() ?: continue

                // Cost to neighbor is linkMetric (distance/quality)
                val newDist = dist + linkMetric
                
                // Don't route back to myself
                if (destId == network.myId) continue

                val currentRoute = routingTable[destId]
                
                var update = false
                if (currentRoute == null) {
                    update = true
                } else if (seqNum > currentRoute.sequenceNumber) {
                    update = true
                } else if (seqNum == currentRoute.sequenceNumber && newDist < currentRoute.distance) {
                    update = true
                }

                if (update) {
                    routingTable[destId] = RouteEntry(fromNeighbor, newDist, seqNum, now)
                    tableChanged = true
                }
            }
        }

        if (tableChanged) {
            broadcastRoutingTable(incrementSeqNum = false)
        }
    }

    private fun touchRoute(nodeId: NodeId) {
        val route = routingTable[nodeId]
        if (route != null) {
            routingTable[nodeId] = route.copy(lastUpdated = System.currentTimeMillis())
        }
    }
    
    private fun purgeStaleRoutes() {
        val now = System.currentTimeMillis()
        val iterator = routingTable.iterator()
        while (iterator.hasNext()) {
            val entry = iterator.next()
            if (now - entry.value.lastUpdated > ROUTE_TIMEOUT_MS) {
                iterator.remove()
            }
        }
    }

    fun broadcastRoutingTable(incrementSeqNum: Boolean = true) {
        if (incrementSeqNum) {
            mySequenceNumber += 2 
        }
        
        val payloadString = routingTable.entries.joinToString(",") { (dest, route) ->
            "${dest.value}:${route.distance}:${route.sequenceNumber}"
        } + ",${network.myId.value}:0:$mySequenceNumber"

        val updatePacket = MeshPacket(
            source = network.myId,
            destination = NodeId("BROADCAST"),
            payload = payloadString.toByteArray(),
            type = PacketType.ROUTING_UPDATE,
            ttl = 1
        )
        
        network.broadcastToNeighbors(updatePacket)
    }
    
    fun getRoute(destination: NodeId): RouteEntry? = routingTable[destination]

    fun getRoutingTableSnapshot(): Map<NodeId, RouteEntry> = routingTable.toMap()
}
