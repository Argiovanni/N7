# Rapport de Synthèse Technique - Projet Find My Friend
## État d'avancement - Janvier 2026

### 1. Synthèse du Travail Accompli
Le projet a franchi les étapes critiques de la mise en place d'un **réseau maillé décentralisé** sur smartphones Android. Nous disposons désormais d'un socle technique capable de fonctionner sans aucune infrastructure (ni Wi-Fi, ni 4G/5G).

#### Réalisations Techniques Clés :
*   **Couche Physique (BLE) robuste** : Implémentation d'une stratégie d'advertising et de scan optimisée pour les terminaux à ressources limitées (ex: Redmi Note 9). Utilisation de modes équilibrés pour garantir la stabilité du signal.
*   **Auto-organisation** : Les nœuds du réseau initient des connexions GATT automatiques dès la découverte de voisins "Find My Friend", créant un maillage spontané sans intervention utilisateur.
*   **Routage Link-State (État de Lien)** : Passage d'un routage par vecteur de distance à une approche Link-State. Chaque nœud diffuse désormais ses liens locaux, permettant à l'ensemble du réseau de construire une carte topologique identique et complète.
*   **Visualisation Temps Réel** : Développement d'un composant de visualisation graphique utilisant une simulation physique (Force-Directed Graph). Les distances estimées via RSSI servent de contraintes pour dessiner une carte relative du réseau.

---

### 2. Limitations Identifiées

#### A. Précision et Stabilité du RSSI
L'estimation de distance basée sur le RSSI reste soumise aux aléas de l'environnement (réflexions, obstacles humains). Bien que le lissage par moyenne des signaux forts améliore la stabilité, la précision reste indicative (ordre de grandeur) plutôt que métrique.

#### B. Absence de Directionnalité (Vectoring)
Le système actuel sait "à quelle distance" se trouve un nœud, mais pas "dans quelle direction". Sur le graphe, cela se traduit par une topologie qui peut pivoter librement. L'absence d'ancres fixes (nœuds dont la position géographique est connue) empêche la superposition sur une carte réelle.

#### C. Hétérogénéité Matérielle et Calibration
L'une des découvertes majeures de cette phase est l'écart de performance entre les modèles de smartphones. Un signal mesuré à -60dBm peut correspondre à des distances physiques très différentes selon l'antenne du téléphone. Pour obtenir une topologie précise, le système devra intégrer une étape de **calibration** (profils par modèle ou procédure d'étalonnage manuel à 1 mètre).

#### D. Consommation Énergétique
Le maintien de connexions GATT actives...

---

### 3. Perspectives d'Amélioration et R&D

#### A. Fusion Capteurs (IMU & Magnétomètre)
L'intégration des données du **gyroscope** et de la **boussole** est la prochaine étape majeure. En corrélant le mouvement du téléphone de l'utilisateur avec les variations de puissance du signal reçu, il est mathématiquement possible d'estimer l'angle (azimut) des voisins et ainsi fixer l'orientation du graphe.

#### B. Optimisation de la Puissance
Mise en place de cycles de sommeil coordonnés entre les nœuds pour réduire la fenêtre de scan une fois que la topologie est stable, tout en conservant une réactivité suffisante pour détecter de nouveaux entrants.

#### C. Messagerie et Payload Multi-sauts
Exploiter la table de routage Link-State pour acheminer des paquets de données (texte, alertes) à travers plusieurs intermédiaires, validant ainsi la fonction de "relais" du réseau maillé.

