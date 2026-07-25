package fr.enseeiht.superjumpingsumokart.application.network;

import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.ServiceConnection;
import android.os.IBinder;
import android.os.Message;

import android.util.Log;


import androidx.localbroadcastmanager.content.LocalBroadcastManager;

import com.parrot.arsdk.ardiscovery.ARDISCOVERY_PRODUCT_ENUM;
import com.parrot.arsdk.ardiscovery.ARDiscoveryDevice;
import com.parrot.arsdk.ardiscovery.ARDiscoveryDeviceNetService;
import com.parrot.arsdk.ardiscovery.ARDiscoveryDeviceService;
import com.parrot.arsdk.ardiscovery.ARDiscoveryException;
import com.parrot.arsdk.ardiscovery.ARDiscoveryService;
import com.parrot.arsdk.ardiscovery.receivers.ARDiscoveryServicesDevicesListUpdatedReceiver;
import com.parrot.arsdk.ardiscovery.receivers.ARDiscoveryServicesDevicesListUpdatedReceiverDelegate;

import java.util.List;

import fr.enseeiht.superjumpingsumokart.application.GUIWelcome;

/**
 * @author Romain Verset.
 *         This class allows the application to remotly connect with a Jumping Sumo Evo Light Parrot drone.
 *         Created by Romain Verset on 30/01/17.
 */

public class WifiConnector implements ARDiscoveryServicesDevicesListUpdatedReceiverDelegate {

    /**
     * The logging tag. Useful for debugging purpose.
     */
    private final static String WIFI_CONNECTOR_TAG = "WIFI_CONNECTOR";

    /**
     * The context of the {@link android.app.Activity} running this connector.
     */
    private final Context APP_CONTEXT;

    /**
     * The discovery service.
     */
    private ARDiscoveryService discoveryService;

    /**
     * The connection service.
     */
    private ServiceConnection connectionService;

    /**
     * The receiver for notification about available devices.
     */
    private ARDiscoveryServicesDevicesListUpdatedReceiver discoveryServiceDeviceListUpdateReceiver;

    private boolean hasStarted = false;

    /**
     * Default constructor of the class.
     * Sets up the context and starts the discovering service.
     * @param appContext The context of the android {@link android.app.Activity} running this connector.
     */
    public WifiConnector(Context appContext) {
        APP_CONTEXT = appContext;
        start();
        Log.d(WIFI_CONNECTOR_TAG,"WifiConnector ended");
    }

    /**
     * Creates a device using a discovery service.
     * @param discoveryDeviceService The discovery service used to construct the device.
     * @return The device corresponding to the given {@link ARDiscoveryDeviceService}.
     */
    public static ARDiscoveryDevice createDevice(ARDiscoveryDeviceService discoveryDeviceService) {
        // Before everything, it is necessary to check the product ID of the device.
        ARDiscoveryDevice device = null;
        Log.d(WIFI_CONNECTOR_TAG, "Attempting to create a device with following connection service : ");
        Log.d(WIFI_CONNECTOR_TAG, "Name : " + discoveryDeviceService.getName());
        Log.d(WIFI_CONNECTOR_TAG, "Product ID : " + discoveryDeviceService.getProductID());
        Log.d(WIFI_CONNECTOR_TAG, "Device : " + discoveryDeviceService.getDevice().toString());
        if (ARDISCOVERY_PRODUCT_ENUM.ARDISCOVERY_PRODUCT_JS_EVO_LIGHT.equals(ARDiscoveryService.getProductFromProductID(discoveryDeviceService.getProductID()))) {
            Log.d(WIFI_CONNECTOR_TAG, "Jumping Sumo detected, attempting to create the device...");
            try {
                // Creates a device and its network service.
                device = new ARDiscoveryDevice();
                ARDiscoveryDeviceNetService netService = (ARDiscoveryDeviceNetService) discoveryDeviceService.getDevice();
                Log.d(WIFI_CONNECTOR_TAG, "Starting the network service of the device : Name = " + netService.getName() + " | IP = " + netService + " | Port = " + netService.getPort());
                device.initWifi(ARDISCOVERY_PRODUCT_ENUM.ARDISCOVERY_PRODUCT_JS_EVO_LIGHT, netService.getName(), netService.getIp(), netService.getPort());
            } catch (ARDiscoveryException arde) {
                Log.e(WIFI_CONNECTOR_TAG, "Unable to create device : " + arde.getMessage());
            }
        }
        if (ARDISCOVERY_PRODUCT_ENUM.ARDISCOVERY_PRODUCT_JS_EVO_RACE.equals(ARDiscoveryService.getProductFromProductID(discoveryDeviceService.getProductID()))) {
            Log.d(WIFI_CONNECTOR_TAG, "Jumping Sumo detected, attempting to create the device...");
            try {
                // Creates a device and its network service.
                device = new ARDiscoveryDevice();
                ARDiscoveryDeviceNetService netService = (ARDiscoveryDeviceNetService) discoveryDeviceService.getDevice();
                Log.d(WIFI_CONNECTOR_TAG, "Starting the network service of the device : Name = " + netService.getName() + " | IP = " + netService + " | Port = " + netService.getPort());
                device.initWifi(ARDISCOVERY_PRODUCT_ENUM.ARDISCOVERY_PRODUCT_JS_EVO_RACE, netService.getName(), netService.getIp(), netService.getPort());
            } catch (ARDiscoveryException arde) {
                Log.e(WIFI_CONNECTOR_TAG, "Unable to create device : " + arde.getMessage());
            }
        }
        return device;
    }

    /**
     * Starts the discovery service.
     * This method first check if a connection is available. If so, it then tries to discover drones
     * to connect with.
     */
    private void start() {
        if (!hasStarted) {
            Log.d(WIFI_CONNECTOR_TAG, "Starting services...");
            // First checks if a connection is already established.
            if (connectionService == null) {
                Log.d(WIFI_CONNECTOR_TAG, "connectionService == null");
                connectionService = new ServiceConnection() {
                    // When a connection is gotten, initializes the device discovery.
                    @Override
                    public void onServiceConnected(ComponentName name, IBinder service) {
                        Log.d(WIFI_CONNECTOR_TAG, "onServiceConnected");
                        discoveryService = ((ARDiscoveryService.LocalBinder) service).getService();
                        Log.d(WIFI_CONNECTOR_TAG, "gotService");
                        discoveryService.start();
                        discoveryService.stopBLEDiscovering();
                        discoveryService.stopUsbDiscovering();
                    }

                    // When the connection is closed or lost, stops the discovery service if it exists
                    // and deletes the discovery service.
                    @Override
                    public void onServiceDisconnected(ComponentName name) {
                        Log.d(WIFI_CONNECTOR_TAG, "onServiceDisConnected");
                        if (discoveryService != null) {
                            discoveryService.stop();
                        }
                    }
                };
                registerReceivers();
            }

            // If the discovery service does not exist yet, creates it and binds it to the
            // application context and starts it. Otherwise just starts it.
            if (discoveryService == null) {
                Log.d(WIFI_CONNECTOR_TAG, "discoveryService is null");
                Intent discoveryIntent = new Intent(APP_CONTEXT, ARDiscoveryService.class);
                //APP_CONTEXT.startService(discoveryIntent);
                Log.d(WIFI_CONNECTOR_TAG, "Intent discoveryService created");
                APP_CONTEXT.bindService(discoveryIntent, connectionService, Context.BIND_AUTO_CREATE);
                Log.d(WIFI_CONNECTOR_TAG, "bindService discoveryService");
                if (connectionService == null) {
                    Log.d(WIFI_CONNECTOR_TAG, "connectionService is null");
                }
                if (discoveryService == null) {
                    Log.d(WIFI_CONNECTOR_TAG,"discoveryService not created");
                }
            } else {
                Log.d(WIFI_CONNECTOR_TAG, "discoveryService start");
                discoveryService.start();

            }
        }
        hasStarted = true;
    }

    /**
     * Stops every services started by this connector.
     * It runs a separate thread to properly unbind and close the connection service and  to close
     * the discovery service.
     */
    public void stop() {
        if (hasStarted) {
            Log.d(WIFI_CONNECTOR_TAG, "Closing services...");
            // Checks if the discovery service exists.
            if (discoveryService != null) {
                // Launch a new thread to stop the services previously launched by this connector.
                new Thread(new Runnable() {
                    @Override
                    public void run() {
                        unregisterReceivers();
                        discoveryService.stop();
                        APP_CONTEXT.unbindService(connectionService);
                        connectionService = null;
                        discoveryService = null;
                    }
                }).start();
            }
        }
        hasStarted = false;
    }

    /**
     * Register this connector so that it receives notification about changes in the list of available
     * devices.
     */
    private void registerReceivers() {
        discoveryServiceDeviceListUpdateReceiver = new ARDiscoveryServicesDevicesListUpdatedReceiver(this);
        LocalBroadcastManager localBroadcastManager = LocalBroadcastManager.getInstance(APP_CONTEXT);
        localBroadcastManager.registerReceiver(discoveryServiceDeviceListUpdateReceiver, new IntentFilter(ARDiscoveryService.kARDiscoveryServiceNotificationServicesDevicesListUpdated));
    }

    /**
     * Unregister this connector so that it no longer receives notification about changes in the
     * list of available devices.
     */
    private void unregisterReceivers() {
        LocalBroadcastManager localBroadcastManager = LocalBroadcastManager.getInstance(APP_CONTEXT);
        localBroadcastManager.unregisterReceiver(discoveryServiceDeviceListUpdateReceiver);
    }

    /**
     * Describes the action to do when there is an update in the available devices list.
     * Here send a message to the {@link GUIWelcome} handler.
     */
    @Override
    public void onServicesDevicesListUpdated() {
        List<ARDiscoveryDeviceService> devicesList = discoveryService.getDeviceServicesArray();
        Message msg = new Message();
        if (devicesList != null && devicesList.size() > 0) {
            msg.what = GUIWelcome.DEVICE_SERVICE_CONNECTED;
            msg.obj = devicesList;
            Log.d(WIFI_CONNECTOR_TAG, "Devices list updated : " + devicesList.size() + " devices available.");
            ((GUIWelcome) APP_CONTEXT).GUI_WELCOME_HANDLER.sendMessage(msg);
        } else {
            msg.what = GUIWelcome.DEVICE_SERVICE_DISCONNECTED;
        }
    }
}
