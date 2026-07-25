package fr.enseeiht.superjumpingsumokart.application;

import android.util.Log;

import java.util.ArrayList;

import fr.enseeiht.superjumpingsumokart.application.circuit.Circuit;
import fr.enseeiht.superjumpingsumokart.application.items.Banana;
import fr.enseeiht.superjumpingsumokart.application.items.Blooper;
import fr.enseeiht.superjumpingsumokart.application.items.FakeBox;
import fr.enseeiht.superjumpingsumokart.application.items.Item;
import fr.enseeiht.superjumpingsumokart.application.items.RedShell;
import fr.enseeiht.superjumpingsumokart.application.network.BluetoothCommunication;
import fr.enseeiht.superjumpingsumokart.application.network.BluetoothCommunicationListener;
import fr.enseeiht.superjumpingsumokart.arpack.DetectionTask;
import fr.enseeiht.superjumpingsumokart.arpack.GUIGame;
import fr.enseeiht.superjumpingsumokart.arpack.GUIGameListener;

/**
 * This class is used to manage the game.
 * @author Vivian Guy, Matthieu Michel, Romain Verset.
 */
public class Game implements BluetoothCommunicationListener, GUIGameListener {

    /**
     * The logging tag. Useful for debugging.
     */
    private final static String GAME_TAG = "GAME";

    /**
     * {@link GUIGame}, the interface of the Game.
     */
    private GUIGame guiGame;

    /**
     * Boolean to check if the race is started or not.
     */
    private final ArrayList<GameListener> GAME_LISTENERS = new ArrayList<>();

    /**
     * The two drones attempting the race.
     */
    private Drone drone, otherDrone;

    /**
     * Two booleans attesting that the video stream is available and the drone controller is ready.
     */
    private boolean videoStreamAvailable = false, droneControllerReady = false;

    /**
     * Two booleans attesting that the two drones are ready.
     */
    private boolean ready = false, otherReady = false;

    /**
     * Two booleans attesting that the race is started and finished.
     */
    private boolean started = false, finished = false;

    /**
     * The bluetooth communication between the two players.
     */
    private BluetoothCommunication comBT;

    /**
     * Default constructor of the class {@link Game}.
     * @param guiGame interface of the {@link Game}.
     */
    public Game(GUIGame guiGame, BluetoothCommunication comBT, boolean isServer) {
        // Add markers for boxes
        this.guiGame = guiGame;
        registerGameListener(guiGame);
        if (Circuit.getInstance() == null) {
            Circuit.initInstance(-1, -1);
        }
        this.started = false;
        this.comBT = comBT;
        if (comBT != null) {
            this.comBT = comBT;
            comBT.setGame(this);
            registerGameListener(comBT);
            Log.d(GAME_TAG, "2 players game created.");
            if (isServer) {
                comBT.sendCircuit();
            }
        } else {
            otherReady = true;
            Log.d(GAME_TAG, "1 player game created.");
        }
        checkReadyAndStartRace();
    }

    /**
     * Starts the race if the video stream is available, the drone controller is ready and the other
     * drone too.
     */
    private void checkReadyAndStartRace() {
        Log.d(GAME_TAG, "checkReadyAndStartRace called");
        if (droneControllerReady) {
            Log.d(GAME_TAG, "droneControllerReady");
        }
        if (videoStreamAvailable) {
            Log.d(GAME_TAG, "videoStreamAvailable");
        }
        if (droneControllerReady && videoStreamAvailable) {
            ready =  true;
            for (GameListener gl : GAME_LISTENERS) {
                gl.onPlayerReady();
            }
        }
        if (ready && otherReady) {
            Log.d(GAME_TAG, "player and other player are ready to start the race");
            started = true;
            guiGame.GUI_GAME_HANDLER.sendEmptyMessage(GUIGame.LAP_COUNT_UPDATE);
            guiGame.GUI_GAME_HANDLER.sendEmptyMessage(GUIGame.CHECKPOINT_COUNT_UPDATE);
            for (GameListener gl : GAME_LISTENERS) {
                gl.onStartRace();
            }
        }
    }

    /**
     * Add a {@link GameListener}.
     * @param gameListener the listener to add.
     */
    private void registerGameListener(GameListener gameListener) {
        GAME_LISTENERS.add(gameListener);
    }

    /**
     * Check the current status of the {@link Game}.
     * @return true if the {@link Game} if started otherwise false.
     */
    public boolean isStarted() {
        return started;
    }

    /**
     * Check the current status of the {@link Game}.
     * @return true if the {@link Game} if finished otherwise false.
     */
    public boolean isFinished() {
        return finished;
    }

    /**
     * Set the drone
     * @param drone the drone
     */
    public void setDrone(Drone drone) {
        this.drone = drone;
    }

    // GUIGameListener methods
    @Override
    public void onItemUsed(DetectionTask.Symbol symbol, Item item) {
        for(GameListener listener  : this.GAME_LISTENERS) {
            listener.onPlayerUseItem(item,symbol);
        }
    }

    @Override
    public void onSymbolTouched(DetectionTask.Symbol symbol) {
        Item item = Circuit.getInstance().getObjects().get(symbol);
        if (item != null) {
            for (GameListener listener : this.GAME_LISTENERS) {
                listener.onItemTouched(item, symbol);
            }
            Circuit.getInstance().removeObject(symbol);
            guiGame.getRenderer().deleteModelAtSymbol(symbol);
        }
    }

    @Override
    public void onPlayerFinished() {
        if (comBT != null) {
            for (GameListener gl : GAME_LISTENERS) {
                gl.onPlayerFinished();
            }
        }
        GAME_LISTENERS.clear();
        finished = true;
        if (comBT != null) {
            comBT.cancel();
        }
    }

    @Override
    public void onPlayerGaveUp() {
        if (comBT != null) {
            for (GameListener gl : GAME_LISTENERS) {
                Log.d(GAME_TAG,"Player gives up notify the listener");
                gl.onPlayerGaveUp();
            }
        }
        GAME_LISTENERS.clear();
        finished = true;
        if (comBT != null) {
            comBT.cancel();
        }
    }

    @Override
    public void onPlayerDetectsArrivalLine() {
        if (drone.getCurrentCheckpoint() >= Circuit.getInstance().getCheckpointToCheck()) {
            drone.setCurrentLap(drone.getCurrentLap() + 1 < Circuit.getInstance().getLaps() ? drone.getCurrentLap() + 1 : Circuit.getInstance().getLaps());
            drone.setCurrentCheckpoint(0);
            for (GameListener gl : GAME_LISTENERS) {
                gl.onPlayerFinishedLap();
            }
        }
        if (drone.getCurrentLap() == Circuit.getInstance().getLaps()) {
            onPlayerFinished();
        }
    }

    @Override
    public void onPlayerDetectsCheckpoint() {
        drone.setCurrentCheckpoint(drone.getCurrentCheckpoint() + 1 < Circuit.getInstance().getCheckpointToCheck() ? drone.getCurrentCheckpoint() + 1 : Circuit.getInstance().getCheckpointToCheck());
    }

    @Override
    public void onDroneControllerReady() {
        droneControllerReady = true;
        checkReadyAndStartRace();
    }

    @Override
    public void onVideoStreamAvailable() {
        videoStreamAvailable = true;
        checkReadyAndStartRace();
    }

    // BluetoothCommunicationListener methods
    @Override
    public void onSecondPlayerReady() {
        this.otherReady = true;
        otherDrone = new Drone();
        checkReadyAndStartRace();
    }

    @Override
    public void onSecondStartRace() {
        guiGame.onStartRace();
    }

    @Override
    public void onSecondPlayerLapFinished() {
        otherDrone.setCurrentLap(otherDrone.getCurrentLap() + 1);
    }

    @Override
    public void onSecondPlayerUsesItem(String msg) {
        String[] msgSplit = msg.split("/");
        String name = msgSplit[0];
        DetectionTask.Symbol itemMarker;
        switch (name) {
            case "redshell":
                Log.d(GAME_TAG,"You've been hit by a shell!");
                RedShell redShell = new RedShell(guiGame);
                redShell.applyEffect(guiGame.getController());
                break;
            case "banana":
                Log.d(GAME_TAG,"A banana has been put on the circuit by second player");
                itemMarker = DetectionTask.Symbol.valueOf(msgSplit[1]);
                Banana banana = new Banana();
                Circuit.getInstance().addObject(itemMarker,banana);
                guiGame.getRenderer().defineModelAtSymbol(banana, itemMarker);

                break;
            case "box":
                Log.d(GAME_TAG,"A box has been put on the circuit by second player");
                itemMarker = DetectionTask.Symbol.valueOf(msgSplit[1]);
                FakeBox box = new FakeBox();
                Circuit.getInstance().addObject(itemMarker,box);
                guiGame.getRenderer().defineModelAtSymbol(box, itemMarker);
                break;
            case "blooper" :
                Log.d(GAME_TAG, "Blooper received");
                Blooper blooper = new Blooper(guiGame);
                blooper.applyEffect(guiGame.getController());
        }
    }

    @Override
    public void onSecondPlayerTouchedItem(String msg){
        String[] msgSplit = msg.split("/");
        DetectionTask.Symbol symbol = DetectionTask.Symbol.valueOf(msgSplit[1]);
        Circuit.getInstance().removeObject(symbol);
        guiGame.getRenderer().deleteModelAtSymbol(symbol);
    }

    @Override
    public void onSecondPlayerFinished() {
        guiGame.notifyDefeat();

        GAME_LISTENERS.clear();
        finished = true;
        if (comBT != null) {
            comBT.cancel();
        }
    }

    @Override
    public void onSecondPlayerGaveUp() {
        guiGame.notifyVictory();
        GAME_LISTENERS.clear();
        finished = true;
        if (comBT != null) {
            comBT.cancel();
        }
    }

    @Override
    public void onCircuitReceived() {
        checkReadyAndStartRace();
    }

    public void onPlayerEntersPitStop() {
        Log.d(GAME_TAG, "Player enters pit stop");
        for (GameListener gl : GAME_LISTENERS) {
            gl.onPlayerEntersPitStop();
        }
    }


    public void onPlayerExitsPitStop() {
        Log.d(GAME_TAG, "Player exits pit stop");
        for (GameListener gl : GAME_LISTENERS) {
            gl.onPlayerExitsPitStop();
        }
    }


    public void onFuelLevelChanged(int fuelLevel) {
        for (GameListener gl : GAME_LISTENERS) {
            gl.onFuelLevelChanged(fuelLevel);
        }
    }


    public void onCriticalFuel() {
        Log.d(GAME_TAG, "Critical fuel level reached");
        for (GameListener gl : GAME_LISTENERS) {
            gl.onCriticalFuel();
        }
    }
}