package fr.enseeiht.superjumpingsumokart.application.items;

import android.util.Log;
import android.widget.ImageButton;

import fr.enseeiht.superjumpingsumokart.R;
import fr.enseeiht.superjumpingsumokart.application.DroneController;
import fr.enseeiht.superjumpingsumokart.arpack.DetectionTask;
import fr.enseeiht.superjumpingsumokart.arpack.GUIGame;

/**
 * Implements a Blooper {@link Item}.
 * @author Romain Verset.
 */

public class Blooper extends Item {

    /**
     * The logging tag. Useful for debugging.
     */
    private final static String ITEM_TAG = "Item.Blooper";

    /**
     * Name of the {@link Item}.
     */
    private final static String NAME = "blooper";

    /**
     * Reference of the {@link GUIGame}.
     */
    private final GUIGame GUI_GAME;

    /**
     * Default constructor of the class {@link Blooper}.
     */
    public Blooper (GUIGame guiGame){
        super(NAME);
        GUI_GAME = guiGame;
    }

    @Override
    public boolean useItem(DroneController controller, DetectionTask.Symbol symbol) {
        Log.d(ITEM_TAG, "Used a blooper");
        return true;
    }

    @Override
    public void applyEffect(DroneController droneController) {
        Log.d(ITEM_TAG, "Blooper effect applied.");
        if (GUI_GAME != null) {
            GUI_GAME.GUI_GAME_HANDLER.sendEmptyMessage(GUIGame.ANIMATE_BLOOPER);
        }
    }

    @Override
    public void assignResource(ImageButton ib) {
        ib.setImageResource(R.drawable.squid);
    }
}
