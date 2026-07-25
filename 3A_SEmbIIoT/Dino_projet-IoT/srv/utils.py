import can
import time
import random
import threading
from . import socketio  # Import de l'instance créée dans __init__.py

#for debug
@socketio.on('connect')
def handle_connect():
    print("Client connecté")


@socketio.on('disconnect')
def handle_disconnect():
    print("Client déconnecté")


def can_reader_thread(app):
    """Boucle de lecture du bus CAN."""
    try:
        # Configuration du bus (à adapter selon les branchements)
        bus = can.interface.Bus(channel="can0", bustype="socketcan")
    except Exception as e:
        print(f"Erreur CAN: {e}")
        return

    while True:
        msg = bus.recv(1.0)
        if msg:
            #print("[DEBUG] : ", msg) # for debug
            # --- Logique de parsing ---
            data_to_send = {"id": hex(msg.arbitration_id), "data": list(msg.data)}
            #print(data_to_send)
            # Exemple de décodage spécifique (id à modifié en fonction des trafic qu'on veut récup)
            if msg.arbitration_id == 0x1:
                data_to_send["type"] = "Vitesse"
                data_to_send["value"] = msg.data[0]
            elif msg.arbitration_id == 0x2:
                data_to_send["type"] = "RPM"
                data_to_send["value"] = msg.data[0]
            elif msg.arbitration_id == 0x3:
                data_to_send["type"] = "Temp"
                data_to_send["value"] = msg.data[0]

            # Envoi au Dashboard via SocketIO
            socketio.emit("can_update", data_to_send)


def start_can_thread(app):
    """Lance le thread en mode 'daemon' pour qu'il s'arrête avec le serveur."""
    # thread = threading.Thread(target=can_reader_thread, args=(app,))
    # thread.daemon = True
    # thread.start()
    socketio.start_background_task(can_reader_thread,app)


