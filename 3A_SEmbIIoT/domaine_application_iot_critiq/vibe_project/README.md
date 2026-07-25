# Find My Friend - Mesh Network PoC

Un réseau maillé pair-à-pair décentralisé utilisant exclusivement des smartphones Android connectés via Bluetooth Low Energy (BLE).

## Fonctionnalités Actuelles
- **Découverte Automatique** : Les smartphones s'identifient via BLE Advertising.
- **Réseau Auto-organisé** : Connexions GATT automatiques entre voisins (limite de 7 liens par nœud).
- **Routage Link-State** : Chaque nœud diffuse ses liens locaux, permettant à tous de connaître la topologie complète.
- **Visualisation Topologique** : Vue en temps réel (Force-Directed Graph) montrant les liens directs (rouges) et indirects (oranges).
- **Estimation de Distance** : Calcul par lissage RSSI (moyenne des signaux les plus forts).

## Installation Rapide
1. Connectez vos smartphones via USB.
2. Assurez-vous que `adb` est dans votre PATH.
3. Lancez l'installation groupée :
   ```bash
   make install
   ```

## Architecture
- `app/` : Interface Android (Jetpack Compose) et Service BLE.
- `mesh-core/` : Logique de routage pure Kotlin (Link-State).
- `Makefile` : Automatisation du build et du déploiement multi-appareils.
