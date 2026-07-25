package com.findmyfriend.project.viewmodel

import android.bluetooth.le.ScanResult
import androidx.lifecycle.ViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow

data class TopologyLink(val source: String, val target: String, val cost: Int)

data class MainUiState(
    val discoveredDevices: List<ScanResult> = emptyList(),
    val advertisingStatus: String = "Initialisation...",
    val isScanning: Boolean = false,
    val myNodeId: String = "",
    val deviceDistances: Map<String, Double> = emptyMap(),
    val topology: List<TopologyLink> = emptyList()
)

class MainViewModel : ViewModel() {
    private val _uiState = MutableStateFlow(MainUiState())
    val uiState = _uiState.asStateFlow()

    // Methods to update the state will be called from the service callbacks
    fun updateDiscoveredDevices(devices: List<ScanResult>) {
        _uiState.value = _uiState.value.copy(discoveredDevices = devices)
    }

    fun updateAdvertisingStatus(status: String) {
        _uiState.value = _uiState.value.copy(advertisingStatus = status)
    }

    fun updateIsScanning(scanning: Boolean) {
        _uiState.value = _uiState.value.copy(isScanning = scanning)
    }

    fun updateMyNodeId(nodeId: String) {
        _uiState.value = _uiState.value.copy(myNodeId = nodeId)
    }

    fun updateDeviceDistance(deviceId: String, distance: Double) {
        val updatedDistances = _uiState.value.deviceDistances.toMutableMap()
        updatedDistances[deviceId] = distance
        _uiState.value = _uiState.value.copy(deviceDistances = updatedDistances)
    }

    fun updateTopology(links: List<TopologyLink>) {
        _uiState.value = _uiState.value.copy(topology = links)
    }
}
