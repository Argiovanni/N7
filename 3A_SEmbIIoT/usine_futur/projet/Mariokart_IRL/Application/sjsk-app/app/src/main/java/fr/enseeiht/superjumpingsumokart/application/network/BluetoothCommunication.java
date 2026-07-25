package fr.enseeiht.superjumpingsumokart.application.network;

import android.bluetooth.BluetoothSocket;
import android.util.Log;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.charset.Charset;
import java.util.ArrayList;

import fr.enseeiht.superjumpingsumokart.application.circuit.Circuit;
import fr.enseeiht.superjumpingsumokart.application.GUIWelcome;
import fr.enseeiht.superjumpingsumokart.application.Game;
import fr.enseeiht.superjumpingsumokart.application.GameListener;
import fr.enseeiht.superjumpingsumokart.application.items.Item;
import fr.enseeiht.superjumpingsumokart.arpack.DetectionTask;

/**
 * @author  Lucas Pascal
 * Bluetooth communication channel used in the application so that to phones can send messages to
 * each other.
 * It manages the bluetooth communication between two paired devices and run in a separate thread
 * in order to avoid UI freezes.
 */
public final class BluetoothCommunication extends Thread implements GameListener {

    /**
     * Logging tag. Useful for debugging.
     */
    private final static String BLUETOOTH_COMMUNICATION_TAG = "BluetoothCommunication";

    /**
     * The GUIWelcome activity.
     */
    private final GUIWelcome GUI_WELCOME;

    /**
     * The singleton instance of BluetoothCommunication.
     */
    private static BluetoothCommunication btComInstance = null;

    /**
     * The socket used for communications.
     */
    private final BluetoothSocket BT_SOCKET;

    /**
     * List of instances listening to the singleton of BluetoothCommunication.
     */
    private final ArrayList<BluetoothCommunicationListener> BLUETOOTH_COMMUNICATION_LISTENERS = new ArrayList<>();

    /**
     * The {@link InputStream} on which messages are received.
     */
    private InputStream btInputStream;

    /**
     * The {@link OutputStream} on which messages are sent.
     */
    private OutputStream btOutputStream;

    /**
     * A boolean indicating that the BluetoothCommunication service is running.
     */
    private boolean isRunning;

    /**
     * Default constructor of BluetoothCommunication.
     * @param socket Socket used for communications.
     */
    private BluetoothCommunication(BluetoothSocket socket, GUIWelcome guiWelcome) {
        BT_SOCKET = socket;
        GUI_WELCOME = guiWelcome;
        // Initialisation of the streams
        try {
            btInputStream = socket.getInputStream();
            btOutputStream = socket.getOutputStream();
        } catch (IOException e) {
            Log.e(BLUETOOTH_COMMUNICATION_TAG, "IOException while opening streams : " + e.getMessage());
        }
    }

    /**
     * Initialises the singleton instance of BluetoothCommunication.
     * @param socket Socket used for communications.
     */
    static void initInstance(BluetoothSocket socket, GUIWelcome guiWelcome) {
        if (btComInstance == null) {
            btComInstance = new BluetoothCommunication(socket, guiWelcome);
        }
    }

    public static void deleteInstance() {
        if (btComInstance != null) {
            btComInstance.cancel();
            btComInstance = null;
        }
    }

    /**
     * Get the instance of BluetoothCommunication
     * @return The singleton instance of BluetoothCommunication.
     */
    public static BluetoothCommunication getInstance() {
        return btComInstance;
    }

    /**
     * Listening on the input stream continuously
     */
    public void run() {
        byte[] buffer = new byte[1024];
        int bytes;
        isRunning = true;
        // Permanent listening on the input stream.
        while (isRunning) {
            try {
                // Reading on the input stream.
                bytes = btInputStream.read(buffer);

                // Copies it.
                byte[] data = new byte[bytes];
                System.arraycopy(buffer, 0, data, 0, bytes);
                String receivedMsg = new String(data, Charset.forName("UTF-8"));
                Log.d(BLUETOOTH_COMMUNICATION_TAG,"Message"+ receivedMsg +" received");
                // Dispatches the message according to its key.
                dispatchMessage(receivedMsg);

            } catch (IOException e) {
                Log.d(BLUETOOTH_COMMUNICATION_TAG, "IOException : + " + e.getMessage());
                cancel();
                break;
            }
        }
    }

    /**
     * Closes the connection.
     */
    public void cancel() {
        try {
            isRunning = false;
            if (BT_SOCKET != null) {
                BT_SOCKET.close();
            }
            BLUETOOTH_COMMUNICATION_LISTENERS.clear();
        } catch (IOException e) {
            Log.d(BLUETOOTH_COMMUNICATION_TAG, "IOException while closing socket : " + e.getMessage());
        }
    }

    /**
     * Parse a message and then dispatch notifications to listeners in {@link BluetoothCommunication#BLUETOOTH_COMMUNICATION_LISTENERS}.
     * @param receivedMsg The received message to parse.
     */
    private void dispatchMessage(String receivedMsg) {
        String[] msgSplit = receivedMsg.split("/");
        String key = msgSplit[0];
        Log.d(BLUETOOTH_COMMUNICATION_TAG, "Message " + key + " received");
        switch (key) {
            case "isReady":
                Log.d(BLUETOOTH_COMMUNICATION_TAG,"other Player is ready received");
                for (BluetoothCommunicationListener listener : this.BLUETOOTH_COMMUNICATION_LISTENERS) {
                    listener.onSecondPlayerReady();
                    Log.d(BLUETOOTH_COMMUNICATION_TAG,"other Player is ready dispatched");
                }
                break;
            case "hasFinished":
                Log.d(BLUETOOTH_COMMUNICATION_TAG,"other Player has finished received");
                for (BluetoothCommunicationListener listener : this.BLUETOOTH_COMMUNICATION_LISTENERS) {
                    listener.onSecondPlayerFinished();
                }
                cancel();
                break;
            case "hasFinishedLap":
                for (BluetoothCommunicationListener listener : this.BLUETOOTH_COMMUNICATION_LISTENERS) {
                    listener.onSecondPlayerLapFinished();
                }
                break;
            case "itemUsed":
                Log.d(BLUETOOTH_COMMUNICATION_TAG,"other Player used an item");
                for (BluetoothCommunicationListener listener : this.BLUETOOTH_COMMUNICATION_LISTENERS) {
                    String itemInfos;
                    if (msgSplit.length == 2) { // if the object isn't on a marker
                        itemInfos = msgSplit[1];
                    } else { // if the object is on a marker
                        itemInfos = msgSplit[1]+ "/" + msgSplit[2];
                    }
                    listener.onSecondPlayerUsesItem(itemInfos);
                }
                break;
            case "circuit":
                // We create a new circuit and assign its parameters

                Log.d(BLUETOOTH_COMMUNICATION_TAG, "Circuit string received : " + receivedMsg);

                int lapsNumber = Integer.parseInt(msgSplit[1]);
                int checkPointToCkeck = Integer.parseInt(msgSplit[2]);

                Circuit.initInstance(lapsNumber,checkPointToCkeck);
                int i;
                for (i=3; i<msgSplit.length; i++){
                    String[] hashSplit = msgSplit[i].split(":");
                    String symbolsType = hashSplit[1];
                    DetectionTask.Symbol symbol = DetectionTask.Symbol.valueOf(symbolsType);
                    Circuit.getInstance().addMarker(symbol);
                }
                GUI_WELCOME.GUI_WELCOME_HANDLER.sendEmptyMessage(GUIWelcome.CIRCUIT_RECEIVED);
                for (BluetoothCommunicationListener bcl : BLUETOOTH_COMMUNICATION_LISTENERS) {
                    Log.d(BLUETOOTH_COMMUNICATION_TAG,"boucle for each circuit recu");
                    bcl.onCircuitReceived();
                }
                break;
            case "hasGiveUp":
                for (BluetoothCommunicationListener listener : this.BLUETOOTH_COMMUNICATION_LISTENERS) {
                    listener.onSecondPlayerGaveUp();
                }
                cancel();
                break;
            case "hasTouchedItem":
                for (BluetoothCommunicationListener listener : this.BLUETOOTH_COMMUNICATION_LISTENERS) {
                    String itemInfos;
                    if (msgSplit.length == 2) { // if the object hasn't assigned to a marker
                        itemInfos = msgSplit[1];
                    } else { // if the object was on a marker
                        itemInfos = msgSplit[1] + "/" + msgSplit[2];
                    }
                    listener.onSecondPlayerTouchedItem(itemInfos);
                }
                break;
            case "raceBegins":
                for (BluetoothCommunicationListener listener : this.BLUETOOTH_COMMUNICATION_LISTENERS) {
                    listener.onSecondStartRace();
                }
                break;
        }
    }

    /**
     * Write a message on the output steam of the socket.
     * @param bytes The bytes of the message.
     */
    private void write(byte[] bytes) {
        try {
            btOutputStream.write(bytes);
        } catch (IOException e) {
            Log.d(BLUETOOTH_COMMUNICATION_TAG, "IOException : + " + e.getMessage());
            cancel();
        }
    }

    /**
     * Send the circuit to the other player (server to client)
     */
    public void sendCircuit() {
        Circuit c = Circuit.getInstance();
        String dataMsg = "circuit/" + Integer.toString(c.getLaps()) + "/" + c.getCheckpointToCheck();
        for (DetectionTask.Symbol symbol : c.getMarkers()) {
            dataMsg = dataMsg.concat("/"+ c.getMarkers().indexOf(symbol) + ":" + symbol.name());
        }
        byte[] dataMsgBytes = dataMsg.getBytes(Charset.forName("UTF-8"));
        write(dataMsgBytes);
        Log.d(BLUETOOTH_COMMUNICATION_TAG, "Circuit send to client, string : " + dataMsg);
    }

    /**
     * Register a {@link BluetoothCommunicationListener} to the list of Bluetooth_communication_listeners
     * @param btListener the BluetoothCommunicationListener to register
     */
    private void registerCommunicationBTListener(BluetoothCommunicationListener btListener) {
        BLUETOOTH_COMMUNICATION_LISTENERS.add(btListener);
    }

    /**
     * Set the current {@link Game} associated to the BluetoothCommunication
     * @param game listened by {@link BluetoothCommunication}.
     */
    public void setGame(Game game) {
        if (game != null) {
            if (!BLUETOOTH_COMMUNICATION_LISTENERS.contains(game)) {
                registerCommunicationBTListener(game);
            }
        }
    }

    // BluetoothCommunication Listeners methods

    @Override
    public void onPlayerReady() {
        Log.d(BLUETOOTH_COMMUNICATION_TAG, "onPlayerReady called");
        // Create message
        String dataString = "isReady";
        byte[] dataBytes = dataString.getBytes(Charset.forName("UTF-8"));
        // Send the message
        write(dataBytes);
        Log.d(BLUETOOTH_COMMUNICATION_TAG, "onPlayerReady sent to the other phone");

    }

    @Override
    public void onPlayerFinished() {
        Log.d(BLUETOOTH_COMMUNICATION_TAG, "onPlayerFinished called");
        // Create message
        String dataString = "hasFinished";
        byte[] dataBytes = dataString.getBytes(Charset.forName("UTF-8"));
        // Send the message
        write(dataBytes);
        Log.d(BLUETOOTH_COMMUNICATION_TAG, "onPlayerFinished sent to the other phone");
        cancel();
    }

    @Override
    public void onPlayerFinishedLap() {
        Log.d(BLUETOOTH_COMMUNICATION_TAG, "onPlayerDetectsArrivalLine called");
        // Creates message
        String dataString = "hasFinishedLap";
        byte[] dataBytes = dataString.getBytes(Charset.forName("UTF-8"));
        // Send the message
        write(dataBytes);
        Log.d(BLUETOOTH_COMMUNICATION_TAG, "onPlayerDetectsArrivalLine sent to the other phone");
    }

    @Override
    public void onPlayerUseItem(final Item item, final DetectionTask.Symbol itemSymbol) {
        Log.d(BLUETOOTH_COMMUNICATION_TAG, "onPlayerUseItem called");
        // Creates message
        String dataString;
        String name = item.getName();

        if (itemSymbol != null) {
            String nameMarker = itemSymbol.name();
            dataString = "itemUsed" + "/" + name + "/" + nameMarker;
        } else {
            dataString = "itemUsed" + "/" + name;
        }
        byte[] dataBytes = dataString.getBytes(Charset.forName("UTF-8"));
        // Sends the message
        write(dataBytes);
        Log.d(BLUETOOTH_COMMUNICATION_TAG, "onPlayerUseItem sent to the other phone");
    }

    @Override
    public void onPlayerGaveUp() {
        Log.d(BLUETOOTH_COMMUNICATION_TAG, "onPlayerGaveUp called");
        // Create message
        String dataString = "hasGiveUp";
        byte[] dataBytes = dataString.getBytes(Charset.forName("UTF-8"));
        // Send the message
        write(dataBytes);
        Log.d(BLUETOOTH_COMMUNICATION_TAG, "onPlayerGaveUp sent to the other phone");
        cancel();
    }

    @Override
    public void onItemTouched(final Item item, final DetectionTask.Symbol itemSymbol) {
        Log.d(BLUETOOTH_COMMUNICATION_TAG, "onItemTouched called");
        // Create message
        String dataString;
        String name = item.getName();

        if (itemSymbol != null) {
            dataString = "hasTouchedItem" + "/" + name + "/" + itemSymbol.name();
        } else {
            dataString = "hasTouchedItem" + "/" + name;
        }
        byte[] dataBytes = dataString.getBytes(Charset.forName("UTF-8"));
        // Send the message
        write(dataBytes);
        Log.d(BLUETOOTH_COMMUNICATION_TAG, "onItemTouched sent to the other phone");
    }

    @Override
    public void onStartRace() {
        Log.d(BLUETOOTH_COMMUNICATION_TAG, "onStartRace called");
        // Create message
        String dataString = "raceBegins";
        byte[] dateBytes = dataString.getBytes(Charset.forName("UTF-8"));
        // Send the message
        write(dateBytes);
        Log.d(BLUETOOTH_COMMUNICATION_TAG, "onStartRace sent to the other phone");
    }


    //TODO: Clean
    @Override
    public void onCriticalFuel() {
        // Nothing to do here
    }

    @Override
    public void onFuelLevelChanged(int fuel){
        // Nothing to do here
    }

    @Override
    public void onPlayerEntersPitStop() {
        // Nothing to do here
    }

    @Override
    public void onPlayerExitsPitStop(){
        // Nothing to do here
    }
}