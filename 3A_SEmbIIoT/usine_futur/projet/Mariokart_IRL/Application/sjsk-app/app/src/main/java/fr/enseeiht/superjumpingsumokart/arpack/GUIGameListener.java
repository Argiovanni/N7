package fr.enseeiht.superjumpingsumokart.arpack;

import fr.enseeiht.superjumpingsumokart.application.Drone;
import fr.enseeiht.superjumpingsumokart.application.DroneController;
import fr.enseeiht.superjumpingsumokart.application.Game;
import fr.enseeiht.superjumpingsumokart.application.items.Item;

/**
 * Interface used in {@link Game} to notify it when there is a modification in {@link fr.enseeiht.superjumpingsumokart.arpack.GUIGame}.
 * @author michelmatthieu.
 */

public interface GUIGameListener {

    /**
     * Method used to notify {@link Game} that an {@link Item} as been used by the {@link Drone}.
     * @param symbol The symbol (ARToolkit marker) holding the item.
     * @param item The item used by the player.
     */
    void onItemUsed(DetectionTask.Symbol symbol, Item item);

    /**
     * Method used to notify {@link Game} that an {@link Item} as been touched by the {@link Drone}.
     * Actually it does not provide directly a reference on the touched {@link Item} but on the
     * ARToolkit marker hit by the drone. The item is then retrieved according to the marker if it
     * exists.
     * @param symbol The symbol touched by the player.
     */
    void onSymbolTouched(DetectionTask.Symbol symbol);

    /**
     * Method called when the controlled {@link Drone} gives up.
     */
    void onPlayerGaveUp();

    /**
     * Method called when the controlled {@link Drone} finishes the race.
     */
    void onPlayerFinished();

    /**
     * Method called when the controlled {@link Drone} detects an ARToolkit marker symbolizing the arrival line.
     */
    void onPlayerDetectsArrivalLine();

    /**
     * Method called when the controlled {@link Drone} detects an ARToolkit marker symbolizing a checkpoint.
     */
    void onPlayerDetectsCheckpoint();

    /**
     * Notify that the {@link fr.enseeiht.superjumpingsumokart.arpack.GUIGame} is able to display the video stream from the Jumping Sumo's camera.
     */
    void onVideoStreamAvailable();

    /**
     * Notify that the {@link DroneController} is ready to command the drone.
     */
    void onDroneControllerReady();
}
