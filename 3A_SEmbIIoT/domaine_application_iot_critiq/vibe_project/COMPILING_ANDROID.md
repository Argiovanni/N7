# Comment Compiler et Installer l'Application Android

Ce guide explique comment compiler l'application pour générer un fichier `.apk` et comment l'installer sur un smartphone Android.

## Prérequis

1.  **Android Studio :** La méthode la plus simple. Assurez-vous d'avoir installé Android Studio et le SDK Android.
2.  **Ligne de Commande (avancé) :** Avoir le JDK (Java Development Kit) et le SDK Android installés et configurés dans votre PATH.
3.  **Smartphone Android :** Avec le mode développeur et le débogage USB activés.

---

## Méthode 1 : Avec Android Studio (Recommandé)

1.  **Ouvrir le Projet :**
    -   Lancez Android Studio.
    -   Choisissez `Open` et sélectionnez le dossier racine de ce projet (`vibe_project`).
    -   Laissez Gradle synchroniser le projet.

2.  **Compiler l'APK :**
    -   Dans la barre de menu, allez à `Build` -> `Build Bundle(s) / APK(s)` -> `Build APK(s)`.
    -   Une fois la compilation terminée, une notification apparaîtra. Cliquez sur `locate` pour trouver le fichier `app-debug.apk`. Il se trouve généralement dans `app/build/outputs/apk/debug/`.

3.  **Installer sur le Smartphone :**
    -   Connectez votre smartphone à votre ordinateur via USB.
    -   Assurez-vous que le débogage USB est autorisé.
    -   Dans Android Studio, cliquez sur le bouton `Run 'app'` (l'icône de lecture verte ▶️) en ayant votre appareil sélectionné. Android Studio s'occupera de compiler, installer et lancer l'application automatiquement.

---

## Méthode 2 : En Ligne de Commande (avec Makefile)

Nous avons un `Makefile` pour simplifier les opérations de compilation et d'installation.

1.  **Générer les fichiers Gradle Wrapper (si absents) :**
    Si les fichiers `gradlew`, `gradlew.bat` et le dossier `gradle/wrapper` n'existent pas à la racine du projet, vous pouvez les générer en exécutant la commande suivante (nécessite Gradle d'être installé globalement ou via Android Studio) :
    ```bash
    gradle wrapper --gradle-version 8.6
    ```
    Ensuite, assurez-vous que `gradlew` est exécutable :
    ```bash
    chmod +x ./gradlew
    ```

2.  **Utiliser le Makefile :**
    Ouvrez un terminal à la racine du projet.

    -   **Compiler l'APK de débogage :**
        ```bash
        make build
        ```
        Le fichier `app-debug.apk` sera généré dans `app/build/outputs/apk/debug/`.

    -   **Compiler et installer sur un smartphone :**
        Connectez votre smartphone à votre ordinateur via USB et assurez-vous que le débogage USB est activé.
        ```bash
        make install
        ```

    -   **Nettoyer les fichiers de build :**
        ```bash
        make clean
        ```

    -   **Désinstaller l'application du smartphone :**
        ```bash
        make uninstall
        ```

    -   **Afficher l'aide du Makefile :**
        ```bash
        make help
        ```

