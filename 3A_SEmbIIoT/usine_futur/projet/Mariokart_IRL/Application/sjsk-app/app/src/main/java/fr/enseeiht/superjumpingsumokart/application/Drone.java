package fr.enseeiht.superjumpingsumokart.application;


import android.util.Log;

import fr.enseeiht.superjumpingsumokart.application.items.*;

import fr.enseeiht.superjumpingsumokart.arpack.DetectionTask;

/**
 * Class representing a drone in the application.
 * It represents a drone as a player, not as a device.
 * @author Vivian Guy.
 */

public class Drone {

    private final static String DRONE_TAG = "Drone_jet";

    /**
     * The current item the drone has.
     */
    private Item currentItem;

    /**
     * The current number of lap made by the drone on the {@link fr.enseeiht.superjumpingsumokart.application.circuit.Circuit#circuitInstance}.
     */
    private int currentLap;

    /**
     * The current number of checkpoint validated by the drone on the {@link fr.enseeiht.superjumpingsumokart.application.circuit.Circuit#circuitInstance}.
     */
    private int currentCheckpoint;

    /**
     * The last marker seen by the drone.
     */
    private DetectionTask.Symbol lastMarkerSeen;

    /**
     * The maximum fuel capacity of the drone (integer: 0-100).
     */
    private static final int MAX_FUEL = 100;

    /**
     * The current fuel level of the drone (0-100).
     */
    private int currentFuel;

    /**
     * Fuel consumption at normal speed (NORMAL_SPEED = 20).
     */
    private static final int FUEL_CONSUMPTION_NORMAL = 5;

    /**
     * Fuel consumption at reduced speed (REDUCED_SPEED = 10).
     */
    private static final int FUEL_CONSUMPTION_REDUCED = 2;

    /**
     * The fuel refill rate per time unit when in pit stop.
     */
    private static final int FUEL_REFILL_RATE = 25;

    /**
     * Boolean to check if the drone is currently in a pit stop.
     */
    private boolean inPitStop = false;

    /**
     * The threshold below which the drone gets reduced speed (10 fuel).
     */
    private static final int CRITICAL_FUEL_THRESHOLD = 10;

    /**
     * Boolean to check if the drone is out of fuel (0 fuel).
     */
    private boolean outOfFuel = false;

    private boolean isMoving = false;

    /**
     * Constructor for the class {@link Drone}.
     */
    Drone() {
        this.currentItem = new NullItem();
        this.currentCheckpoint = 0;
        this.currentLap = 0;
        this.currentFuel = MAX_FUEL;
        this.inPitStop = false;
    }

    /**
     * Get the {@link Item} of the drone.
     * @return the current item of the drone.
     */
    public Item getCurrentItem() {
        return currentItem;
    }

    /**
     * Set the {@link Item} of the drone.
     * @param currentItem the new item of the drone.
     */
    public void setCurrentItem(Item currentItem) {

        this.currentItem = currentItem;
    }

    /**
     * @return the number of lap the drone has done.
     */
    public int getCurrentLap() {
        return currentLap;
    }

    /**
     * @param currentLap the number of lap the drone has done.
     */
    void setCurrentLap(int currentLap) {
        this.currentLap = currentLap;
    }

    /**
     *
     * @return The current number of checkpoints validated by the drone.
     */
    public int getCurrentCheckpoint() {
        return currentCheckpoint;
    }

    /**
     * @param currentCheckpoint the number of checkpoint validated by the drone.
     */
    void setCurrentCheckpoint(int currentCheckpoint) {
        this.currentCheckpoint = currentCheckpoint;
    }

    /**
     * @return The marker last marker seen by the drone.
     */
    public DetectionTask.Symbol getLastMarkerSeen() {
        return lastMarkerSeen;
    }

    /**
     * @param lastMarkerSeen The marker to put as last marker seen.
     */
    public void setLastMarkerSeen(DetectionTask.Symbol lastMarkerSeen) {
        this.lastMarkerSeen = lastMarkerSeen;
    }

    /**
     * Get the current fuel level of the drone (0-100).
     * @return the current fuel level as integer.
     */
    public int getCurrentFuel() {
        return currentFuel;
    }

    /**
     * Get the fuel level as a percentage (0-100).
     * @return the fuel percentage.
     */
    public int getFuelPercentage() {
        return (currentFuel * 100) / MAX_FUEL;
    }

    /**
     * Set the current fuel level of the drone.
     * @param fuel the fuel level to set (0-100).
     */
    public void setCurrentFuel(int fuel) {
        this.currentFuel = Math.min(fuel, MAX_FUEL);
        this.currentFuel = Math.max(this.currentFuel, 0);
        this.outOfFuel = (this.currentFuel == 0);
    }

    /**
     * Consume fuel based on the drone's current speed state.
     * - Normal speed (20) consumes 5 fuel per update
     * - Reduced speed (10) consumes 2 fuel per update
     * - Out of fuel (0) consumes 0
     * @param speed the current speed of the drone (20, 10, or 5).
     */
    public void consumeFuel(byte speed) {
        if (!inPitStop && currentFuel > 0) {
            int consumption = 0;
            if (speed == 20) {
                consumption = FUEL_CONSUMPTION_NORMAL; // 5
            } else if (speed == 10) {
                consumption = FUEL_CONSUMPTION_REDUCED; // 2
            }
            Log.d(DRONE_TAG,"consumption= "+ consumption);
            setCurrentFuel(currentFuel-consumption);
        } else {
            Log.d(DRONE_TAG,"No fuel consumption. pit stop : "+ inPitStop + " currentFuel: "+ currentFuel);
        }
    }

    /**
     * Refill fuel when the drone is in a pit stop.
     * Increases fuel by 5 per update when stationary in a pit stop.
     */
    public void refillFuel() {
        if (inPitStop && currentFuel < MAX_FUEL && !this.isMoving) {
            setCurrentFuel(currentFuel+FUEL_REFILL_RATE);
        }
    }

    /**
     * Check if the drone can move at full speed (20).
     * Below critical threshold (10), speed is reduced to 10.
     * At zero fuel, drone is stopped.
     * @return true if fuel > CRITICAL_FUEL_THRESHOLD, false otherwise.
     */
    public boolean canMoveAtFullSpeed() {
        return currentFuel > CRITICAL_FUEL_THRESHOLD;
    }

    /**
     * Check if the drone has no fuel at all (0 fuel).
     * @return true if the drone is out of fuel, false otherwise.
     */
    public boolean isOutOfFuel() {
        return currentFuel == 0;
    }

    /**
     * Check if the drone is in a pit stop.
     * @return true if the drone is in a pit stop, false otherwise.
     */
    public boolean isInPitStop() {
        return inPitStop;
    }

    /**
     * Set whether the drone is in a pit stop.
     * @param inPitStop true if the drone enters a pit stop, false otherwise.
     */
    public void setInPitStop(boolean inPitStop) {
        this.inPitStop = inPitStop;
    }

    /**
     * Reset the drone's fuel to the maximum for a new race.
     */
    public void resetFuel() {
        this.currentFuel = MAX_FUEL;
        this.inPitStop = false;
    }

    public boolean getmoving(){
        return this.isMoving;
    }

    public void setmoving(boolean moving){
        this.isMoving = moving;
    }

}
