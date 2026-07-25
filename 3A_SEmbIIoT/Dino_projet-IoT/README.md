# D.I.N.O. - Système embarqué d'acquisition et d'analyse de données véhicule

![Status Badge](https://img.shields.io/badge/status-in%20development-yellow)
![Python](https://img.shields.io/badge/Python-3.7+-blue)
![Flask](https://img.shields.io/badge/Flask-2.2.2-green)

## Table des matières

- [Description du projet](#description-du-projet)
- [Architecture générale](#architecture-générale)
- [Composants](#composants)
  - [Arduino - Simulateur CAN](#arduino---simulateur-can)
  - [Raspberry Pi - Serveur web embarqué](#raspberry-pi---serveur-web-embarqué)
  - [Interface web](#interface-web)
- [Installation](#installation)
- [Utilisation](#utilisation)
- [Configuration](#configuration)
- [État du projet](#état-du-projet)
- [Structure du projet](#structure-du-projet)
- [Technologies utilisées](#technologies-utilisées)
- [Troubleshooting](#troubleshooting)

---

## Description du projet

**D.I.N.O.** est un système embarqué innovant conçu pour **acquérir, traiter et visualiser en temps réel les données de conduite d'un véhicule** via le bus CAN (Controller Area Network).

### Objectifs principaux

- 🚗 **Acquisition de données véhicule** : Récupérer les informations du bus CAN (vitesse, régime moteur, température, etc.)
- 📊 **Tableau de bord interactif** : Afficher les données en temps réel sur une interface web responsive
- 🔒 **Authentification utilisateur** : Sécuriser l'accès aux données de conduite
- ☁️ **Architecture IoT** : Système entièrement embarqué sur Raspberry Pi, autonome et sans dépendances externes
- 📡 **Point d'accès Wi-Fi** : Accès à l'application depuis n'importe quel appareil (smartphone, tablette, PC)

---

## Architecture générale

```
                    ┌──────────────────────┐
                    │    Véhicule réel     │
                    │   (bus CAN)          │
                    └──────────┬───────────┘
                               │
                    ┌──────────▼───────────┐
                    │  Raspberry Pi 3B     │
                    │  - Service CAN       │
                    │  - Serveur Flask     │
                    │  - Base de données   │
                    │  - Point d'accès Wi-Fi
                    └──────────┬───────────┘
                               │
                ┌──────────────┼──────────────┐
                │              │              │
        ┌───────▼────────┐  ┌──▼────────┐  ┌─▼─────────┐
        │  Smartphone    │  │  Tablette │  │  Laptop   │
        │  (Web Browser) │  │ (Web App) │  │ (Web App) │
        └────────────────┘  └───────────┘  └───────────┘
```

---

## Composants

### Arduino - Simulateur CAN

**Localisation** : [arduino/](arduino/)

**Objectif** : Simuler le trafic d'un bus CAN réel en générant des trames avec des paramètres véhicule variables.

**Matériel utilisé** :
- 2 cartes Arduino UNO
- Module MCP2515 (contrôleur CAN) × 2
- Câbles de connexion SPI

**Caractéristiques** :
- Simulation des paramètres de conduite :
  - Vitesse (ID 0x1)
  - Régime moteur / RPM (ID 0x2)
  - Température moteur (ID 0x3)
- Communication SPI avec le contrôleur CAN
- Bitrate CAN : 250 kbit/s

**Fichiers** :
- `CAN_TRANSMETTER.ino` : Génère les trames CAN avec données simulées
- `CAN_RECEIVER.ino` : Reçoit et valide les trames CAN
- `README.md` : Documentation technique détaillée

Pour plus d'informations, consultez [arduino/README.md](arduino/README.md).

---

### Raspberry Pi - Serveur web embarqué

**Localisation** : [config_raspi/](config_raspi/)

**Objectif** : Exécuter un serveur web capable de lire le bus CAN et de servir l'interface utilisateur.

**Configuration automatique au démarrage** :

Le système d'exploitation est configuré pour démarrer automatiquement tous les services nécessaires grâce à un fichier service systemd (`dino.service`).

**Processus d'initialisation** (exécuté automatiquement) :

1. Configuration de l'interface CAN (`can0`) - bitrate 250 kbit/s
2. Configuration de la carte réseau Wi-Fi (`wlan0`) - IP 192.168.1.1/24
3. Lancement du mode point d'accès Wi-Fi (hostapd)
4. Démarrage du serveur Flask sur le port 5000

**Fichiers de configuration** :

| Fichier | Localisation | Description |
|---------|-------------|---|
| `dino.service` | `/etc/systemd/system/dino.service` | Service systemd pour l'auto-démarrage |
| `hostapd.conf` | `/etc/hostapd/hostapd.conf` | Configuration du point d'accès Wi-Fi |
| `dnsmasq.conf` | `/etc/dnsmasq.conf` | Configuration DHCP/DNS |
| `start_dino.sh` | `/usr/local/bin/start_dino.sh` | Script d'initialisation |

**Adresse d'accès** :
```
http://192.168.1.1:5000/
```

Pour plus d'informations, consultez [config_raspi/README.md](config_raspi/README.md).

---

### Interface web

**Localisation** : [srv/](srv/)

**Framework** : Python Flask + Flask-SocketIO

**Fonctionnalités** :

#### Pages disponibles

1. **Page d'accueil** (`index.html`)
   - Liste des utilisateurs disponibles
   - Sélection de l'utilisateur pour la connexion
   - Accès rapide au formulaire de création d'utilisateur

2. **Page de connexion** (`login.html`)
   - Authentification basique par sélection d'utilisateur
   - Gestion des sessions utilisateur

3. **Tableau de bord** (`dashboard.html`) - *Protégé par authentification*
   - Affichage en temps réel des données CAN
   - Indicateurs dynamiques :
     - Vitesse
     - Régime moteur (RPM)
     - Température moteur
   - Mise à jour automatique via WebSocket (Flask-SocketIO)

4. **Page de création d'utilisateur** (`new_user.html`)
   - Formulaire de création de nouveaux profils
   - Validation des données

#### Architecture backend

**Modèle de données** :
```
User
├── id (Integer, Primary Key)
├── username (String, Unique)
└── password_hash (String)
```

**Système de communication temps réel** :
- **SocketIO** pour une mise à jour fluide sans rechargement de page
- Les données CAN sont émises vers tous les clients connectés dès leur arrivée
- Format des messages :
  ```json
  {
    "id": "0x1",
    "data": [120],
    "type": "Vitesse",
    "value": 120
  }
  ```

---

## Installation

### Prérequis

- **Raspberry Pi 3B+** (ou compatible) avec Raspbian/Raspberry Pi OS
- Connexion à Internet (pour l'installation initiale)
- Accès root/sudo

### Sur Raspberry Pi

1. **Cloner le projet** :
```bash
git clone <repository-url> /home/dino/Dino
cd /home/dino/Dino
```

2. **Créer un environnement virtuel** :
```bash
python3 -m venv .env
source .env/bin/activate
```

3. **Installer les dépendances Python** :
```bash
pip install -r srv/requirements.txt
```

4. **Copier les fichiers de configuration** :
```bash
# Configuration CAN et Wi-Fi
sudo cp config_raspi/hostapd.conf /etc/hostapd/
sudo cp config_raspi/dnsmasq.conf /etc/dnsmasq.conf
sudo cp config_raspi/start_dino.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/start_dino.sh

# Service systemd
sudo cp config_raspi/dino.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable dino.service
```

5. **Configurer les services** :
```bash
sudo systemctl enable hostapd
sudo systemctl enable dnsmasq
```

6. **Redémarrer la Raspberry Pi** :
```bash
sudo reboot
```

### Sur un ordinateur de développement (test/debug)

1. **Cloner le projet** :
```bash
git clone <repository-url>
cd Dino
```

2. **Créer un environnement virtuel** :
```bash
python3 -m venv venv
source venv/bin/activate  # Linux/Mac
# OU
venv\Scripts\activate  # Windows
```

3. **Installer les dépendances** :
```bash
pip install -r srv/requirements.txt
```

4. **Lancer le serveur** :
```bash
python run.py
```

L'application est disponible à `http://localhost:5000/`

---

## Utilisation

### Accès à l'application

#### Depuis la Raspberry Pi (production)

1. Connecter l'appareil (smartphone, PC, etc.) au réseau Wi-Fi **Dino** ( mot de passe `dinodino` )
2. Ouvrir un navigateur et accéder à : `http://192.168.1.1:5000/`
3. Sélectionner un utilisateur et se connecter 
4. Consulter le tableau de bord en temps réel

#### Depuis un ordinateur (développement)

1. Lancer le serveur : `python run.py`
2. Ouvrir `http://localhost:5000/`

### Workflow utilisateur

```
Index (sélection utilisateur)
        ↓
    Login (authentification)
        ↓
Dashboard (consultation données)
        ↓
    Logout (retour à index)
```

### Créer un nouvel utilisateur

1. Depuis la page d'accueil, cliquer sur "+"
2. Entrer un nom d'utilisateur unique et un mot de passe
3. Cliquer sur "Create"
4. L'utilisateur peut désormais se connecter

---

## Configuration

### Variables d'environnement

Créer un fichier `.env` à la racine du projet  (sinon valeur par défault lu depuis [srv/__init__.py](srv/__init__.py)):

```bash
# Secret key pour Flask (générer une clé forte en production)
export FLASK_SECRET_KEY="votre-clé-secrète-ici"

# Mode debug (à désactiver en production)
export FLASK_ENV="production"
```

### Configuration CAN (Raspberry Pi)

Les paramètres CAN sont définis dans [config_raspi/start_dino.sh](config_raspi/start_dino.sh) :

```bash
# Bitrate : 250 kbit/s (standard automobile)
ip link set dev can0 type can bitrate 250000 loopback off
```

### Configuration Wi-Fi (Raspberry Pi)

Les paramètres Wi-Fi se trouvent dans [config_raspi/hostapd.conf](config_raspi/hostapd.conf) :

```ini
interface=wlan0
ssid=Dino              # Nom du réseau
channel=6             # Canal Wi-Fi
```

---

## État du projet

### ✅ Fonctionnalités complétées

- [x] Communication CAN entre Arduino et Raspberry Pi
- [x] Lecture du bus CAN via interface `can0`
- [x] Serveur Flask avec Blueprint architecture
- [x] Authentification utilisateur (base de données SQLite)
- [x] Page de tableau de bord
- [x] Mise à jour temps réel via SocketIO
- [x] Configuration Wi-Fi en point d'accès
- [x] Service systemd pour auto-démarrage
- [x] Simulation de données CAN (Arduino)

### 🔄 En cours de développement

- [ ] Affichage graphique avancé du tableau de bord (courbes, graphiques)
- [ ] Historique des données de conduite
- [ ] Analyse des comportements de conduite
- [ ] Optimisation des performances
- [ ] Tests sur véhicule réel (OBD2)

### 📋 TODO - Prochaines étapes

- [ ] Intégration réelle sur véhicule (connecteur OBD2)
- [ ] Adaptation des identifiants CAN par constructeur
- [ ] Stockage long terme des données
- [ ] Alertes et notifications
- [ ] Interface mobile réactive (PWA)
- [ ] Documentation utilisateur

---

## Structure du projet

```
Dino/
├── README.md                    # Cette documentation
├── run.py                       # Point d'entrée de l'application
│
├── arduino/                    # Code Arduino (simulation CAN)
│   ├── CAN_RECEIVER.ino        # Lecteur CAN
│   ├── CAN_TRANSMETTER.ino     # Générateur de trafic CAN
│   └── README.md               # Documentation Arduino
│
├── config_raspi/               # Configuration Raspberry Pi
│   ├── dino.service            # Service systemd
│   ├── hostapd.conf            # Configuration Wi-Fi
│   ├── dnsmasq.conf            # Configuration DHCP/DNS
│   ├── start_dino.sh           # Script d'initialisation
│   └── README.md               # Documentation Raspi
│
└── srv/                        # Serveur Flask
    ├── __init__.py             # Initialisation app, extensions
    ├── routes.py               # Routes Flask (Blueprint)
    ├── models.py               # Modèles SQLAlchemy (User)
    ├── forms.py                # Formulaires WTForms
    ├── utils.py                # Utilitaires (SocketIO, CAN)
    ├── requirements.txt        # Dépendances Python
    ├── db.sqlite3              # Base de données SQLite
    │
    ├── static/                 # Fichiers statiques
    │   └── assets/
    │       ├── css/
    │       │   └── style.css   # Feuille de styles
    │       └── js/
    │           ├── dino.js     # Logique JavaScript client
    │           └── socket.io.min.js
    │
    └── templates/              # Templates HTML
        ├── layout/
        │   └── base.html       # Template de base
        ├── index.html          # Page d'accueil
        ├── login.html          # Page de connexion
        ├── new_user.html       # Formulaire création utilisateur
        ├── dashboard.html      # Tableau de bord
        └── state-system.html   # (réservé)
```

---

## Technologies utilisées

### Backend
- **Flask** (2.2.2) : Framework web Python
- **Flask-SocketIO** : WebSocket temps réel
- **Flask-Login** : Gestion des sessions utilisateur
- **Flask-SQLAlchemy** : ORM pour la base de données
- **Flask-WTF** : Gestion des formulaires
- **python-can** (4.6.1) : Lecture du bus CAN
- **Werkzeug** (2.2.2) : Utilitaires sécurité (hashing)

### Frontend
- **HTML5 / CSS3** : Interface utilisateur
- **JavaScript (Vanilla)** : Interactivité client
- **Socket.IO Client** : Communication temps réel

### Système
- **Raspberry Pi OS** : Système d'exploitation embarqué
- **systemd** : Gestion des services
- **hostapd** : Mode point d'accès Wi-Fi
- **dnsmasq** : Serveur DHCP/DNS
- **can-utils** : Utilitaires CAN (optionnel)

### Base de données
- **SQLite3** : Base de données embarquée (léger et autonome)

---

## Troubleshooting

### Logs et debug

**Logs du service systemd** :
```bash
sudo journalctl -u dino.service -f
```

**Logs Flask en mode debug** :
```bash
FLASK_ENV=development python run.py
```

**Monitoring du bus CAN** :
```bash
# Afficher tout le trafic CAN
candump can0

# Afficher les statistiques
ip -s link show can0
```

---


## Auteurs et remerciements

Projet de 3A SN - Spécialité Systèmes Embarqués et IoT Industriel

*Bernard Emilie, 
Bongiovanni Arthur, 
Canillac Leilie, 
Vanicotte--Hochman Alexandre, 
Withanage Perera Sakun*

---

## Support

Pour toute question ou problème :
- 📧 Consultez la documentation de chaque composant
- 🔍 Vérifiez les fichiers README spécifiques
- 🐛 Ouvrez une issue sur le dépôt Git

---

**Dernière mise à jour** : 19 janvier 2026

