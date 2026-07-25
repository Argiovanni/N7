package com.findmyfriend.mesh

import java.util.UUID

/**
 * Represents a unique identifier for a node in the mesh network.
 * Currently wraps a UUID/String.
 */
data class NodeId(val value: String) {
    override fun toString(): String = value

    companion object {
        fun random() = NodeId(java.util.UUID.randomUUID().toString().take(8))
    }
}
