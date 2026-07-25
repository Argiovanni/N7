# Code for web server running on raspi 3B

[TOC]

## Rapport d’avancement (19/12)

### 1. Contexte

Dans le cadre du projet D.I.N.O., une des composantes principales consiste à développer un **serveur web embarqué** exécuté sur une **Raspberry Pi connectée au véhicule**.
Ce serveur a pour objectif de fournir une interface utilisateur accessible depuis un écran embarqué ou un terminal externe (smartphone, tablette) connecté en Wi-Fi à la carte.

---

### 2. État actuel de l’implémentation

À ce stade du projet, les fonctionnalités suivantes ont été mises en place :

#### 2.1 Serveur web

* Le serveur web est développé en **Python** à l’aide du framework **Flask**.
* L’architecture du projet est modulaire (routes, templates, modèles, formulaires), facilitant l’évolutivité et la maintenance.
* Le serveur est conçu pour être exécuté directement sur la **Raspberry Pi 3B** embarquée dans le véhicule, mais n'a pour l'instant été testé que sur nos ordinateurs.

#### 2.2 Gestion des utilisateurs et authentification

* Une **page de connexion fonctionnelle** a été implémentée.
* Le système d’authentification repose sur **Flask-Login**.
* Les utilisateurs sont stockés dans une **base de données SQLite3**, adaptée à un système embarqué léger.
* La sélection d’un utilisateur se fait via une interface visuel et simple.
* Une fois authentifié, l’utilisateur est maintenu en session.

#### 2.3 Accès au tableau de bord

* Une **page de dashboard** est accessible uniquement après authentification.
* Cette page constitue le point d’entrée principal de l’interface utilisateur.
* Elle est destinée à afficher les informations liées à la conduite et à l’état du véhicule.

---

### 3. Travaux restant à réaliser

Plusieurs éléments restent à implémenter pour compléter cette partie du projet :

* **Conception graphique du tableau de bord**
  Le design du dashboard doit être défini afin d’afficher les informations de manière claire, ergonomique et adaptée à une utilisation embarquée (écran ou mobile).

* **Récupération des données du bus CAN**
  Les données du véhicule (vitesse, régime moteur, consommation, etc.) devront être récupérées via le **bus CAN**, en lien avec une autre partie du projet dédiée à l’acquisition des données OBD2.

* **Stockage et exploitation des données**
  Il est prévu de :

  * sauvegarder les données de conduite en base de données,
  * permettre l’affichage de **courbes d’évolution** (ex. vitesse, régime moteur, consommation),
  * offrir à l’utilisateur une visualisation de son comportement de conduite dans le temps.

---

### 4. Conclusion

La partie serveur web embarqué est aujourd’hui **fonctionnelle dans ses fondations** : serveur Flask opérationnel, authentification utilisateur en place et accès sécurisé à un dashboard.
Les prochaines étapes consisteront à enrichir cette base avec l’acquisition des données véhicule, leur visualisation en temps réel et leur exploitation sur le long terme.


## Rapport d’avancement (19/01)

À ce stade du projet, l’application D.I.N.O. a évolué afin d’intégrer la lecture et l’exploitation de données issues du bus CAN, ainsi que leur diffusion en temps réel vers l’interface utilisateur.

Un utilisateur correctement authentifié peut désormais accéder à des données véhicule provenant du bus CAN via l’interface web.
Les identifiants des trames CAN dépendant fortement du constructeur et du modèle du véhicule, et compte tenu des contraintes matérielles liées à un branchement direct sur un véhicule réel, une simulation de trafic CAN a été mise en place.

Cette simulation est réalisée à l’aide d’une carte Arduino, qui génère un trafic CAN artificiel permettant de faire varier dynamiquement plusieurs paramètres représentatifs de l’état du véhicule, notamment :

* la vitesse,
* le régime moteur,
* la température moteur.

Les trames CAN simulées sont transmises sur le bus, puis lues par la Raspberry Pi via l’interface `can0`.

### Mise à jour temps réel via Flask-SocketIO

Afin d’assurer une mise à jour fluide et réactive des données affichées, l’application Flask s’appuie désormais sur Flask-SocketIO.

Ce mécanisme permet :

* l’établissement d’une connexion persistante entre le serveur et le client web,
* l’envoi des nouvelles valeurs dès leur réception, sans rechargement de page,
* une actualisation en temps réel du tableau de bord côté client.

Concrètement, les données acquises depuis le bus CAN sont traitées côté serveur puis émises sous forme d’événements SocketIO vers les clients connectés.
Le tableau de bord met ainsi à jour dynamiquement les indicateurs (vitesse, régime moteur, température moteur) dès qu’une nouvelle trame est reçue.

Cette approche est particulièrement adaptée à un contexte embarqué et IoT, où la réactivité et la faible latence sont essentielles pour l’affichage d’informations de conduite.
