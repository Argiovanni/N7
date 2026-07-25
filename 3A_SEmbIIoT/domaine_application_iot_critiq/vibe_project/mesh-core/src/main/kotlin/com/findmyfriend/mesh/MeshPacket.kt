package com.findmyfriend.mesh

/**
 * Represents a packet of data traveling through the mesh.
 * 
 * @property id Unique identifier for this packet (to detect duplicates).
 * @property source The original sender of the packet.
 * @property destination The final destination of the packet.
 * @property payload The actual data content.
 * @property ttl Time To Live - decremented at each hop to prevent infinite loops.
 */
data class MeshPacket(
    val id: String = java.util.UUID.randomUUID().toString(),
    val source: NodeId,
    val destination: NodeId,
    val payload: ByteArray,
    val type: PacketType = PacketType.DATA,
    val ttl: Int = 10
) {
    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (javaClass != other?.javaClass) return false
        other as MeshPacket
        return id == other.id
    }

    override fun hashCode(): Int = id.hashCode()
    
    fun decrementTtl(): MeshPacket {
        return copy(ttl = ttl - 1)
    }

    // --- Serialization ---
    
    fun toByteArray(): ByteArray {
        val payloadString = String(payload, Charsets.UTF_8)
        // Add a newline as a delimiter/terminator
        val packetString = "$id|${source.value}|${destination.value}|${type.name}|$ttl|$payloadString\n"
        return packetString.toByteArray(Charsets.UTF_8)
    }

    companion object {
        fun fromByteArray(bytes: ByteArray): MeshPacket {
            try {
                // Remove null bytes and trim whitespace/newlines
                val cleanString = String(bytes, Charsets.UTF_8).replace("\u0000", "").trim()
                val parts = cleanString.split("|", limit = 6)
                if (parts.size < 6) throw IllegalArgumentException("Invalid packet format")
                
                return MeshPacket(
                    id = parts[0].trim(),
                    source = NodeId(parts[1].trim()),
                    destination = NodeId(parts[2].trim()),
                    type = try { PacketType.valueOf(parts[3].trim()) } catch(e: Exception) { PacketType.DATA },
                    ttl = parts[4].trim().toIntOrNull() ?: 0,
                    payload = parts[5].toByteArray(Charsets.UTF_8)
                )
            } catch (e: Exception) {
                throw IllegalArgumentException("Failed to parse MeshPacket", e)
            }
        }
    }
}
