package fr.enseeiht.superjumpingsumokart.arpack;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.AsyncTask;
import android.os.SystemClock;

import android.util.Log;

import org.artoolkit.ar.base.ARToolKit;

import java.io.ByteArrayInputStream;

import fr.enseeiht.superjumpingsumokart.application.items.MagicBox;
import fr.enseeiht.superjumpingsumokart.application.items.NullItem;

/**
 * Class that implement several image transformations. It extends {@link AsyncTask} to run heavy computation
 * work outside of the UI {@link Thread}. Once the work is done UI {@link Thread} will update its graphical components.
 * @author Romain Verset, Jorge Enrique Gutierrez.
 */
public class DetectionTask extends AsyncTask<byte[], Void, Boolean> {

    public enum Symbol {HIRO, KANJI, A, B, C, D, F, G}

    /**
     * Logging tag. Useful for debugging.
     */
    private final static String DETECTION_TASK_TAG = "DetectionTask";

    /**
     * The {@link GUIGame} that launches this {@link DetectionTask}.
     */
    private final GUIGame GUI_GAME;

    /**
     * The bitmap created from the bytes stream received from the Jumping Sumo camera.
     */
    private Bitmap bitmapToDisplay;

    // TIMERS VARIABLES
    private static long timeSinceLastHiro;
    private static long timeSinceLastKanji;
    private static long timeSinceLastMinion;
    private static long timeSinceLastPit;
    private static boolean isBananaVisible = false;

    /**
     * Default constructor of {@link DetectionTask} (Romain Verset, Jorge Gutierrez - 08/02/2017).
     *
     * @param guiGame The {@link GUIGame} activity that launches this {@link DetectionTask}.
     */
    DetectionTask(GUIGame guiGame) {
        GUI_GAME = guiGame;
    }

    /**
     * Task performed in background (i.e. not on the UI {@link Thread} for marker detection (Romain Verset, Jorge Gutierrez - 08/02/2017).
     * It converts the bytes from the Jumping Sumo camera stream into a displayable {@link Bitmap}.
     * Finally it runs the marker detection on the NV21 bytes (Android ARToolkit supports only NV21 encoding).
     *
     * @param frames The bytes received from the Jumping Sumo Camera stream.
     * @return True. Useless return statement.
     */
    @Override
    protected Boolean doInBackground(byte[]... frames) {
        long startTime = SystemClock.currentThreadTimeMillis();
        bitmapToDisplay = BitmapFactory.decodeStream(new ByteArrayInputStream(frames[0]));

        // Lancement de la detection des signes poses sur le circuit
        ARToolKit.getInstance().convertAndDetect(getNV21(640, 480, bitmapToDisplay));

        //DECOMMENT TO DISPLAY THE YUV IMAGE (DEBUGGING). Considerably decreases the frame rate.
        /*
        YuvImage yuvImage = new YuvImage(yuvBytes, ImageFormat.NV21, 640, 480, null);
        ByteArrayOutputStream o = new ByteArrayOutputStream(640*480*3/2);
        yuvImage.compressToJpeg(new Rect(0, 0, 640, 480), 100, o);
        bitmapToDisplay = BitmapFactory.decodeStream(new ByteArrayInputStream(o.toByteArray()));
        */


        for (Symbol s : Symbol.values()) {
            if (ItemRenderer.SYMBOLS_HASH_MAP.get(s) != null) {
                int id = ItemRenderer.SYMBOLS_HASH_MAP.get(s);
                if (ARToolKit.getInstance().queryMarkerVisible(id)) {
                    switch (s) {
                        case HIRO:
                            Log.d(DETECTION_TASK_TAG, "Distance to marker HIRO : " + Float.toString(-ARToolKit.getInstance().queryMarkerTransformation(id)[14]));
                            if (-ARToolKit.getInstance().queryMarkerTransformation(id)[14] < 350 && (SystemClock.elapsedRealtime() - timeSinceLastHiro) > 5000) {
                                timeSinceLastHiro = SystemClock.elapsedRealtime();
                                GUI_GAME.arrivalLineDetected();
                                Log.d(DETECTION_TASK_TAG, "Lap validated");
                            }
                            break;
                        case KANJI:
                            Log.d(DETECTION_TASK_TAG, "Distance to marker KANJI : " + Float.toString(-ARToolKit.getInstance().queryMarkerTransformation(id)[14]));
                            if (-ARToolKit.getInstance().queryMarkerTransformation(id)[14] < 350 && (SystemClock.elapsedRealtime() - timeSinceLastKanji) > 3000) {
                                timeSinceLastKanji = SystemClock.elapsedRealtime();
                                GUI_GAME.checkpointDetected();
                                Log.d(DETECTION_TASK_TAG, "Checkpoint validated");

                            }
                            break;
                        case A:
                            Log.d(DETECTION_TASK_TAG, "Distance to marker A : " + Float.toString(-ARToolKit.getInstance().queryMarkerTransformation(id)[14]));
                            if (GUI_GAME.getController().getDrone().getCurrentItem() instanceof NullItem && -ARToolKit.getInstance().queryMarkerTransformation(id)[14] < 250 && (SystemClock.elapsedRealtime() - timeSinceLastMinion) > 5000) {
                                timeSinceLastMinion = SystemClock.elapsedRealtime();
                                new MagicBox(GUI_GAME).applyEffect(GUI_GAME.getController());
                                Log.d(DETECTION_TASK_TAG, "Got a Magic FakeBox");
                            }
                            break;

                        case B:
                            isBananaVisible = true; // ← Marquer que la banane est visible
                            Log.d(DETECTION_TASK_TAG, "Distance to marker BANANA (Pit) : " + Float.toString(-ARToolKit.getInstance().queryMarkerTransformation(id)[14]));
                            if (-ARToolKit.getInstance().queryMarkerTransformation(id)[14] < 350 && (SystemClock.elapsedRealtime() - timeSinceLastPit) > 2000) {
                                timeSinceLastPit = SystemClock.elapsedRealtime();
                                GUI_GAME.getController().onEnterPit();
                                Log.d(DETECTION_TASK_TAG, "Pit detecté, box box");
                            }else{
                                isBananaVisible = false;
                                GUI_GAME.getController().onLeavingPit();
                            }


                        default:
                            Log.d(DETECTION_TASK_TAG, "Distance to marker " + s.name().concat(" ") + Float.toString(-ARToolKit.getInstance().queryMarkerTransformation(id)[14]));
                            if (-ARToolKit.getInstance().queryMarkerTransformation(id)[14] < 300) {
                                GUI_GAME.touchedSymbol(s);
                                Log.d(DETECTION_TASK_TAG, "Touched symbol " + s.name());
                            }
                            GUI_GAME.getController().getDrone().setLastMarkerSeen(s);
                            GUI_GAME.circuitMarkerDetected();
                            break;
                    }
                }
            }
        }
        Log.d(DETECTION_TASK_TAG, "Detection task time : " + Long.toString(SystemClock.currentThreadTimeMillis() - startTime));
        return true;
    }

    /**
     * Tasks performed on the UI {@link Thread} <b>once</b> the {@link #doInBackground(byte[]...)} method is
     * over (Romain Verset - 08/02/2017).
     * @param b Useless parameter.
     */
    @Override
    protected void onPostExecute(Boolean b) {
        GUI_GAME.updateCameraSurfaceView(bitmapToDisplay);
        GUI_GAME.renderAR();
    }



    private byte[] getNV21(int inputWidth, int inputHeight, Bitmap scaled) {
        long startTime = SystemClock.currentThreadTimeMillis();
        int [] argb = new int[inputWidth * inputHeight];

        scaled.getPixels(argb, 0, inputWidth, 0, 0, inputWidth, inputHeight);

        byte [] yuv = new byte[inputWidth*inputHeight*3/2];
        encodeYUV420SP(yuv, argb, inputWidth, inputHeight);
        Log.d(DETECTION_TASK_TAG, "GetNV21 : " + Long.toString((SystemClock.currentThreadTimeMillis() - startTime)));

        return yuv;
    }

    private void encodeYUV420SP(byte[] yuv420sp, int[] argb, int width, int height) {
        final int frameSize = width * height;

        int yIndex = 0;
        int uvIndex = frameSize;

        int R, G, B, Y, U, V;
        int index = 0;
        for (int j = 0; j < height; j++) {
            for (int i = 0; i < width; i++) {

                R = (argb[index] & 0xff0000) >> 16;
                G = (argb[index] & 0xff00) >> 8;
                B = (argb[index] & 0xff);

                // well known RGB to YUV algorithm
                Y = ( (  66 * R + 129 * G +  25 * B + 128) >> 8) +  16;
                U = ( ( -38 * R -  74 * G + 112 * B + 128) >> 8) + 128;
                V = ( ( 112 * R -  94 * G -  18 * B + 128) >> 8) + 128;

                // NV21 has a plane of Y and interleaved planes of VU each sampled by a factor of 2
                //    meaning for every 4 Y pixels there are 1 V and 1 U.  Note the sampling is every other
                //    pixel AND every other scanline.
                yuv420sp[yIndex++] = (byte) ((Y < 0) ? 0 : ((Y > 255) ? 255 : Y));
                if (j % 2 == 0 && index % 2 == 0) {
                    yuv420sp[uvIndex++] = (byte)((V<0) ? 0 : ((V > 255) ? 255 : V));
                    yuv420sp[uvIndex++] = (byte)((U<0) ? 0 : ((U > 255) ? 255 : U));
                }

                index ++;
            }
        }
    }
}
