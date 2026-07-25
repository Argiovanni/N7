# Guide d'Installation et Déploiement

## Pré-requis
- Android SDK (platform-tools pour `adb`).
- Java 17+.
- Au moins deux smartphones Android (API 26+).

## Déploiement de Test
Le projet est optimisé pour tester sur plusieurs appareils simultanément.

### Installation sur tous les téléphones
```bash
make install
```
Cette commande compile l'APK et l'installe en parallèle sur tous les appareils connectés détectés par `adb`.

### Monitoring des logs
Pour voir le maillage se construire en temps réel :
```bash
adb logcat -v time | grep -E "AndroidMeshNetwork|BleService|DistanceVectorRouter"
```

## Permissions requises
L'application demandera à l'exécution :
- Bluetooth Scan & Advertise.
- Localisation (Fine Location) : **Indispensable** pour le scan BLE sur Android.
- Bluetooth Connect.