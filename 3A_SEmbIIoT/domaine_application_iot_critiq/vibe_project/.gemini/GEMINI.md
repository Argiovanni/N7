# Vision du Projet Find My Friend

## Objectif Principal

Créer un **réseau maillé (mesh network) en pair-à-pair (peer-to-peer) utilisant exclusivement des smartphones** connectés via **Bluetooth Low Energy (BLE)**.

## Principes Clés

1.  **Décentralisation :** Le réseau ne dépend d'aucun serveur central ou point d'accès Wi-Fi. Les smartphones communiquent directement entre eux.
2.  **Exclusivité Smartphone :** L'écosystème est conçu uniquement pour les appareils mobiles (Android dans un premier temps).
3.  **Réseau Maillé :** Chaque smartphone agit comme un nœud capable de recevoir, d'envoyer et de relayer des informations pour les autres nœuds. Si un appareil n'est pas à portée directe d'un autre, leur message peut transiter par des appareils intermédiaires.
4.  **Robustesse :** Le réseau peut se reconfigurer dynamiquement si des appareils le rejoignent ou le quittent.

## Fonctionnalité Additionnelle

-   **Estimation de la Distance :** L'application intègrera une fonctionnalité pour calculer la distance approximative entre deux appareils connectés en se basant sur la force du signal BLE (RSSI - Received Signal Strength Indication).

## Cas d'Usage Potentiels

-   Applications de communication dans des zones sans réseau (festivals, randonnées).
-   Jeux interactifs basés sur la proximité.
-   Systèmes de détection et d'alerte décentralisés.

## Plan de Développement

La vision de ce projet est découpée en étapes techniques et en phases de développement claires. Pour une vue détaillée de l'architecture cible et du plan de développement, veuillez consulter notre [**ROADMAP.md**](../ROADMAP.md).
