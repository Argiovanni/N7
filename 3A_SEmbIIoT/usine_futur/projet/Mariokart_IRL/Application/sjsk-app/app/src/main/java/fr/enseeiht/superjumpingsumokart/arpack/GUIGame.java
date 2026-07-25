package fr.enseeiht.superjumpingsumokart.arpack;

import android.app.Activity;
import android.content.pm.ActivityInfo;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.PixelFormat;
import android.graphics.drawable.AnimationDrawable;
import android.hardware.Sensor;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.opengl.GLSurfaceView;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.view.MotionEvent;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.FrameLayout;
import android.widget.ImageButton;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.Toast;
import android.content.SharedPreferences;

import com.parrot.arsdk.arcontroller.ARFrame;
import com.parrot.arsdk.ardiscovery.ARDiscoveryDevice;
import com.parrot.arsdk.arsal.ARNativeData;
import com.parrot.arsdk.ardiscovery.ARDiscoveryDeviceService;

import org.artoolkit.ar.base.ARToolKit;
import org.artoolkit.ar.base.AndroidUtils;

import java.util.ArrayList;

import fr.enseeiht.superjumpingsumokart.R;
import fr.enseeiht.superjumpingsumokart.application.circuit.Circuit;
import fr.enseeiht.superjumpingsumokart.application.DroneController;
import fr.enseeiht.superjumpingsumokart.application.Game;
import fr.enseeiht.superjumpingsumokart.application.GameListener;
import fr.enseeiht.superjumpingsumokart.application.items.Item;
import fr.enseeiht.superjumpingsumokart.application.network.BluetoothCommunication;
import fr.enseeiht.superjumpingsumokart.application.network.WifiConnector;

/**
 * User interface {@link Activity} used while in game.
 * It it composed of several to pilot the drone device buttons and two {@link SurfaceView}, one for
 * the video stream upcoming from the drone device, another one for OpenGL rendering.
 * @author Romain Verset
 *
 */
public class GUIGame extends Activity implements GameListener {

    /**
     * The logging tag. Useful for debugging.
     */
    private static String GUI_GAME_TAG = "GUIGame";

    /**
     * Handler used to communicate with the Bluetooth thread and the drone Controller thread.
     */
    public final Handler GUI_GAME_HANDLER = new Handler() {
        @Override
        public void handleMessage(Message msg) {
            switch (msg.what) {
                case RECEIVE_FRAME:
                    new DetectionTask(GUIGame.this).execute(currentFrame);
                    break;
                case CONTROLLER_STOPPING_ON_ERROR:
                    Toast.makeText(GUIGame.this, "Loosing controller connection", Toast.LENGTH_LONG).show();
                    for (GUIGameListener ggl : GUI_GAME_LISTENERS) {
                        ggl.onPlayerGaveUp();
                    }
                    GUI_GAME_LISTENERS.clear();
                    finish();
                    break;
                case RENDER_AR:
                    renderAR();
                    break;
                case DISPLAY_ITEM :
                    displayItem();
                    break;
                case CONTROLLER_RUNNING:
                    for (GUIGameListener ggl : GUI_GAME_LISTENERS) {
                        ggl.onDroneControllerReady();
                    }
                    break;
                case VICTORY:
                    Toast.makeText(GUIGame.this, "YOU WON !", Toast.LENGTH_SHORT).show();
                    break;
                case DEFEAT:
                    Toast.makeText(GUIGame.this, "YOU LOST !", Toast.LENGTH_SHORT).show();
                    break;
                case LAP_COUNT_UPDATE:
                    lapsTextView.setText(Integer.toString(controller.getDrone().getCurrentLap()) + "/" + Integer.toString(Circuit.getInstance().getLaps()));
                    break;
                case CHECKPOINT_COUNT_UPDATE :
                    checkpointTextView.setText(Integer.toString(controller.getDrone().getCurrentCheckpoint()) + "/" + Integer.toString(Circuit.getInstance().getCheckpointToCheck()));
                    break;
                case LAST_MARKER_SEEN_UPDATE :
                    lmsTextView.setText((controller.getDrone().getLastMarkerSeen().name()));
                    break;
                case ANIMATE_BLOOPER :
                    animationLayout.setBackgroundResource(R.drawable.blooper_animation);
                    AnimationDrawable adb = (AnimationDrawable) animationLayout.getBackground();
                    adb.stop(); // We need to stop the animation before starting in order to make it repeatable.
                    adb.start();
                    break;
                case ANIMATE_RED_SHELL :
                    animationLayout.setBackgroundResource(R.drawable.red_shell_animation);
                    AnimationDrawable adrs = (AnimationDrawable) animationLayout.getBackground();
                    adrs.stop(); // We need to stop the animation before starting in order to make it repeatable.
                    adrs.start();
                    break;
                case ANIMATE_MAGIC_BOX :
                    sendTrapAnim.setBackgroundResource(R.drawable.magic_box_animation);
                    AnimationDrawable admb = (AnimationDrawable) sendTrapAnim.getBackground();
                    admb.stop(); // We need to stop the animation before starting in order to make it repeatable.
                    admb.start();
                    break;
                case FUEL_GAUGE_UPDATE:
                    updateFuelGaugeUI();
                    break;
                default:
                    break;
            }
        }
    };

    /**
     * Message for {@link GUIGame#GUI_GAME_HANDLER}.
     */
    public final static int RECEIVE_FRAME = 0;

    /**
     * Message for {@link GUIGame#GUI_GAME_HANDLER}.
     */
    public final static int DISPLAY_ITEM = 1;

    /**
     * Message for {@link GUIGame#GUI_GAME_HANDLER}.
     */
    public final static int RENDER_AR = 3;

    /**
     * Message for {@link GUIGame#GUI_GAME_HANDLER}.
     */
    public final static int CONTROLLER_STOPPING_ON_ERROR = 4;

    /**
     * Message for {@link GUIGame#GUI_GAME_HANDLER}.
     */
    public final static int CONTROLLER_RUNNING = 5;

    /**
     * Message for {@link GUIGame#GUI_GAME_HANDLER}.
     */
    public final static int VICTORY = 6;

    /**
     * Message for {@link GUIGame#GUI_GAME_HANDLER}.
     */
    public final static int DEFEAT = 7;

    /**
     * Message for {@link GUIGame#GUI_GAME_HANDLER}.
     */
    public static final int LAP_COUNT_UPDATE = 8;

    /**
     * Message for {@link GUIGame#GUI_GAME_HANDLER}.
     */
    public final static int CHECKPOINT_COUNT_UPDATE = 9;

    /**
     * Message for {@link GUIGame#GUI_GAME_HANDLER}.
     */
    public final static int LAST_MARKER_SEEN_UPDATE = 2;

    /**
     * Message for {@link GUIGame#GUI_GAME_HANDLER}.
     */
    public final static int ANIMATE_BLOOPER = 10;

    /**
     * Message for {@link GUIGame#GUI_GAME_HANDLER}.
     */
    public final static int ANIMATE_RED_SHELL = 11;

    /**
     * Message for {@link GUIGame#GUI_GAME_HANDLER}.
     */
    public final static int ANIMATE_MAGIC_BOX = 12;

    /**
     * Message for {@link GUIGame#GUI_GAME_HANDLER}.
     */
    public final static int FUEL_GAUGE_UPDATE = 13;

    /**
     * The width of the frames of the Jumping Sumo Camera.
     */
    final static int VIDEO_WIDTH = 640;

    /**
     * The height of the frames of the Jumping Sumo Camera.
     */
    final static int VIDEO_HEIGHT = 480;

    /**
     * List of listeners to notify when an event occurs in an instance of {@link GUIGame}.
     */
    private final ArrayList<GUIGameListener> GUI_GAME_LISTENERS = new ArrayList<>();

    /**
     * The controller that dispatches commands from the user to the device.
     */
    private DroneController controller;

    /**
     * The game associated to the current {@link GUIGame}.
     */
    private Game game;

    /**
     * The current frame to display.
     */
    private byte[] currentFrame;

    /**
     * The renderer provided to {@link GUIGame#glView}.
     */
    private ItemRenderer renderer;

    /**
     * Inner state variable.
     * Boolean variables used to know when to initialise the {@link ARToolKit} markers.
     */
    private boolean firstUpdate = true;

    /**
     * Inner state variable.
     * Boolean variable used to know when the camera view is available so that we know when to start
     * the markers research.
     */
    private boolean cameraViewAvailable = false;

    // VIEWS VARIABLE

    /**
     * The button used to display and use the {@link fr.enseeiht.superjumpingsumokart.application.Drone #currentItem}.
     */
    private ImageButton sendTrapBtn;

    private FrameLayout mainLayout, animationLayout, sendTrapAnim;
    private TextView lapsTextView, checkpointTextView, lmsTextView, fuelGaugeTextView;
    private SurfaceView cameraView;
    private ProgressBar fuelGauge;

    private GLSurfaceView glView;

    // Partie Gyroscope
    private SharedPreferences sharedPreferences;

    //Public pour qu'il soit accessible depuis DroneController (utiliser pour l'appui sur le bouton)
    //public boolean savedImageValue;

    public boolean usingGyro;

    private ImageButton imageButton;

    /**
     * Ajout du sensor manager et du sensor afin de récupérer les informations du gyroscope
     */
    private SensorManager sensorManager;
    private Sensor gyroscopeSensor;
    private SensorEventListener gyroscopeListener;
    private Sensor accelerometerSensor;
    private SensorEventListener accelerometerListener;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        // Initializes the GUI from layout file
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_gui_game);

        // Partie gyroscope
        // Initialize SharedPreferences
        sharedPreferences = getSharedPreferences("MyPrefs", MODE_PRIVATE);

        // Retrieve the last state from SharedPreferences
        usingGyro = sharedPreferences.getBoolean("usingGyro", false);

        // Set UI according to gyro or not
        onSwitchModeGyroscope();

        // Ajout du gyroscope
        sensorManager = (SensorManager) getSystemService(SENSOR_SERVICE);
        gyroscopeSensor = sensorManager.getDefaultSensor(Sensor.TYPE_GYROSCOPE);

        // Ajout de l'acceleromètre
        accelerometerSensor = sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER);

        if(gyroscopeSensor == null){
            Toast.makeText(this,"The device has no gyroscope !", Toast.LENGTH_SHORT).show();
        } else {
            Toast.makeText(this,"Congrats you can work !", Toast.LENGTH_SHORT).show();
        }

        if(accelerometerSensor == null){
            Toast.makeText(this,"The device has no accelerometer !", Toast.LENGTH_SHORT).show();
        } else {
            Toast.makeText(this,"Congrats you can shake to jump !", Toast.LENGTH_SHORT).show();
        }

        // Binds with the bluetooth connector
        BluetoothCommunication bluetoothConnector = BluetoothCommunication.getInstance();
        if (bluetoothConnector != null) {
            Log.d(GUI_GAME_TAG, "BluetoothConnector not null, multi player mode.");
        }

        // Checks if the activity is a server or a client
        boolean isServer = (boolean) getIntent().getExtras().get("isServer");

        // Creation of the game
        game = new Game(this, bluetoothConnector, isServer);
        registerGuiGameListener(game);

        // Binds with the drone and creates its controller
        ARDiscoveryDeviceService currentDeviceService = (ARDiscoveryDeviceService) getIntent().getExtras().get("currentDeviceService");
        if (currentDeviceService == null)
            Log.d(GUI_GAME_TAG, "Got NOOOOO device service from activity GUIWelcome...");
        ARDiscoveryDevice currentDevice = WifiConnector.createDevice(currentDeviceService);
        if (currentDevice != null)
            Log.d(GUI_GAME_TAG, "Device created, attempting to create its controller...");
        else
            Log.d(GUI_GAME_TAG, "Device NOT created...");
        controller = new DroneController(this, currentDevice,gyroscopeSensor,accelerometerSensor);
        Log.d(GUI_GAME_TAG, "Controller of the device created.");
        game.setDrone(controller.getDrone());

        // Sets some graphical settings;
        getWindow().setFormat(PixelFormat.TRANSLUCENT);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN);
        setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);

        // Logs information about the displaying screen
        AndroidUtils.reportDisplayInformation(this);

        // Initializes the view for ModeButton (Gyroscope)
        imageButton = (ImageButton) findViewById(R.id.imageButton);

        // Set the initial image resource based on the current state
        imageButton.setImageResource((!usingGyro) ? R.drawable.pngwing_com : R.drawable.steeringwheelmario_removebg_preview);

        // Initializes the views of the GUI
        mainLayout = (FrameLayout) findViewById(R.id.mainLayout);
        animationLayout = (FrameLayout) findViewById(R.id.animationLayout);
        sendTrapAnim = (FrameLayout) findViewById(R.id.sendTrapLayout);
        sendTrapAnim.setBackgroundColor(getResources().getColor(android.R.color.transparent));
        ImageButton turnLeftBtn = (ImageButton) findViewById(R.id.turnLeftBtn);
        ImageButton turnRightBtn = (ImageButton) findViewById(R.id.turnRightBtn);
        ImageButton moveBackwardBtn = (ImageButton) findViewById(R.id.moveBackwardBtn);
        ImageButton moveForwardBtn = (ImageButton) findViewById(R.id.moveForwardBtn);
        ImageButton jumpBtn = (ImageButton) findViewById(R.id.jumpBtn);
        sendTrapBtn = (ImageButton) findViewById(R.id.sendTrapBtn);
        checkpointTextView = (TextView) findViewById(R.id.checkpointTextView);
        lapsTextView = (TextView) findViewById(R.id.lapsTextView);
        lmsTextView = (TextView) findViewById(R.id.lmsTextView);
        fuelGaugeTextView = (TextView) findViewById(R.id.fuelGaugeTextView);
        fuelGauge = (ProgressBar) findViewById(R.id.fuelGauge);

        // Defines action listeners
        turnLeftBtn.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                switch (event.getAction()) {
                    case MotionEvent.ACTION_DOWN:
                        Log.d(GUI_GAME_TAG, "Turn left pressed");
                        controller.turnLeft();
                        break;
                    case MotionEvent.ACTION_UP:
                        Log.d(GUI_GAME_TAG, "Turn left released");
                        controller.stopRotation();
                        break;
                }
                return true;
            }
        });
        turnRightBtn.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                switch (event.getAction()) {
                    case MotionEvent.ACTION_DOWN:
                        Log.d(GUI_GAME_TAG, "Turn right pressed");
                        controller.turnRight();
                        break;
                    case MotionEvent.ACTION_UP:
                        Log.d(GUI_GAME_TAG, "Turn right released");
                        controller.stopRotation();
                        break;
                }
                return true;
            }
        });
        moveForwardBtn.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                switch (event.getAction()) {
                    case MotionEvent.ACTION_DOWN:
                        Log.d(GUI_GAME_TAG, "Move forward pressed.");
                        controller.moveForward();
                        break;
                    case MotionEvent.ACTION_UP:
                        Log.d(GUI_GAME_TAG, "Move forward released.");
                        controller.stopMotion();
                        break;
                }
                return true;
            }
        });
        moveBackwardBtn.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                switch (event.getAction()) {
                    case MotionEvent.ACTION_DOWN:
                        Log.d(GUI_GAME_TAG, "Move backward pressed.");
                        controller.moveBackward();
                        break;
                    case MotionEvent.ACTION_UP:
                        Log.d(GUI_GAME_TAG, "Move backward released.");
                        controller.stopMotion();
                        break;
                }
                return true;
            }
        });

        sendTrapBtn.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View view, MotionEvent motionEvent) {
                if (motionEvent.getAction() == MotionEvent.ACTION_UP) {
                    DetectionTask.Symbol lastMarkerSeen = controller.getDrone().getLastMarkerSeen();
                    ArrayList<DetectionTask.Symbol> markers = Circuit.getInstance().getMarkers();
                    long pressDuration = motionEvent.getEventTime() - motionEvent.getDownTime();
                    // Send the object on the next marker forward if it is a long touch
                    if (pressDuration > 500 && markers.size() > 1) {
                        Log.d(GUI_GAME_TAG, "sentTrapBtn long touch");
                        // Get the list of markers and the last marker seen
                        // Found the next marker on the circuit
                        int lastMarkerSeenIndex = markers.indexOf(lastMarkerSeen);
                        int nextMarkerIndex = (lastMarkerSeenIndex + 1 == markers.size()) ? 0 : lastMarkerSeenIndex + 1;
                        DetectionTask.Symbol nextMarker = markers.get(nextMarkerIndex);
                        Item item = controller.getDrone().getCurrentItem();
                        if (controller.useItem(nextMarker)) {
                            for (GUIGameListener ggl : GUI_GAME_LISTENERS) {
                                ggl.onItemUsed(nextMarker, item);
                            }
                        }
                    } else {
                        Log.d(GUI_GAME_TAG, "Send trap button released, short press.");
                        Item item = controller.getDrone().getCurrentItem();
                        if (controller.useItem(lastMarkerSeen)) {
                            for (GUIGameListener ggl : GUI_GAME_LISTENERS) {
                                ggl.onItemUsed(lastMarkerSeen, item);
                            }
                        }
                    }
                }
                return true;
            }
        });
        jumpBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Log.d(GUI_GAME_TAG, "Jump pressed.");
                controller.longJump();
            }
        });
    }

    @Override
    public void onStart() {
        super.onStart();
        if (!ARToolKit.getInstance().nativeInitialised()) {
            ARToolKit.getInstance().initialiseNative(getCacheDir().getAbsolutePath());
        }
    }

    @Override
    public void onResume() {
        super.onResume();
        Log.d(GUI_GAME_TAG, "Resuming GUIGame activity");
        firstUpdate = true;
        if (controller != null) {
            controller.startController();
        }
        initCameraSurfaceView();
        initGLSurfaceView();
        ARToolKit.getInstance().initialiseAR(VIDEO_WIDTH, VIDEO_HEIGHT, "Data/camera_para.dat", 0, false);

        // Reprise du gyroscope
        if(gyroscopeListener != null){
            this.sensorManager.registerListener(gyroscopeListener,gyroscopeSensor,SensorManager.SENSOR_DELAY_FASTEST);
        }

        // Reprise du accelerometer
        if(accelerometerListener != null){
            this.sensorManager.registerListener(accelerometerListener,accelerometerSensor,SensorManager.SENSOR_DELAY_FASTEST);
        }
    }

    @Override
    protected void onPause() {
        super.onPause();
        if (glView != null) {
            glView.onPause();
        }
        // Pause du gyroscope
        if(gyroscopeListener != null){
            this.sensorManager.unregisterListener(gyroscopeListener);
        }

        if(accelerometerListener != null){
            this.sensorManager.unregisterListener(accelerometerListener);
        }

        mainLayout.removeView(glView);
    }

    @Override
    public void onStop() {
        Log.d(GUI_GAME_TAG,"calling on stop");
        super.onStop();
        if (controller.isRunning()) {
            controller.stopController();
        }
        for (GUIGameListener ggl : GUI_GAME_LISTENERS) {
            if (game != null && game.isStarted()) {
                ggl.onPlayerGaveUp();
            }
        }
        GUI_GAME_LISTENERS.clear();
        BluetoothCommunication.deleteInstance();
    }

    /**
     * Initialises the camera surface view.
     * Finds the surface view in the layout and adds necessary callbacks to the it.
     */
    private void initCameraSurfaceView() {
        cameraView = (SurfaceView) findViewById(R.id.cameraSurfaceView);
        cameraView.getHolder().addCallback(new SurfaceHolder.Callback() {
            @Override
            public void surfaceCreated(SurfaceHolder holder) {
                cameraViewAvailable = true;
                Log.d(GUI_GAME_TAG, "Camera surface view created, ready to display.");
            }

            @Override
            public void surfaceChanged(SurfaceHolder holder, int format, int width, int height) {
                //NOTHING TO DO
            }

            @Override
            public void surfaceDestroyed(SurfaceHolder holder) {
                cameraViewAvailable = false;
                ARToolKit.getInstance().cleanup();
                Log.d(GUI_GAME_TAG, "Camera surface view destroyed.");
            }
        });
    }

    /**
     * Initialises the OpenGL surface view.
     * Instantiates a {@link GLSurfaceView} and configures it. Also provides the renderer to the OpenGL surface view
     * and add it in the layout of the activity.
     */
    private void initGLSurfaceView() {
        // Create the GL view
        glView = new GLSurfaceView(GUIGame.this);
        glView.setEGLConfigChooser(8, 8, 8, 8, 16, 0);
        glView.getHolder().setFormat(PixelFormat.TRANSLUCENT); // Needs to be a translucent surface so the camera preview shows through.
        renderer = new ItemRenderer();
        glView.setRenderer(renderer);
        glView.setRenderMode(GLSurfaceView.RENDERMODE_WHEN_DIRTY);
        glView.setZOrderMediaOverlay(true); // Request that GL view's SurfaceView be on top of other SurfaceViews (including CameraPreview's SurfaceView).
        mainLayout.addView(glView, new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        if (glView != null) {
            glView.onResume();
        }
    }

    /**
     * Method used by {@link #controller} to send the current frame of its video stream to the GUI (Romain Verset - 01/02/2017).
     * @param frame The frame received from the device.
     */
    public void onFrameReceived(ARFrame frame) {
        if (firstUpdate) {
            renderer.configureARScene();
            firstUpdate = false;
            for (GUIGameListener ggl : GUI_GAME_LISTENERS) {
                ggl.onVideoStreamAvailable();
            }
        }
        currentFrame = frame.getByteData();
        GUI_GAME_HANDLER.sendEmptyMessage(RECEIVE_FRAME);
        GUI_GAME_HANDLER.sendEmptyMessage(DISPLAY_ITEM);
    }

    /**
     * Method called by {@link #GUI_GAME_HANDLER} to refresh the view of the GUI and update the displayed
     * frame from the video stream of the device (Romain Verset - 01/02/2017).
     */
    public void updateCameraSurfaceView(Bitmap frameToDraw) {
        if (cameraViewAvailable) {
            Canvas canvas = cameraView.getHolder().lockCanvas();
            canvas.drawBitmap(frameToDraw, 0, 0, null);
            cameraView.getHolder().unlockCanvasAndPost(canvas);
        }
    }

    /**
     * Render loaded models according to visible markers on {@link GUIGame#glView}.
     */
    public void renderAR() {
        if (glView != null && renderer != null && ARToolKit.getInstance().getProjectionMatrix() != null) {
            Log.d(GUI_GAME_TAG, "renderAR() called.");
            glView.requestRender();
        }
    }

    /**
     * Method used to display the current trap owned by the player (Matthieu Michel - 30/01/2017).
     */
    private void displayItem() {
        Item currentItem = controller.getDrone().getCurrentItem();
        Log.d(GUI_GAME_TAG, currentItem.getName()+" is owned by the player");
        currentItem.assignResource(sendTrapBtn);
    }

    /**
     * Register a {@link GUIGameListener}so that it can be notified when needed.
     * @param guiGameListener The listener to register.
     */
    public void registerGuiGameListener(GUIGameListener guiGameListener) {
        GUI_GAME_LISTENERS.add(guiGameListener);
    }

    /**
     * Display a message on the screen to notify the player he has won.
     */
    public void notifyVictory() {
        if (!game.isFinished()) {
            GUI_GAME_HANDLER.sendEmptyMessage(VICTORY);
        }
    }

    /**
     * Display a message on the screen to notify the player he has lost.
     */
    public void notifyDefeat() {
        if (!game.isFinished()) {
            GUI_GAME_HANDLER.sendEmptyMessage(DEFEAT);
        }
    }

    /**
     * Called when a {@link DetectionTask} detects a marker not associated with the arrival line or a checkpoint.
     */
    public void circuitMarkerDetected() {
        GUI_GAME_HANDLER.sendEmptyMessage(LAST_MARKER_SEEN_UPDATE);
    }

    /**
     * Called when a {@link DetectionTask} detects a marker associated with a checkpoint ({@link fr.enseeiht.superjumpingsumokart.arpack.DetectionTask.Symbol#KANJI} by default).
     */
    public void checkpointDetected() {
        GUI_GAME_HANDLER.sendEmptyMessage(CHECKPOINT_COUNT_UPDATE);
        for (GUIGameListener ggl : GUI_GAME_LISTENERS) {
            ggl.onPlayerDetectsCheckpoint();
        }
    }

    /**
     * Called when a {@link DetectionTask} detects a marker associated with the arrival line ({@link fr.enseeiht.superjumpingsumokart.arpack.DetectionTask.Symbol#HIRO} by default).
     */
    public void arrivalLineDetected() {
        for (GUIGameListener ggl : GUI_GAME_LISTENERS) {
            ggl.onPlayerDetectsArrivalLine();
        }
    }

    /**
     * Method called when a {@link fr.enseeiht.superjumpingsumokart.arpack.DetectionTask.Symbol} is detected by the drone and the drone is close enough to "activate" it.
     * @param symbol The symbol touched by the drone.
     */
    public void touchedSymbol(DetectionTask.Symbol symbol) {
        for (GUIGameListener ggl : GUI_GAME_LISTENERS) {
            ggl.onSymbolTouched(symbol);
        }
    }

    // GETTERS AND SETTERS

    /**
     * @return The {@link DroneController} used by the activity.
     */
    public DroneController getController() {
        return controller;
    }

    /**
     * @return The renderer used in conjunction with {@link GUIGame#glView}.
     */
    public ItemRenderer getRenderer() {
        return renderer;
    }

    // GAME_LISTENER METHODS

    @Override
    public void onPlayerFinishedLap() {
        GUI_GAME_HANDLER.sendEmptyMessage(GUIGame.LAP_COUNT_UPDATE);
    }

    @Override
    public void onPlayerUseItem(Item item, DetectionTask.Symbol symbol) {
        if (symbol != null) {
            renderer.defineModelAtSymbol(item, symbol);
        }
        displayItem();
    }

    @Override
    public void onPlayerGaveUp() {
        notifyDefeat();
    }

    @Override
    public void onPlayerReady() {
        // Nothing to do here.
    }

    @Override
    public void onPlayerFinished() {
        notifyVictory();
    }

    @Override
    public void onItemTouched(Item item, DetectionTask.Symbol symbol) {
        item.applyEffect(controller);
    }

    @Override
    public void onStartRace() {
        controller.setRunning(true);
    }

    @Override
    public void onPlayerEntersPitStop() {
        Log.d(GUI_GAME_TAG, "Pit stop entered - showing pit stop UI");
        Toast.makeText(GUIGame.this, "Refueling... Stay in position!", Toast.LENGTH_SHORT).show();
    }

    @Override
    public void onPlayerExitsPitStop() {
        Log.d(GUI_GAME_TAG, "Pit stop exited");
        Toast.makeText(GUIGame.this, "Pit stop exited", Toast.LENGTH_SHORT).show();
    }

    @Override
    public void onFuelLevelChanged(int fuelLevel) {
        // Update fuel gauge UI on next GUI update
        GUI_GAME_HANDLER.sendEmptyMessage(GUIGame.FUEL_GAUGE_UPDATE);
    }

    @Override
    public void onCriticalFuel() {
        Log.d(GUI_GAME_TAG, "Critical fuel level - performance degraded");
        Toast.makeText(GUIGame.this, "CRITICAL FUEL! Find a pit stop!", Toast.LENGTH_SHORT).show();
    }

    public void registerGyroscopeListener(SensorEventListener gyroscopeListener){
        this.gyroscopeListener = gyroscopeListener;
        this.sensorManager.registerListener(gyroscopeListener,gyroscopeSensor,SensorManager.SENSOR_DELAY_FASTEST);
    }

    public void registerAccelerometerListener(SensorEventListener accelerometerListener){
        this.accelerometerListener = accelerometerListener;
        this.sensorManager.registerListener(accelerometerListener,accelerometerSensor,SensorManager.SENSOR_DELAY_GAME);
    }

    public void onSwitchModeGyroscope() {
        View right = findViewById(R.id.turnRightBtn);
        View left = findViewById(R.id.turnLeftBtn);
        // Mode Gyroscope
        if (usingGyro) {
            left.setVisibility(View.GONE);
            right.setVisibility(View.GONE);
            // Mode classique
        } else {
            left.setVisibility(View.VISIBLE);
            right.setVisibility(View.VISIBLE);
        }
    }

    public void onImageButtonClick(View view) {

        // Toggle the state
        usingGyro = !usingGyro;

        // Toggle between the two images
        if (usingGyro) {
            imageButton.setImageResource(R.drawable.steeringwheelmario_removebg_preview);
        } else {
            // Eviter donuts
            controller.stopRotation();
            imageButton.setImageResource(R.drawable.pngwing_com);
        }

        onSwitchModeGyroscope();

        // Save the current state to SharedPreferences
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putBoolean("usingGyro", usingGyro);
        editor.apply();
    }

    /**
     * Update the fuel gauge display on the UI with integer fuel model (0-100).
     */
    public void updateFuelGaugeUI() {
        Log.d(GUI_GAME_TAG, "Updating fuel gauge UI...");
        if (controller != null && fuelGaugeTextView != null) {
            int fuelLevel = controller.getDrone().getCurrentFuel();
            fuelGaugeTextView.setText(String.format("Fuel: %d%%", fuelLevel));
            Log.d(GUI_GAME_TAG, "Updating fuel gauge: " + fuelLevel + "%");
            if (fuelGauge != null) {
                fuelGauge.setProgress(fuelLevel);
                Log.d(GUI_GAME_TAG, "Fuel gauge ProgressBar updated to " + fuelLevel + "%");
                if (fuelLevel <= 10) {
                    fuelGauge.setProgressTintList(getResources().getColorStateList(android.R.color.holo_red_dark));
                } else {
                    fuelGauge.setProgressTintList(getResources().getColorStateList(android.R.color.holo_green_dark));
                }
            } else {
                Log.d(GUI_GAME_TAG, "Fuel gauge ProgressBar is null!");
            }
        }
    }
}
