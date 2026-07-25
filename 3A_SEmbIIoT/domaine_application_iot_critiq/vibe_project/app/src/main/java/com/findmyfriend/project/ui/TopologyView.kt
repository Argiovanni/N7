package com.findmyfriend.project.ui

import android.os.ParcelUuid
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.graphics.drawscope.translate
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.drawText
import androidx.compose.ui.text.rememberTextMeasurer
import androidx.compose.ui.unit.sp
import com.findmyfriend.project.service.BleService
import com.findmyfriend.project.viewmodel.MainUiState
import kotlinx.coroutines.delay
import kotlin.math.atan2
import kotlin.math.cos
import kotlin.math.pow
import kotlin.math.sin
import kotlin.math.sqrt
import kotlin.random.Random

// Data classes for the simulation
private class Node(
    val id: String,
    var x: Float,
    var y: Float,
    var vx: Float = 0f,
    var vy: Float = 0f,
    val isMe: Boolean = false
)

private class Edge(
    val sourceId: String,
    val targetId: String,
    val idealDistance: Float
)

// Simulation constants
private const val REFRESH_RATE_MS = 16L
private const val REPULSION_STRENGTH = 10000f
private const val ATTRACTION_STRENGTH = 0.05f
private const val DAMPING_FACTOR = 0.95f
private const val MIN_DISTANCE_METERS = 1.0f // The distance corresponding to ideal spring length

/**
 * A Jetpack Compose component that visualizes a network topology using a force-directed graph.
 */
@Composable
fun TopologyView(
    uiState: MainUiState,
    modifier: Modifier = Modifier
) {
    val nodes = remember { mutableStateMapOf<String, Node>() }
    val edges = remember { mutableStateListOf<Edge>() }
    val directNeighborIds = remember { mutableStateListOf<String>() }
    val textMeasurer = rememberTextMeasurer()
    val labelStyle = TextStyle(color = Color.Black, fontSize = 10.sp)
    val edgeLabelStyle = TextStyle(color = Color.DarkGray, fontSize = 8.sp)

    // Helper to extract Node ID from ScanResult
    fun getNodeId(result: android.bluetooth.le.ScanResult): String? {
        return result.scanRecord
            ?.getServiceData(ParcelUuid(BleService.MESH_SERVICE_UUID))
            ?.let { String(it, Charsets.UTF_8) }
    }

    // This effect runs when the input data changes. It initializes and updates the nodes/edges for the simulation.
    LaunchedEffect(uiState.discoveredDevices, uiState.deviceDistances, uiState.myNodeId, uiState.topology) {
        // Add "self" node
        if (!nodes.containsKey(uiState.myNodeId)) {
            nodes[uiState.myNodeId] = Node(id = uiState.myNodeId, x = 0f, y = 0f, isMe = true)
        }

        // 1. Collect all Node IDs present in the topology + discovered devices
        val allVisibleNodeIds = mutableSetOf<String>()
        uiState.topology.forEach {
            allVisibleNodeIds.add(it.source)
            allVisibleNodeIds.add(it.target)
        }
        
        // Add direct scan results to the set
        val macToNodeId = uiState.discoveredDevices.mapNotNull { result ->
            getNodeId(result)?.let { result.device.address to it }
        }.toMap()
        allVisibleNodeIds.addAll(macToNodeId.values)

        // 2. Add/Update nodes
        allVisibleNodeIds.forEach { nodeId ->
            if (!nodes.containsKey(nodeId)) {
                nodes[nodeId] = Node(
                    id = nodeId,
                    x = Random.nextFloat() * 200 - 100,
                    y = Random.nextFloat() * 200 - 100
                )
            }
        }

        // Cleanup stale nodes
        val currentActiveIds = allVisibleNodeIds + uiState.myNodeId
        nodes.keys.toList().forEach { id ->
            if (id !in currentActiveIds) nodes.remove(id)
        }

        // 3. Update the set of direct neighbors
        directNeighborIds.clear()
        directNeighborIds.addAll(macToNodeId.values)

        // 4. Create edges from topology
        edges.clear()
        uiState.topology.forEach { link ->
            if (nodes.containsKey(link.source) && nodes.containsKey(link.target)) {
                edges.add(
                    Edge(
                        sourceId = link.source,
                        targetId = link.target,
                        // We use a mix of real distance if available, or a default value
                        idealDistance = 150f 
                    )
                )
            }
        }
    }

    // This is the main simulation loop. It runs continuously.
    LaunchedEffect(Unit) {
        while (true) {
            val forceMap = mutableMapOf<String, Offset>()

            // 1. Reset forces
            nodes.keys.forEach { id -> forceMap[id] = Offset.Zero }

            // 2. Calculate repulsive forces between all pairs of nodes
            val nodeList = nodes.values.toList()
            for (i in nodeList.indices) {
                for (j in (i + 1) until nodeList.size) {
                    val nodeA = nodeList[i]
                    val nodeB = nodeList[j]
                    val dx = nodeB.x - nodeA.x
                    val dy = nodeB.y - nodeA.y
                    val distanceSq = (dx * dx + dy * dy).coerceAtLeast(0.01f)
                    val force = REPULSION_STRENGTH / distanceSq
                    val angle = atan2(dy, dx)
                    forceMap[nodeA.id] = forceMap[nodeA.id]!! - Offset(force * cos(angle), force * sin(angle))
                    forceMap[nodeB.id] = forceMap[nodeB.id]!! + Offset(force * cos(angle), force * sin(angle))
                }
            }

            // 3. Calculate attractive (spring) forces for all edges
            edges.forEach { edge ->
                val nodeA = nodes[edge.sourceId]
                val nodeB = nodes[edge.targetId]
                if (nodeA != null && nodeB != null) {
                    val dx = nodeB.x - nodeA.x
                    val dy = nodeB.y - nodeA.y
                    val distance = sqrt(dx * dx + dy * dy)
                    val displacement = distance - edge.idealDistance
                    val force = ATTRACTION_STRENGTH * displacement
                    val angle = atan2(dy, dx)
                    forceMap[nodeA.id] = forceMap[nodeA.id]!! + Offset(force * cos(angle), force * sin(angle))
                    forceMap[nodeB.id] = forceMap[nodeB.id]!! - Offset(force * cos(angle), force * sin(angle))
                }
            }

            // 4. Update positions based on forces
            nodes.values.forEach { node ->
                if (!node.isMe) { // "Me" node is fixed at the center
                    val force = forceMap[node.id] ?: Offset.Zero
                    node.vx = (node.vx + force.x) * DAMPING_FACTOR
                    node.vy = (node.vy + force.y) * DAMPING_FACTOR
                    node.x += node.vx
                    node.y += node.vy
                }
            }

            delay(REFRESH_RATE_MS)
        }
    }

    // 5. Draw the graph on the canvas
    Canvas(modifier = modifier.fillMaxSize()) {
        // Center the coordinate system
        translate(left = size.width / 2, top = size.height / 2) {
            // Draw edges
            edges.forEach { edge ->
                val sourceNode = nodes[edge.sourceId]
                val targetNode = nodes[edge.targetId]
                if (sourceNode != null && targetNode != null) {
                    val start = Offset(sourceNode.x, sourceNode.y)
                    val end = Offset(targetNode.x, targetNode.y)
                    
                    drawLine(
                        color = Color.Gray.copy(alpha = 0.5f),
                        start = start,
                        end = end,
                        strokeWidth = 2f
                    )

                    // Draw Distance Label
                    val linkInfo = uiState.topology.find { 
                        (it.source == edge.sourceId && it.target == edge.targetId) || 
                        (it.source == edge.targetId && it.target == edge.sourceId) 
                    }
                    val distanceText = if (linkInfo != null) {
                        "${"%.1f".format(linkInfo.cost / 10.0)}m"
                    } else {
                        "..."
                    }

                    val textLayoutResult = textMeasurer.measure(distanceText, edgeLabelStyle)
                    val midX = (start.x + end.x) / 2
                    val midY = (start.y + end.y) / 2
                    
                    drawText(
                        textLayoutResult = textLayoutResult,
                        topLeft = Offset(midX - textLayoutResult.size.width / 2, midY - textLayoutResult.size.height / 2)
                    )
                }
            }
            
            // Draw nodes
            nodes.values.forEach { node ->
                val isDirect = directNeighborIds.contains(node.id)
                val color = when {
                    node.isMe -> Color.Blue
                    isDirect -> Color.Red
                    else -> Color(0xFFFFA500) // Orange for indirect
                }

                drawCircle(
                    color = color,
                    radius = 20f,
                    center = Offset(node.x, node.y)
                )
                
                // Draw ID label
                val textLayoutResult = textMeasurer.measure(
                    text = node.id.takeLast(8), // Show last 8 chars of ID for brevity
                    style = labelStyle
                )
                drawText(
                    textLayoutResult = textLayoutResult,
                    topLeft = Offset(
                        node.x - textLayoutResult.size.width / 2,
                        node.y + 25f // Position below the circle
                    )
                )
            }
        }
    }
}
