package fr.enseeiht.superjumpingsumokart.application.network;

/**
 * Defines all notification functions for a class listening for {@link BluetoothCommunication}.
 * Created by Lucas on 15/02/2017.
 */

public interface BluetoothCommunicationListener {
    /**
     * Notify the game that the second player is ready.
     */
    void onSecondPlayerReady();

    /**
     * Notify the game that the second player has started the race.
     */
    void onSecondStartRace();

    /**
     * Notify the game that the second player has finished a lap.
     */
    void onSecondPlayerLapFinished();

    /**
     * Notify the game that the second player has finished the race.
     */
    void onSecondPlayerFinished();

    /**
     * Notify the game that the second player has given up.
     */
    void onSecondPlayerGaveUp();

    /**
     * Notify the game that the second player is using an item.
     *
     * @param msg used by the second player.
     */
    void onSecondPlayerUsesItem(final String msg);

    /**
     * Notify the game that the second player has touched an item.
     *
     * @param msg touched by the second player.
     */
    void onSecondPlayerTouchedItem(final String msg);

    /**
     * Notify a circuit has been received from bluetooth communication.
     */
    void onCircuitReceived();

}
