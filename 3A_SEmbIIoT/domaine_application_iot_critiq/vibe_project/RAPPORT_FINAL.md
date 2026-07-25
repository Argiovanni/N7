# Rapport Final de Projet - Find My Friend

## Introduction
Ce rapport présente les résultats finaux du projet "Find My Friend", un réseau maillé décentralisé basé sur le Bluetooth Low Energy (BLE) pour smartphones Android. L'objectif était de créer une infrastructure de communication sans dépendance à un serveur central ou au Wi-Fi.

## Synthèse du Travail Accompli
Le projet a franchi les étapes critiques de la mise en place d'un **réseau maillé décentralisé** sur smartphones Android. Nous disposons désormais d'un socle technique capable de fonctionner sans aucune infrastructure (ni Wi-Fi, ni 4G/5G).

### Réalisations Techniques Clés :
*   **Couche Physique (BLE) robuste** : Implémentation d'une stratégie d'advertising et de scan optimisée pour les terminaux à ressources limitées. Utilisation de modes équilibrés pour garantir la stabilité du signal.
*   **Auto-organisation** : Les nœuds du réseau initient des connexions GATT automatiques dès la découverte de voisins, créant un maillage spontané sans intervention utilisateur.
*   **Routage Link-State (État de Lien)** : Implémentation d'un algorithme où chaque nœud diffuse ses liens locaux, permettant à l'ensemble du réseau de construire une carte topologique identique et complète.
*   **Visualisation Temps Réel** : Développement d'un composant de visualisation graphique utilisant une simulation physique (Force-Directed Graph). Les distances estimées via RSSI servent de contraintes pour dessiner une carte relative du réseau.

## Workflow de Développement & "Vibe Coding"

Le développement de ce projet a suivi une approche moderne assistée par IA, utilisant le **Gemini CLI** comme partenaire de programmation. Ce workflow, souvent appelé "Vibe Coding", se caractérise par une itération rapide entre l'expression des besoins en langage naturel et l'implémentation technique automatisée.

### Méthodologie d'interaction avec l'IA
1. **Expression du besoin** : Description de la fonctionnalité ou du bug en langage naturel.
2. **Analyse de contexte** : L'IA explore le codebase pour comprendre les dépendances, l'architecture (ex: module `mesh-core` vs `app`) et les conventions de nommage.
3. **Génération & Application** : L'IA propose et applique directement les modifications dans les fichiers Kotlin ou les fichiers de configuration Gradle.
4. **Vérification** : Tests unitaires dans `mesh-core` et déploiement sur terminaux réels via le `Makefile`.

### Exemples de Prompts Structurants

#### 1. Transition vers le Routage Link-State
> *"Nous devons passer d'un simple flooding à un routage Link-State. Crée une classe `LinkStateRouter` qui maintient une table de voisinage. Chaque fois qu'un voisin est ajouté ou perdu, diffuse un paquet `LSA` (Link State Advertisement) à tous les autres nœuds. Assure-toi que les paquets ont un numéro de séquence pour éviter les boucles infinies."*

#### 2. Visualisation de la Topologie
> *"Ajoute un écran `TopologyView` utilisant Canvas dans Jetpack Compose. Utilise une simulation de forces pour positionner les nœuds : les nœuds se repoussent, mais les liens BLE agissent comme des ressorts dont la force dépend du RSSI."*

#### 3. Stabilisation des données (Lissage RSSI)
> *"Le RSSI est trop instable pour la visualisation. Crée un utilitaire dans `AndroidMeshNetwork` pour calculer la moyenne mobile des 10 derniers échantillons de RSSI pour chaque lien avant de mettre à jour le ViewModel."*

#### 4. Automatisation multi-appareils
> *"Modifie le Makefile pour que `make install` détecte tous les appareils connectés via ADB et installe l'application sur tous en parallèle. Ajoute également une cible `make clean-logs` pour vider les buffers logcat de tous les téléphones."*

## Limitations et Défis Techniques
*   **Précision du RSSI** : Très sensible à l'environnement et aux obstacles physiques.
*   **Hétérogénéité matérielle** : Les antennes BLE varient d'un modèle à l'autre, nécessitant une calibration spécifique.
*   **Consommation batterie** : Le scan permanent et les connexions GATT maintenues sont énergivores.

## Perspectives
*   **Fusion de capteurs** : Utilisation de la boussole et de l'accéléromètre pour orienter le graphe de topologie.
*   **Messagerie Multi-sauts** : Implémentation d'une couche de transport pour envoyer des messages texte à un nœud non-voisin via des relais.

## Résultats et Démonstrations
Le système est capable de maintenir un réseau stable entre 3 et 5 appareils, avec une mise à jour de la topologie globale en moins de 2 secondes lors de l'ajout ou du retrait d'un nœud.

### Livrable (APK)
L'application compilée est disponible pour test à l'emplacement suivant :
- **APK Debug** : `app/build/outputs/apk/debug/app-debug.apk`

*Note : Pour installer l'APK sur un appareil connecté, vous pouvez utiliser la commande `make install` à la racine du projet.*

## Conclusion
L'utilisation de l'IA (Gemini CLI) a radicalement transformé le workflow de développement. En déléguant les tâches répétitives et l'implémentation de base à l'IA, nous avons pu nous concentrer sur la résolution des problèmes complexes de routage et de physique du signal, accélérant le cycle de développement par un facteur estimé à 3x.