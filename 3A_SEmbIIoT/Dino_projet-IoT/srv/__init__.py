import os
from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_login import LoginManager
from flask_socketio import SocketIO

# Extensions Flask (créées UNE fois)
db = SQLAlchemy()
login_manager = LoginManager()
login_manager.login_view = "main.index"
socketio = SocketIO(async_mode="threading", cors_allowed_origins="*")


def create_app():
    app = Flask(__name__)

    # =========================
    # Configuration
    # =========================
    app.config["SECRET_KEY"] = os.environ.get("FLASK_SECRET_KEY", "dev-secret-key")

    BASEDIR = os.path.abspath(os.path.dirname(__file__))

    app.config["SQLALCHEMY_DATABASE_URI"] = (
        f"sqlite:///{os.path.join(BASEDIR, 'db.sqlite3')}"
    )
    app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False

    # =========================
    # Init extensions
    # =========================
    db.init_app(app)
    login_manager.init_app(app)
    socketio.init_app(app)

    # =========================
    # Blueprints
    # =========================
    from .routes import main

    app.register_blueprint(main)

    # =========================
    # Création DB (proto)
    # =========================
    with app.app_context():
        db.create_all()

    # ==========================================
    # Lancement du thread CAN (Logique dans utils)
    # ==========================================
    from .utils import start_can_thread

    start_can_thread(app)

    return app
