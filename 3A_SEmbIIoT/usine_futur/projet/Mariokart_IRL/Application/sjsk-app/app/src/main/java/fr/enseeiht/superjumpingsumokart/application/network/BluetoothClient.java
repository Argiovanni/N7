package fr.enseeiht.superjumpingsumokart.application.network;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothSocket;
import android.util.Log;

import java.io.IOException;
import java.util.Set;
import java.util.UUID;

import fr.enseeiht.superjumpingsumokart.application.GUIWelcome;

/**
 *  @author  Lucas Pascal
 * Defines the bluetooth client used to communicate with another paired phone.
 */
public class BluetoothClient extends Thread {

    /**
     * Logging tag. Useful for debugging.
     */
    private final static String BLUETOOTH_CLIENT_TAG = "BluetoothClient";

    /**
     * The {@link GUIWelcome} activity that launched the {@link BluetoothClient}.
     */
    private final GUIWelcome GUI_WELCOME;

    /**
     * The socket where will be hosted the bluetooth communication.
     */
    private BluetoothSocket btSocket;

    /**
     * The local bluetooth device.
     */
    private BluetoothDevice btDevice;

    /**
     * Create the client for the bluetooth connexion.
     *
     * @param guiWelcome The {@link GUIWelcome} activity that instantiates this {@link BluetoothClient}.
     */
    public BluetoothClient(GUIWelcome guiWelcome) {
        GUI_WELCOME = guiWelcome;
    }

    @Override
    public void run() {
        BluetoothSocket tmpSocket = null;
        BluetoothDevice tmpDevice = null;
        BluetoothAdapter btAdapter = BluetoothAdapter.getDefaultAdapter();
        Set<BluetoothDevice> pairedDevices = btAdapter.getBondedDevices();
        //It is assumed the two phones are already paired so we got only one device in pairedDevices.
        if (pairedDevices.size() > 0) {
            for (BluetoothDevice device : pairedDevices) {
                tmpDevice = device;
            }
            btDevice = tmpDevice;
        }
        // If the bluetooth service is disabled on the phone, enables it.
        if (!btAdapter.isEnabled()) {
            btAdapter.enable();
        }
        Log.d(BLUETOOTH_CLIENT_TAG, "Bluetooth service enabled.");
        // We get a BluetoothSocket object thanks to the BluetoothDevice.
        try {
            // The UUID is the login for the server. It is the same on the server's side.
            tmpSocket = btDevice.createInsecureRfcommSocketToServiceRecord(UUID.fromString("00001101-0000-1000-8000-00805F9B34FB"));
        } catch (IOException e) {
            Log.e(BLUETOOTH_CLIENT_TAG, "IOException while getting a socket : " + e.getMessage());
        }
        btSocket = tmpSocket;
        // Once the socket is created it is possible to stop bluetooth discovery service.
        btAdapter.cancelDiscovery();
        try {
            // Attempts to connect.
            Log.d(BLUETOOTH_CLIENT_TAG, "Trying to connect.");
            btSocket.connect();
            Log.d(BLUETOOTH_CLIENT_TAG, "Connected to server.");
        } catch (IOException e) {
            // If impossible to connect, we close the socket and kill the thread.
            Log.e(BLUETOOTH_CLIENT_TAG, "" + e.getMessage());
            try {
                // Attempts to connect using a different way
                btSocket = (BluetoothSocket) btDevice.getClass().getMethod("createRfcommSocket", new Class[]{int.class}).invoke(btDevice, 1);
                btSocket.connect();
            } catch (Exception ex) {
                Log.e(BLUETOOTH_CLIENT_TAG, "Failed to connect : " + e.getMessage());
                cancel();
            }
            return;
        }
        // Launches the Bluetooth communication thread
        BluetoothCommunication.initInstance(btSocket, GUI_WELCOME);
        //The bluetooth communication channel.
        BluetoothCommunication comClient = BluetoothCommunication.getInstance();
        comClient.start();
        GUI_WELCOME.GUI_WELCOME_HANDLER.sendEmptyMessage(GUIWelcome.BLUETOOTH_CLIENT_JOINED_GAME);
        Log.d(BLUETOOTH_CLIENT_TAG, "Bluetooth communication launched.");
    }

    /**
     * Closes the connection on the client side.
     */
    public void cancel() {
        Log.d(BLUETOOTH_CLIENT_TAG, "Cancel called.");
        try {
            if (btSocket != null) {
                btSocket.close();
                GUI_WELCOME.GUI_WELCOME_HANDLER.sendEmptyMessage(GUIWelcome.BLUETOOTH_CLIENT_SHUT_DOWN);
            }
        } catch (IOException e) {
            Log.e(BLUETOOTH_CLIENT_TAG, "IOException while closing socket : " + e.getMessage());
        }
    }
}