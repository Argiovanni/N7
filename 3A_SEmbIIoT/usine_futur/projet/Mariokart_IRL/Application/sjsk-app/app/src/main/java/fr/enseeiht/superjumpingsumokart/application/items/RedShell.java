package fr.enseeiht.superjumpingsumokart.application.items;

import android.util.Log;
import android.widget.ImageButton;

import fr.enseeiht.superjumpingsumokart.R;
import fr.enseeiht.superjumpingsumokart.application.DroneController;
import fr.enseeiht.superjumpingsumokart.arpack.DetectionTask;
import fr.enseeiht.superjumpingsumokart.arpack.GUIGame;

/**
 * Implementation of red shell {@link Item}.
 * @author Lucas Pascal.
 */

public class RedShell extends Item {
    /**
     * The logging tag. Useful for debugging.
     */
    private final static String ITEM_TAG = "ITEM";

    /**
     * Name of the {@link Item}.
     */
    private final static String NAME = "redshell";

    /**
     * Reference of the {@link GUIGame}.
     */
    private final GUIGame GUI_GAME;

    /**
     * Default constructor of the class {@link RedShell}.
     */
    public RedShell(GUIGame guiGame) {
        super(NAME);
        GUI_GAME = guiGame;
    }

    @Override
    public boolean useItem(DroneController droneController, DetectionTask.Symbol symbol) {
        Log.d(ITEM_TAG, "A red shell has been thrown!");
        return true;
    }

    @Override
    public void applyEffect(DroneController droneController) {
        Log.d(ITEM_TAG, "You've been hit by a red shell!");
        if (GUI_GAME != null) {
            GUI_GAME.GUI_GAME_HANDLER.sendEmptyMessage(GUIGame.ANIMATE_RED_SHELL);
        }
        droneController.spinningJump();
    }

    @Override
    public void assignResource(ImageButton ib) {
        ib.setImageResource(R.drawable.redshell);
    }
}
