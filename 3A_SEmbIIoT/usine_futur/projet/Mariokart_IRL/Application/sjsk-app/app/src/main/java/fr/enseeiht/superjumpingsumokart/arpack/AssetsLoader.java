package fr.enseeiht.superjumpingsumokart.arpack;

import android.app.Application;

import org.artoolkit.ar.base.assets.AssetHelper;

/**
 * Assets loader to enable the access to ressource for native code.
 * @author JorgeEnrique.
 */

public class AssetsLoader extends Application {

    /**
     * Singleton instance of {@link Application}.
     */
    private Application sInstance;

    // Anywhere in the application where an instance is required, this method
    // can be used to retrieve it.

    /**
     * @return The singleton instance of {@link AssetsLoader}.
     */
    public Application getInstance() {
        return sInstance;
    }

    @Override
    public void onCreate() {
        super.onCreate();
        sInstance = this;
        ((AssetsLoader) sInstance).initializeInstance();
    }

    // Here we do one-off initialisation which should apply to all activities
    // in the application.
    protected void initializeInstance() {
        // Unpack assets to cache directory so native library can read them.
        // N.B.: If contents of assets folder changes, be sure to increment the
        // versionCode integer in the AndroidManifest.xml file.
        AssetHelper assetHelper = new AssetHelper(getAssets());
        assetHelper.cacheAssetFolder(getInstance(), "Data");
    }
}
