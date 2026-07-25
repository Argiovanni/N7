package fr.enseeiht.superjumpingsumokart.application;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.CompoundButton;
import android.widget.ImageButton;
import android.widget.Switch;
import android.widget.Toast;
import android.widget.ToggleButton;
import android.content.SharedPreferences;


import com.parrot.arsdk.ARSDK;
import com.parrot.arsdk.arsal.ARSALPrint;
import com.parrot.arsdk.ardiscovery.ARDiscoveryDeviceService;

import java.util.ArrayList;
import java.util.List;

import fr.enseeiht.superjumpingsumokart.R;
import fr.enseeiht.superjumpingsumokart.application.circuit.Circuit;
import fr.enseeiht.superjumpingsumokart.application.circuit.GUICircuit;
import fr.enseeiht.superjumpingsumokart.application.network.BluetoothClient;
import fr.enseeiht.superjumpingsumokart.application.network.BluetoothCommunication;
import fr.enseeiht.superjumpingsumokart.application.network.BluetoothServer;
import fr.enseeiht.superjumpingsumokart.application.network.WifiConnector;
import fr.enseeiht.superjumpingsumokart.arpack.GUIGame;
/**
 * The activity used as home screen for the application. From there it is possible to connect to a
 * drone, to launch a race, to manage circuits and to connect with another SuperJumpingSumoKart
 * application using Bluetooth.
 * @author Romain Verset.
 */
public class GUIWelcome extends Activity {

    // Static block to load libraries ParrotSDK3
    static {
        ARSDK.loadSDKLibs();
    }
    /**
     * The logging tag. Useful for debugging.
     */
    private final static String GUI_WELCOME_TAG = "GUIWelcome";

    /**
     * Message for {@link #GUI_WELCOME_HANDLER}.
     */
    public final static int DEVICE_SERVICE_CONNECTED = 0;

    /**
     * Message for {@link #GUI_WELCOME_HANDLER}.
     */public final static int DEVICE_SERVICE_DISCONNECTED = 1;

    /**
     * Message for {@link #GUI_WELCOME_HANDLER}.
     */
    public final static int BLUETOOTH_SERVER_READY = 3;

    /**
     * Message for {@link #GUI_WELCOME_HANDLER}.
     */
    public final static int BLUETOOTH_SERVER_GOT_CONNECTION = 4;

    /**
     * Message for {@link #GUI_WELCOME_HANDLER}.
     */
    public final static int BLUETOOTH_CLIENT_JOINED_GAME = 5;

    /**
     * Message for {@link #GUI_WELCOME_HANDLER}.
     */
    public final static int BLUETOOTH_SERVER_SHUT_DOWN = 6;

    /**
     * Message for {@link #GUI_WELCOME_HANDLER}.
     */
    public final static int BLUETOOTH_CLIENT_SHUT_DOWN = 7;

    /**
     * Message for {@link #GUI_WELCOME_HANDLER}.
     */
    public final static int CIRCUIT_RECEIVED = 8;

    /**
     * Handler used so that other {@link Thread} can communicate with the {@link Activity} thread.
     */
    public final Handler GUI_WELCOME_HANDLER = new Handler() {
        @Override
        public void handleMessage(Message msg) {
            switch (msg.what) {
                case DEVICE_SERVICE_CONNECTED :
                    enableWifiConnectionBtn();
                    if (msg.obj instanceof List) {
                        devicesList = (List<ARDiscoveryDeviceService>) msg.obj;
                    } else {
                        Log.d(GUI_WELCOME_TAG, "Object in msg can not be cast in List<ARDiscoveryDeviceService>");
                    }
                    break;
                case DEVICE_SERVICE_DISCONNECTED :
                    disableWifiConnectionBtn();
                    break;
                case BLUETOOTH_CLIENT_JOINED_GAME :
                    onClientConnected();
                    break;
                case BLUETOOTH_SERVER_READY :
                    onServerReady();
                    break;
                case BLUETOOTH_SERVER_GOT_CONNECTION :
                    onServerReceivedConnection();
                    break;
                case BLUETOOTH_SERVER_SHUT_DOWN:
                    onServerShutDown();
                    break;
                case BLUETOOTH_CLIENT_SHUT_DOWN:
                    onClientShutDown();
                    break;
                case CIRCUIT_RECEIVED:
                    enableStartARaceButton();
                    break;
                default :
                    break;
            }
        }
    };

    // Buttons in the GUI
    private Button startRaceBtn;
    private ToggleButton wifiConnectionBtn;
    private Button btHostBtn;
    private Button btJoinBtn;
    // Connection and device variables
    private WifiConnector wifiConnector = null;

    // Partie Gyroscope
    private ImageButton imageButton;
    private boolean usingGyro = false;

    /**
     * Manages the bluetooth socket if on server side. If on client side, is null.
     */
    private BluetoothServer server = null;

    /**
     * Manages the bluetooth socket if on client side. If on server side, is null.
     */
    private BluetoothClient client = null;

    /**
     * The connection with the drone device.
     */
    private ARDiscoveryDeviceService currentDeviceService = null;

    /**
     * The list of drone connections available. Contains only one element if connected on the WiFi
     * hotspot of a drone.
     */
    private List<ARDiscoveryDeviceService> devicesList = new ArrayList<>();

    // Inner state variables.
    private boolean isServer = true;
    private boolean serverHosting, clientConnected;

    private SharedPreferences sharedPreferences;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        // Initializes the GUI from layout file
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_gui_welcome);

        // Initializes remote connection
        wifiConnector = new WifiConnector(GUIWelcome.this);

        // Initializes the views of the GUI
        startRaceBtn = (Button) findViewById(R.id.startRaceBtn);
        wifiConnectionBtn = (ToggleButton) findViewById(R.id.connectWifiBtn);
        wifiConnectionBtn.setEnabled(false);
        btHostBtn = (Button) findViewById(R.id.connectBluetoothBtn);
        btJoinBtn = (Button) findViewById(R.id.joinBluetoothBtn);
        Button setCircuitBtn = (Button) findViewById(R.id.setCircuitBtn);
        Button exitBtn = (Button) findViewById(R.id.exitBtn);

        // Partie Gyroscope
        // Initializes the view for ModeButton
        imageButton = (ImageButton) findViewById(R.id.imageButton);

        // Initialize SharedPreferences
        sharedPreferences = getSharedPreferences("MyPrefs",MODE_PRIVATE);

        // Retrieve the last state from SharedPreferences
        usingGyro = sharedPreferences.getBoolean("usingGyro", false);

        // Set the initial image resource based on the current state
        imageButton.setImageResource((!usingGyro) ? R.drawable.pngwing_com : R.drawable.steeringwheelmario_removebg_preview);

        // Defines action listener
        startRaceBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                startRaceBtnAction();
            }
        });
        wifiConnectionBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                wifiConnectionBtnAction();
            }
        });
        btHostBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                btHostBtnAction();
            }
        });
        btJoinBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                btJoinBtnAction();
            }
        });
        setCircuitBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                setCircuitBtnAction();
            }
        });
        exitBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                exitBtnAction();
            }
        });

        btHostBtn.setBackgroundResource(android.R.drawable.btn_default);
        btJoinBtn.setBackgroundResource(android.R.drawable.btn_default);
        wifiConnectionBtn.setBackgroundResource(android.R.drawable.btn_default);
        exitBtn.setBackgroundResource(android.R.drawable.btn_default);
        setCircuitBtn.setBackgroundResource(android.R.drawable.btn_default);
        startRaceBtn.setBackgroundResource(android.R.drawable.btn_default);

    }

    @Override
    protected void onResume() {
        super.onResume();
        if (currentDeviceService == null) {
            disableWifiConnectionBtn();
        }

        // Retrieve the last state from SharedPreferences
        usingGyro = sharedPreferences.getBoolean("usingGyro", false);

        // Set the initial image resource based on the current state
        imageButton.setImageResource((!usingGyro) ? R.drawable.pngwing_com : R.drawable.steeringwheelmario_removebg_preview);
    }

    /**
     * Switch the current {@link GUIWelcome} {@link android.app.Activity} for a {@link GUIGame} {@link android.app.Activity}.
     * This switch requires to have a drone connected with the application.
     */
    private void startRaceBtnAction(){
        if (currentDeviceService == null) {
            Toast.makeText(GUIWelcome.this, R.string.no_drone_connected, Toast.LENGTH_SHORT).show();
        } else {
            Intent i = new Intent(GUIWelcome.this, GUIGame.class);
            i.putExtra("currentDeviceService", currentDeviceService);
            i.putExtra("isServer", isServer);
            Log.d(GUI_WELCOME_TAG, "Launching a GUIGame Activity...");
            startActivity(i);
        }
    }

    /**
     * Enables to connect with a Jumping Sumo drone.
     * <b>Your cell phone has to be connected to the access point provided by the Jumping Sumo drone.<b/>
     */
    private void wifiConnectionBtnAction() {
        try {
            if (wifiConnectionBtn.isChecked()) {
                currentDeviceService = devicesList.get(0);
                Log.d(GUI_WELCOME_TAG, "New device service bound to the application : " + currentDeviceService.toString());
            } else {
                Log.d(GUI_WELCOME_TAG, "Device service unbound from the application : " + currentDeviceService.toString());
                currentDeviceService = null;
            }
        } catch (NullPointerException npe) {
            Log.d(GUI_WELCOME_TAG, "Unable to bind the device service");
        }
    }

    /**
     * Enables to connect the phone with an other phone in bluetooth to launch multi player game.
     */
    private void btHostBtnAction() {
        if (!serverHosting) {
            startRaceBtn.setEnabled(false);
            server = new BluetoothServer(GUIWelcome.this);
            server.start();
            serverHosting = true;
        } else {
            onServerShutDown();
        }
    }

    /**
     * Enables to connect your phone to a bluetooth server to launch a multi player game.
     */
    private void btJoinBtnAction() {
        if (!clientConnected) {
            startRaceBtn.setEnabled(false);
            isServer = false;
            client = new BluetoothClient(GUIWelcome.this);
            client.start();
        } else {
            onClientShutDown();
        }
    }

    /**
     * Sends to a {@link GUICircuit} activity in order to manage circuits.
     */
    private void setCircuitBtnAction() {
        Intent i = new Intent(GUIWelcome.this, GUICircuit.class);
        Log.d(GUI_WELCOME_TAG, "Launching a GUICircuit Activity...");
        startActivity(i);
    }

    /**
     * Default action to do when the exit button is clicked.
     * It closes the eventual connection between the application and the drone and cleans
     * all variables used to avoid memory leak. It also closes all bluetooth connections.
     */
    private void exitBtnAction() {
        if (wifiConnector != null) {
            wifiConnector.stop();
            wifiConnector = null;
        }
        if (client != null) {
            client.cancel();
        }
        if (server != null) {
            server.cancel();
        }
        BluetoothCommunication.deleteInstance();
        currentDeviceService = null;
        devicesList = null;
        finish();
    }

    /**
     * Enable the WIFI connection button.
     * The button is allowed when the phone and the drone are on the same WiFi network.
     */
    private void enableWifiConnectionBtn() {
        wifiConnectionBtn.setEnabled(true);
    }

    /**
     * Disable the WIFI connection button.
     * The button is allowed when the phone and the drone are on the same WiFi network.
     */
    private void disableWifiConnectionBtn() {
        wifiConnectionBtn.setChecked(false);
        wifiConnectionBtn.setEnabled(false);
    }

    /**
     * Enable the player to click on start a race.
     * Used only when two players are conneced via Bluetooth. In this case client can not click on
     * {@link GUIWelcome#startRaceBtn} while the server has not sent its .
     */
    private void enableStartARaceButton() {
        startRaceBtn.setEnabled(true);
    }

    /**
     * Callback called when the {@link BluetoothServer} is ready and waiting for a {@link BluetoothClient}.
     */
    private void onServerReady() {
        btHostBtn.setBackgroundColor(getResources().getColor(R.color.waitingForClient));
        btHostBtn.setText(getResources().getString(R.string.hostBTButtonOn));
    }

    /**
     * Callback called when a {@link BluetoothClient} connects to the {@link BluetoothServer}.
     */
    private void onServerReceivedConnection() {
        btHostBtn.setBackgroundColor(getResources().getColor(R.color.connected));
        btHostBtn.setText(getResources().getString(R.string.hostBTButtonOnAndPlayerConnected));
        enableStartARaceButton();
    }

    /**
     * Callback called when the {@link BluetoothClient} has sucessfully connected to a {@link BluetoothServer}.
     */
    private void onClientConnected() {
        btJoinBtn.setBackgroundColor(getResources().getColor(R.color.connected));
        btJoinBtn.setText(getResources().getString(R.string.joinBTButtonOn));
        clientConnected = true;
    }

    /**
     * Callback called when the {@link BluetoothClient} is no longer available.
     */
    private void onClientShutDown() {
        btJoinBtn.setBackgroundColor(getResources().getColor(R.color.notConnected));
        btJoinBtn.setText(getResources().getString(R.string.joinBTButtonOff));
        if (client != null) {
            client = null;
        }
        clientConnected = false;
    }


    /**
     * Callback called when the {@link BluetoothServer} is no longer available.
     */
    public void onServerShutDown() {
        btHostBtn.setBackgroundResource(android.R.drawable.btn_default);
        btHostBtn.setText(getResources().getString(R.string.hostBTButtonOff));
        if (server != null) {
            server = null;
        }
        serverHosting = false;
    }

    // Partie Gyroscope
    public void onImageButtonClick(View view) {

        // Toggle the state
        usingGyro = !usingGyro;

        // Toggle between the two images
        if (usingGyro) {
            imageButton.setImageResource(R.drawable.steeringwheelmario_removebg_preview);
            Toast.makeText(GUIWelcome.this, "Playing with gyroscope!", Toast.LENGTH_LONG).show();
        } else {
            imageButton.setImageResource(R.drawable.pngwing_com);
            Toast.makeText(GUIWelcome.this, "Playing with buttons!", Toast.LENGTH_LONG).show();
        }

        // Save the current state to SharedPreferences
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putBoolean("usingGyro", usingGyro);
        editor.apply();
    }

}
