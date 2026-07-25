GroundSDK = new version
https://mvnrepository.com/artifact/com.parrot.drone

Trace de la vieille version sur Maven : 3.14.0 de 2018
https://mvnrepository.com/artifact/com.parrot/arsdk

ARSDK - github : generateur de la librairie qui etait sur maven (parrot.arsdk) via un projet Android: marche pas.
https://github.com/Parrot-Developers/ARSDK3

ARSDK : build des libraries : ARSDK3_version_3_7_5 (18.11.2015 ... semble un peu ancien).
https://github.com/Parrot-Developers/ARSDKBuildUtils/releases
https://github.com/Parrot-Developers/ARSDKBuildUtils

## Build ARSDK : 
- Doc :

http://web.archive.org/web/20220321195346/http://developer.parrot.com/docs/bebop

- Source

https://github.com/Parrot-Developers/arsdk_manifests

- Code Samples in Unix / Android / iOS

https://github.com/Parrot-Developers/SamplesJumpingSumoSample

---

## Mes étapes pour le Build du SDK : ARSDK_KJR 

cf. [ARDroneSDK3 API Reference.html](assets/ARDroneSDK3%20API%20Reference.html)


### Download all sources using `repo`

Créer un répertoire où on installe les sources. On le nomme dans la suite <SDK>. Le chemin absolu de ce répertoire NE DOIT PAS contenir d'espace.

`cd <SDK>`
`brew install repo`

SDK sources are hosted on [github](https://github.com/Parrot-Developers/). To download them, you only have to init repo with the arsdk_manifests url:
`repo init -u https://github.com/Parrot-Developers/arsdk_manifests.git`

After that, you can download all the other repository automatically by executing the command:
`repo sync`

Then follow the How to build the SDK section.

__> IMPORTANT__  Change alchemy package in `build/alchemy` with this newer one :

    https://github.com/Parrot-Developers/alchemy/tree/master


### setup variables and dependencies

On travaille avec : 
- MIN SDK = 19
- Target SDK = 25

1. Variable d'environnement ANDROID_SDK_PATH 
`export ANDROID_SDK_PATH=/Users/kjaffres/Library/Android/sdk`

2. Installation du NDK et de cmake via AndroidStudio
https://developer.android.com/studio/projects/install-ndk

3. Var d'env ANDROID_NDK_PATH
`export ANDROID_NDK_PATH=/Users/kjaffres/Library/Android/sdk/ndk/19.2.5345600`
=> Testing NDK 20 : Android Q (10) API support
https://developer.android.com/ndk/downloads/revision_history
`export ANDROID_NDK_PATH=/Users/kjaffres/Library/Android/sdk/ndk/20.0.5594570`

4. dependences avec brew

Ce qui donne: 

`brew install git autoconf libtool mplayer libncurses5-dev libdvdnav`
`brew install avahi`
`brew install ffmpeg`

### Compilation du SDK pour Android. 

On créé pour deux seules architectures __`armeabi-v7a` et `arm64-v8a`__ 

    if dragon.VARIANT == "android":
        android_abis = ["armeabi-v7a", "arm64-v8a"]
    
__COMMMANDE__ 

    ./build.sh -p arsdk-android -t build-jni -v
    
__Attention__, il faut changer dans `products/arsdk/android/config/product.mk`. passage de 14 à 19 pour etre compatible avec une version moins vielle du NDK. les scripts Alchemy ne peuvent gérer qu'un NDK entre 18 et 20.

    TARGET_ANDROID_APILEVEL := 19

Dans le meme fichier : suppression `armeabi` car pb de compatibilité avec Alchemy
    
    #ifeq ("$(ANDROID_ABI)","armeabi")
    #  TARGET_ARCH := arm
    #else 

__Attention (BUGs)__ : Dans packages/libARStream2 : 
- arstream2_rtp.h : supprimer la redéfinition du type `mmsghdr` ligne 39 (re-def de socket.h)
- Ajouter #include <sys/select.h> dans arstream2_rtp_sender.h et dans _receiver.h
- https://visp-doc.inria.fr/doxygen/visp-3.6.0/tutorial-bebop2-vs.html quand on ne trouve pas Python : you may edit $VISP_WS/3rdparty/ARDroneSDK3/out/arsdk-native/staging-host/usr/lib/mavgen/pymavlink/generator/mavcrc.py and modify accumulate_str() replacing
```
def accumulate_str(self, buf):
    '''add in some more bytes'''
    accum = self.crc
    import array
    bytes = array.array('B')
    bytes.fromstring(buf)
    self.accumulate(bytes)
``` 
by
```
def accumulate_str(self, buf):
    '''add in some more bytes'''
    accum = self.crc
    import array
    bytes_array = array.array('B')
    try:  # if buf is bytes
        bytes_array.frombytes(buf)
    except TypeError:  # if buf is str
        bytes_array.frombytes(buf.encode())
    except AttributeError:  # Python < 3.2
        bytes_array.fromstring(buf)
    self.accumulate(bytes_array)
```

The output will be in `<SDK>/out/arsdk-android/ARCH/staging/usr/`
avec <SDK> le répertoire où on travaille (on a chargé les sources)

## Integration à un projet AndroidStudio

### Creation des archives .aar pour chaque module 

Pour cela, on utilise le projet AndroidStudio qui se nomme ARSDK3. Il se trouve dans `<SDK>/packages/ARSD3`

Ce projet génère dans `out/arsdk-android/gradle`, pour chaque librairie (libARCommands, libARController ... ) un .aar que l'on trouve dans 

`out/arsdk-android/gradle/libARCommands/outputs/aar/`

### Ajout des librairies au projet sjsk

On cree un répertoire arsdk à la racine (meme niveau que app)
On y copie les répertoires générés dans `out/arsdk-android/gradle`
Dans chaque répertoire, on ajoute un build.gradle de la forme :

```
configurations.maybeCreate("default")
artifacts.add("default", file('outputs/aar/libARCommands-release.aar'))
```

mariokart-2024 utilise cette façon de faire : on crée autant de aar que de sous-projets dans ARSDK, et on inclut chaque bibliothèque comme fait pour aRBaseLib. 
=> Pb, le compilo n'arrive pas à trouver ARSDK.java dans le projet arsdk. Et c'est celui qui charge les bibliothèques JNI qui se trouvent dans out/arsdk-android/jni/arsdk/libs pour les architectures cibles (arm64 et armeabi)


### Autre version : on utilse les gradle du projet Android `<SDK>/packages/Sample/Android` 

cf. mariokart-25 folder qui contient à la fois le projet Android `sjsk-app` et le sdk (`arsdk-kjr`). 
Les 

- Bug : 

> The application could not be installed: INSTALL_FAILED_NO_MATCHING_ABIS Installation failed due to: 'Error code: 'INSTALL_FAILED_NO_MATCHING_ABIS', message='INSTALL_FAILED_NO_MATCHING_ABIS: INSTALL_FAILED_NO_MATCHING_ABIS: Failed to extract native libraries, res=-113'' List of apks: [0] '/Users/kjaffres/Documents/MarioKart/mariokart-25/arsdk-kjr/out/arsdk-android/gradle/app/intermediates/apk/debug/app-debug.apk'

Add a filter on the architectures I have built the SDK for : 
```
android {
    defaultConfig {
        ndk {
            abiFilters 'arm64-v8a', 'armeabi-v7a'
        }
    }
}
```


=> Cette solution a permis de construire une version qui compile. 
L'applicaiton se déploie, mais : 
- L'execution plante : on attend de binder au service : ARDiscoveryService qui permet de récupérer la connexion wifi vers le drone. 


=> Ce que j'ai testé 

Changer les compilations des librairies 
- Changer le NDK (passer de la version 19 à version 20 car elle supporte Android 10 (Q))
- Changer le SDK_MIN : 19 et 21 testés (pas de clang pour 20)
3 variantes existent : 
mariokart-25/arsdk-kjr-NDK19-MIN_SDK_19
mariokart-25/arsdk-kjr-NDK19-MIN_SDK_21
mariokart-25/arsdk-kjr-NDK20-MIN_SDK_21

Ces repertoires sont au même niveau que le répertoire du projet android 
mariokart-25/sjsj-app

Pour s'adapter au changement de min_SDK, il faut modifier les répertoires dans settings.gradle, build.gradle(projet sjsk-app) pour prendre le bon MIN_SDK / NDK
Et changer le minSdkVersion dans build.graddle(:app) et build.graddle(Projet sjsk-app) dans ext