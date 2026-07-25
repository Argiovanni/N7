# index des machines dans la matrice d'adjacence :
# 0 -> CA1
# 1 -> CA2
# 2 -> CA3
# 3 -> CTS1
# 4 -> CTS2
# nombres = nombre d'appels max par lien
LINKS_CAP = [
    0, 10, 0, 100, 100,
    10, 0, 10, 100, 100,
    0, 10, 0, 100, 100,
    100, 100, 100, 0, 1000,
    100, 100, 100, 1000, 0]
    
NBR_OF_MACHINES = 5

CA_INDEX = [0,1,2] # indice des CA

CA_NUMBER = 3

SIMULATION_END_TIME = 3600 # simulation sur 1h

CALLS_NUMBER = 6000 # Nombre d'appel de la simulation

def get_call_nbr():
    return CALLS_NUMBER


def set_call_nbr(val):
    global CALLS_NUMBER
    CALLS_NUMBER = val

REPET_NUMBER = 10 # Nombre de répétition de la simulation pour faire des moyenne
