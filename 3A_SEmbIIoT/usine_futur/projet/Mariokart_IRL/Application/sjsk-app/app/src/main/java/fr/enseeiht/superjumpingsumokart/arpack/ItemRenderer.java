package fr.enseeiht.superjumpingsumokart.arpack;

import android.util.Log;

import org.artoolkit.ar.base.ARToolKit;
import org.artoolkit.ar.base.rendering.ARRenderer;

import java.util.HashMap;

import javax.microedition.khronos.opengles.GL10;

import fr.enseeiht.superjumpingsumokart.application.items.Banana;
import fr.enseeiht.superjumpingsumokart.application.items.FakeBox;
import fr.enseeiht.superjumpingsumokart.application.items.Item;

/**
 * Provides the necessary methods to associate markers pattern and 3D models together.
 * Renderer to render on the {@link GUIGame} {@link android.opengl.GLSurfaceView}.
 * @author Romain Verset, JorgeEnrique.
 */

public final class ItemRenderer extends ARRenderer {

    /**
     * Logging tag. Useful for debugging.
     */
    private final static String ITEM_RENDERER_TAG = "ItemRenderer";

    /**
     * Contains the association between the symbols from the marker and the ID of their patterns in
     * ARToolkit.
     */
    final static HashMap<DetectionTask.Symbol, Integer> SYMBOLS_HASH_MAP = new HashMap<>();

    /**
     * Configures all markers for the application.
     * Associates 3D models with their respective markers and patterns.
     */
    public boolean configureARScene() {
        Log.d(ITEM_RENDERER_TAG, "configureARScene() called.");

        // Symbols for checkpoints, arrival line and Magic Boxes.
        SYMBOLS_HASH_MAP.put(DetectionTask.Symbol.HIRO, ARToolKit.getInstance().addModel2("Data/models/flag.obj", "single;Data/patt.hiro;80", DetectionTask.Symbol.HIRO.ordinal(), 1.0f, false));
        SYMBOLS_HASH_MAP.put(DetectionTask.Symbol.KANJI, ARToolKit.getInstance().addModel2("Data/models/checkpoint.obj", "single;Data/patt.kanji;80", DetectionTask.Symbol.KANJI.ordinal(), 1.0f, false));
        SYMBOLS_HASH_MAP.put(DetectionTask.Symbol.A, ARToolKit.getInstance().addModel2("Data/models/magicbox.obj", "single;Data/patt.a;80", DetectionTask.Symbol.A.ordinal(), 1.0f, false));

        // Initialisation of markers on the circuit.
        SYMBOLS_HASH_MAP.put(DetectionTask.Symbol.B, ARToolKit.getInstance().addModel2("Data/models/giantbanana.obj", "single;Data/patt.b;80", DetectionTask.Symbol.B.ordinal(), 20.0f, true));
        deleteModelAtSymbol(DetectionTask.Symbol.B);
        SYMBOLS_HASH_MAP.put(DetectionTask.Symbol.C, ARToolKit.getInstance().addModel2("Data/models/giantbanana.obj", "single;Data/patt.c;80", DetectionTask.Symbol.C.ordinal(), 20.0f, true));
        deleteModelAtSymbol(DetectionTask.Symbol.C);
        SYMBOLS_HASH_MAP.put(DetectionTask.Symbol.D, ARToolKit.getInstance().addModel2("Data/models/giantbanana.obj", "single;Data/patt.d;80", DetectionTask.Symbol.D.ordinal(), 20.0f, true));
        deleteModelAtSymbol(DetectionTask.Symbol.D);
        SYMBOLS_HASH_MAP.put(DetectionTask.Symbol.F, ARToolKit.getInstance().addModel2("Data/models/giantbanana.obj", "single;Data/patt.f;80", DetectionTask.Symbol.F.ordinal(), 20.0f, true));
        deleteModelAtSymbol(DetectionTask.Symbol.F);
        SYMBOLS_HASH_MAP.put(DetectionTask.Symbol.G, ARToolKit.getInstance().addModel2("Data/models/giantbanana.obj", "single;Data/patt.g;80", DetectionTask.Symbol.G.ordinal(), 20.0f, true));
        deleteModelAtSymbol(DetectionTask.Symbol.G);
        return true;
    }

    /**
     * Puts an {@link Item} on the {@link fr.enseeiht.superjumpingsumokart.application.circuit.Circuit} (Romain Verset 27/02/2017).
     * The item is associated with an ARToolkit marker, the identification is made according to the
     * symbol of the marker.
     * @param item The {@link Item} to put on the circuit.
     * @param symbol The symbol of the marker on which the item is put.
     */
    public void defineModelAtSymbol(Item item, DetectionTask.Symbol symbol) {
        Log.d(ITEM_RENDERER_TAG, "Defined model for symbol : " + symbol.name());
        if (item instanceof Banana) {
            ARToolKit.getInstance().addModel("Data/models/giantbanana.obj", SYMBOLS_HASH_MAP.get(symbol), symbol.ordinal(), 20.0f, true);
        } else if (item instanceof FakeBox) {
            ARToolKit.getInstance().addModel("Data/models/magicbox.obj", SYMBOLS_HASH_MAP.get(symbol), symbol.ordinal(), 1.0f, false);
        }
    }

    /**
     * Deletes an {@link Item} on the {@link fr.enseeiht.superjumpingsumokart.application.circuit.Circuit} (Romain Verset 27/02/2017).
     * @param symbol The symbol on which the item to delete is put on.
     */
    public void deleteModelAtSymbol(DetectionTask.Symbol symbol) {
        Log.d(ITEM_RENDERER_TAG, "Deleted model for symbol : " + symbol.name());
        ARToolKit.getInstance().disableModel(symbol.ordinal());
    }

    @Override
    public void onDrawFrame(GL10 gl) {
        if (ARToolKit.getInstance().getProjectionMatrix() != null) {
            draw(gl);
        }
    }

    @Override
    public void draw(GL10 gl) {
        ARToolKit.getInstance().drawModels();
    }
}
