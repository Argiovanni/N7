package fr.enseeiht.superjumpingsumokart.application.network;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothServerSocket;
import android.bluetooth.BluetoothSocket;
import android.util.Log;

import java.io.IOException;
import java.util.UUID;

import fr.enseeiht.superjumpingsumokart.application.GUIWelcome;

/**
 * @author  Lucas Pascal
 * Defines the bluetooth server used to communicate with another paired phone.
 */
public class BluetoothServer extends Thread {

    private final static String BLUETOOTH_SERVER_TAG = "BluetoothServer";

    /**
     * The {@link GUIWelcome} activity that launched the {@link BluetoothClient}.
     */
    private GUIWelcome GUI_WELCOME;

    /**
     * The server socket where will be hosted the bluetooth communication.
     */
    private BluetoothServerSocket btSocket;

    /**
     * Certifies that the bluetooth connexion is established.
     */
    private boolean isConnected;

    /**
     * Create the server for the bluetooth connexion.
     *
     * @param guiWelcome The {@link GUIWelcome} activity that instantiates this {@link BluetoothServer}.
     */
    public BluetoothServer(GUIWelcome guiWelcome) {
        GUI_WELCOME = guiWelcome;
    }

    @Override
    public void run() {
        BluetoothAdapter btAdapter = BluetoothAdapter.getDefaultAdapter();
        // If the bluetooth service is disabled on the phone, enables it.
        if (!btAdapter.isEnabled()) {
            btAdapter.enable();
        }
        // We wait until the bluetooth is actually connected
        while (!btAdapter.isEnabled()) {
            try {
                wait(100);
            } catch (InterruptedException e) {
                Log.e(BLUETOOTH_SERVER_TAG, "Waited for bluetooth service enabled but it failed.");
            }
        }
        Log.d(BLUETOOTH_SERVER_TAG, "Bluetooth service enabled.");
        try {
            btSocket = btAdapter.listenUsingInsecureRfcommWithServiceRecord("My Server", UUID.fromString("00001101-0000-1000-8000-00805F9B34FB"));
        } catch (IOException e) {
            Log.e(BLUETOOTH_SERVER_TAG, "IOException while gettting the server socket : " + e.getMessage());
        }
        // Once the socket is created it is possible to stop bluetooth discovery service.
        btAdapter.cancelDiscovery();
        BluetoothSocket socket = null;
        Log.d(BLUETOOTH_SERVER_TAG, "Waiting for client connections...");
        GUI_WELCOME.GUI_WELCOME_HANDLER.sendEmptyMessage(GUIWelcome.BLUETOOTH_SERVER_READY);
        // We wait for a client.
        while (!isConnected) {
            if (btSocket != null) {
                Log.d(BLUETOOTH_SERVER_TAG, "Server socket initialized.");
            } else {
                Log.d(BLUETOOTH_SERVER_TAG, "Not connected.");
            }
            try {
                Log.d(BLUETOOTH_SERVER_TAG, "Trying to connect...");
                socket = btSocket.accept();
            } catch (IOException e) {
                Log.e(BLUETOOTH_SERVER_TAG, "IOException while getting a socket : " + e.getMessage());
                break;
            }
            // Checks if the connexion is established.
            if (socket != null) {
                Log.d(BLUETOOTH_SERVER_TAG, "Connected to a client.");
                try {
                    isConnected = true;
                    // We close the server socket as it is no longer useful.
                    btSocket.close();
                } catch (IOException e) {
                    Log.e(BLUETOOTH_SERVER_TAG, "IOException while getting a socket : " + e.getMessage());
                    cancel();
                }
                break;
            }
        }
        // We launch the BT communication threads.
        if (socket != null) {
            GUI_WELCOME.GUI_WELCOME_HANDLER.sendEmptyMessage(GUIWelcome.BLUETOOTH_SERVER_GOT_CONNECTION);
            BluetoothCommunication.initInstance(socket, GUI_WELCOME);
            //The bluetooth communication.
            BluetoothCommunication btComServer = BluetoothCommunication.getInstance();
            btComServer.start();
            Log.d(BLUETOOTH_SERVER_TAG, "Bluetooth communication launched.");
        }
    }

    /**
     * Closes the connection on the server side.
     */
    public void cancel() {
        Log.d(BLUETOOTH_SERVER_TAG, "Cancel called.");
        try {
            if (btSocket != null) {
                btSocket.close();
                GUI_WELCOME.GUI_WELCOME_HANDLER.sendEmptyMessage(GUIWelcome.BLUETOOTH_SERVER_SHUT_DOWN);
            }
        } catch (IOException e) {
            Log.e(BLUETOOTH_SERVER_TAG, "IOException while closing socket : " + e.getMessage());
        }
    }
}