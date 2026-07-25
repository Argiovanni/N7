package fr.enseeiht.superjumpingsumokart.application.items;

import android.util.Log;
import android.widget.ImageButton;

import fr.enseeiht.superjumpingsumokart.R;
import fr.enseeiht.superjumpingsumokart.application.circuit.Circuit;
import fr.enseeiht.superjumpingsumokart.application.DroneController;
import fr.enseeiht.superjumpingsumokart.arpack.DetectionTask;

/**
 * Implementation of a box {@link Item}.
 * @author Matthieu Michel.
 */

public class FakeBox extends Item {

    /**
     * The logging tag. Useful for debugging.
     */
    private final static String ITEM_TAG = "Item.FakeBox";

    /**
     * Name of the {@link Item}.
     */
    private final static String NAME = "box";

    /**
     * Default constructor of the class {@link FakeBox}.
     */
    public FakeBox() {
        super(NAME);
    }

    @Override
    public boolean useItem(DroneController controller, DetectionTask.Symbol symbol) {
        if (symbol != null) {
            Circuit.getInstance().addObject(symbol, this);
            Log.d(ITEM_TAG, "A TNT box has been put on the circuit");
            return true;
        } else {
            return false;
        }
    }

    @Override
    public void applyEffect(DroneController droneController) {
        Log.d(ITEM_TAG, "A TNT box has been touched");
        droneController.stopMotion();
        droneController.highJump();
    }

    @Override
    public void assignResource(ImageButton ib) {
        ib.setImageResource(R.drawable.redbox);
    }
}
