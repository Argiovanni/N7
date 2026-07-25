package fr.enseeiht.superjumpingsumokart.application;

import fr.enseeiht.superjumpingsumokart.application.circuit.Circuit;
import fr.enseeiht.superjumpingsumokart.application.items.Item;
import fr.enseeiht.superjumpingsumokart.arpack.DetectionTask;

/**
 * Interface for the communication between {@link fr.enseeiht.superjumpingsumokart.application.network.BluetoothCommunication}, {@link fr.enseeiht.superjumpingsumokart.arpack.GUIGame} and {@link Game}.
 * Methods from this interface enable to notify the Bluetooth module and the user interface from the
 * first player's action.
 * @author Vivian Guy.
 */

public interface GameListener {

    /**
     * Called when the player is ready to start the race.
     */
    void onPlayerReady();

    /**
     * Called when the player has finished the race.
     */
    void onPlayerFinished();

    /**
     * Called when the player has finished a lap.
     */

    void onPlayerFinishedLap();

    /**
     * Called when the player use an {@link Item}.
     * @param item The item used.
     */
    void onPlayerUseItem(Item item, DetectionTask.Symbol lastMarkerSeen);

    /**
     * Called when the player give up the race.
     */
    void onPlayerGaveUp();

    /**
     * Called when an {@link Item} is touched on the {@link Circuit}.
     * @param item The item touched.
     */
    void onItemTouched(Item item, DetectionTask.Symbol symbol);

    /**
     * Called when the two players are ready and the start begins.
     */
    void onStartRace();

    /**
     * Called when the player enters a pit stop for refueling.
     */
    void onPlayerEntersPitStop();

    /**
     * Called when the player exits a pit stop.
     */
    void onPlayerExitsPitStop();

    /**
     * Called when the fuel level changes.
     * @param fuelLevel the new fuel level (0-100 integer).
     */
    void onFuelLevelChanged(int fuelLevel);

    /**
     * Called when the fuel reaches a critical level.
     */
    void onCriticalFuel();
}
