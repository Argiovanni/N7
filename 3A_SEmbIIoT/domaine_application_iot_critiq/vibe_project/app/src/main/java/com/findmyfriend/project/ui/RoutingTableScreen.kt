package com.findmyfriend.project.ui

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.findmyfriend.project.viewmodel.MainUiState

@Composable
fun RoutingTableScreen(uiState: MainUiState) {
    Column(modifier = Modifier.fillMaxSize().padding(16.dp)) {
        Text(text = "Connaissance Globale du Réseau", style = MaterialTheme.typography.headlineMedium)
        Text(
            text = "Distances calculées entre tous les points connus",
            style = MaterialTheme.typography.bodySmall,
            color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f)
        )
        Spacer(modifier = Modifier.height(16.dp))

        if (uiState.topology.isEmpty()) {
            Box(modifier = Modifier.fillMaxSize(), contentAlignment = androidx.compose.ui.Alignment.Center) {
                Text("En attente de données topologiques...")
            }
        } else {
            LazyColumn {
                item {
                    Row(
                        modifier = Modifier.fillMaxWidth().padding(8.dp),
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Text("Point A", fontWeight = FontWeight.Bold, modifier = Modifier.weight(1f))
                        Text("Point B", fontWeight = FontWeight.Bold, modifier = Modifier.weight(1f))
                        Text("Distance", fontWeight = FontWeight.Bold)
                    }
                    HorizontalDivider()
                }
                items(uiState.topology) { link ->
                    // Cost is in decimeters (10cm units)
                    val distanceMeters = "${"%.1f".format(link.cost / 10.0)}m"
                    
                    Row(
                        modifier = Modifier.fillMaxWidth().padding(8.dp),
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Text(link.source, modifier = Modifier.weight(1f), fontSize = 14.sp)
                        Text(" ↔ ", color = MaterialTheme.colorScheme.primary)
                        Text(link.target, modifier = Modifier.weight(1f), fontSize = 14.sp)
                        Text(distanceMeters, fontWeight = FontWeight.Bold, color = MaterialTheme.colorScheme.secondary)
                    }
                }
            }
        }
    }
}
