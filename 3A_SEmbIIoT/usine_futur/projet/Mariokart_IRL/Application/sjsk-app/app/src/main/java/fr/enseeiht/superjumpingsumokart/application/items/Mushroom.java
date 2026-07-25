package fr.enseeiht.superjumpingsumokart.application.items;

import android.util.Log;
import android.widget.ImageButton;

import fr.enseeiht.superjumpingsumokart.R;
import fr.enseeiht.superjumpingsumokart.application.DroneController;
import fr.enseeiht.superjumpingsumokart.arpack.DetectionTask;

/**
 * Implementation of a boost mushroom.
 * @author Romain Verset.
 */

public class Mushroom extends Item {

    /**
     * The logging tag. Useful for debugging.
     */
    private final static String ITEM_TAG = "Item.Mushroom";

    /**
     * Name of the {@link Item}.
     */
    private final static String NAME = "mushroom";

    /**
     * Default constructor of the class {@link Mushroom}.
     */
    public Mushroom() {
        super(NAME);
    }

    @Override
    public boolean useItem(DroneController droneController, DetectionTask.Symbol symbol) {
        Log.d(ITEM_TAG, "You used a mushroom !");
        droneController.boost();
        return true;
    }

    @Override
    public void applyEffect(DroneController droneController) {
        // Nothing to do
    }

    @Override
    public void assignResource(ImageButton ib) {
        ib.setImageResource(R.drawable.mushroom);
    }
}
