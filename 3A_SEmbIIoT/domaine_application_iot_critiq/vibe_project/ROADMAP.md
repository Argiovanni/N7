# Roadmap du Projet Find My Friend

Ce document décrit l'architecture cible et les étapes de développement pour construire le réseau maillé Find My Friend. L'approche est itérative, commençant par un socle technique simple pour valider les concepts de base avant de construire les fonctionnalités plus complexes.

## 1. Architecture Cible

L'architecture est pensée en couches logiques, indépendantes les unes des autres.

#### Couche 1 : Couche Physique (BLE)
- **Rôle :** Gérer les interactions matérielles Bluetooth (scan, émission, connexion).
- **Composants :** `Scanner`, `Advertiser`, `Gestionnaire de Connexion (GATT)`.
- **État :** ✅ Scan, Advertising et Connexion GATT stables.

#### Couche 2 : Couche Réseau (Mesh Logic)
- **Rôle :** Gérer la topologie du réseau, le routage des messages et l'identité des nœuds. C'est le cœur du système.
- **Composants :** `Table des Voisins`, `Table de Routage`, `Distance Vector Router`, `Paquet de Données Mesh`.
- **État :** 🔄 Implémentation du routage dynamique (Multi-hop).

#### Couche 3 : Couche Application
- **Rôle :** Fournir les fonctionnalités visibles par l'utilisateur.
- **Composants :** `Service de Messagerie`, `Calculateur de Distance`, `Visualisation Topologique (Graph)`.
- **État :** ✅ Visualisation Graphique fonctionnelle. 🔄 Messagerie en cours.

---

## 2. Plan de Développement

### Phase 1 : Preuve de Concept (PoC) - Connexion & Calcul de Distance
- ✅ **(Fait)** Mettre en place le scan et l'advertising BLE (Optimisé pour Redmi Note 9).
- ✅ **(Fait)** Construire une UI avec Liste et Calcul de distance temps réel.
- ✅ **(Fait)** Implémenter la logique de connexion GATT.

### Phase 2 : Noyau du Réseau Maillé (Routage Dynamique)
- **Objectif :** Permettre à un message de traverser le réseau via un nœud intermédiaire (relais).
- ✅ **(Fait)** Structure du `MeshPacket` et `DistanceVectorRouter` de base.
- ⬜ **(À faire) Synchronisation du Routage :**
    -   Informer le routeur des voisins directs dès le scan BLE.
    -   Échanger les tables de routage via les connexions GATT.
    -   Gérer les métriques de lien (RSSI -> Coût de routage).
- ⬜ **(À faire) Multi-hop :**
    -   Implémenter le transfert automatique des paquets dont nous ne sommes pas le destinataire.

### Phase 3 : Fonctionnalités Applicatives & Visualisation
- **Objectif :** Construire les fonctionnalités finales et visualiser le réseau.
- ✅ **(Fait) Visualisation Topologique (Graph View) :**
    -   Force-Directed Graph avec simulation physique.
    -   Affichage des IDs et des distances relatives.
- ⬜ **(À faire) Messagerie Mesh :**
    -   Envoyer un message à un ID distant.
    -   Affichage des "sauts" (nombre de téléphones entre source et destination).

### Phase 4 : Optimisation, Robustesse et Précision
- **Objectif :** Améliorer l'efficacité et la fiabilité du réseau.
- ⬜ **(À faire) Calibration Multi-terminaux :**
    -   Implémenter un profil de calibration par modèle de smartphone (TX Power et Offset RSSI).
    -   Permettre une calibration manuelle via l'UI (bouton "Je suis à 1m").
- ⬜ **(À faire)** Gérer les déconnexions/reconnexions (auto-réparation des routes).
- ⬜ **(À faire)** Ajouter une couche de sécurité (chiffrement).

## Idées Futures
- [ ] Cartographie précise utilisant des ancres BLE statiques.
- [ ] Partage de fichiers en P2P via le maillage.
