package fr.enseeiht.superjumpingsumokart.application.items;

import android.util.Log;
import android.widget.ImageButton;

import fr.enseeiht.superjumpingsumokart.R;
import fr.enseeiht.superjumpingsumokart.application.DroneController;
import fr.enseeiht.superjumpingsumokart.arpack.DetectionTask;
import fr.enseeiht.superjumpingsumokart.arpack.GUIGame;

/**
 * Implementation of magic box {@link Item}.
 * @author Vivian Guy.
 */


public class MagicBox extends Item {

    /**
     * The logging tag. Useful for debugging.
     */
    private final static String ITEM_TAG = "Item.MagicBox";

    /**
     * Name of the {@link Item}.
     */
    private final static String NAME = "magicBox";

    /**
     * Reference of the {@link GUIGame}.
     */
    private final GUIGame GUI_GAME;

    /**
     * Default constructor of the class {@link MagicBox}.
     */
    public MagicBox(GUIGame guiGame) {
        super(NAME);
        GUI_GAME = guiGame;
    }

    @Override
    public boolean useItem(DroneController droneController, DetectionTask.Symbol symbol) {
        return true;
    }

    @Override
    public void applyEffect(DroneController droneController) {
        GUI_GAME.GUI_GAME_HANDLER.sendEmptyMessage(GUIGame.ANIMATE_MAGIC_BOX);
        int rand = 1+ (int) Math.floor(Math.random() * 5);
        Item item;
        switch (rand) {
            case 1 :
                item = new RedShell(null);
                break;
            case 2 :
                item = new FakeBox();
                break;
            case 3 :
                item = new RedShell(null);
                break;
            case 4 :
                item = new Mushroom();
                break;
            case 5 :
                item = new Blooper(null);
                break;
            default:
                item = new NullItem();
        }
        droneController.getDrone().setCurrentItem(item);
        Log.d(ITEM_TAG, "A, "+ item.getName()+" has been assigned to the droneController");
    }

    @Override
    public void assignResource(ImageButton ib) {
        ib.setImageResource(R.drawable.magicbox);
    }
}
