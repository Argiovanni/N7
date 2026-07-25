import random
from typing import Optional
from Call import Call_impl
from Timeline import Timeline_impl
from Event import EventStartCall
from Routing import HierarchicalRouting, AdaptiveRouting, ShareLoadRouting
import networkx as nx
import matplotlib.pyplot as plt
import matplotlib.cm as cm
from enum import Enum
from constant import get_call_nbr,set_call_nbr,SIMULATION_END_TIME,CA_INDEX


class RoutingAlgorithmType(Enum):
    HIERARCHICAL = 1
    SHARELOAD = 2
    ADAPTATIV = 3

def configure_routing(type, network):
    """
    Configure et retourne un algorithme de routage en fonction du type spécifié.
    @param routing_type : Type d'algorithme de routage (Enum).
    @param network : Instance du réseau.
    @return : Instance de l'algorithme de routage.
    """
    if type == RoutingAlgorithmType.HIERARCHICAL:
        return HierarchicalRouting(network)
    elif type == RoutingAlgorithmType.SHARELOAD:
        return ShareLoadRouting(network)
    elif type == RoutingAlgorithmType.ADAPTATIV:
        return AdaptiveRouting(network)
    else:
        raise (NotImplementedError, "This Routing algorithm hasn't been implemented yet")


def random_timestamp(end_time: Optional[int] = SIMULATION_END_TIME):
    """
    Génère un timestamp aléatoire compris entre 0 et end_time.
    @param end_time : Fin de la simulation (par défaut, SIMULATION_END_TIME).
    @return : Timestamp aléatoire.
    """
    return random.randint(0, end_time)


def random_call(routing):
    """
    Génère un appel aléatoire entre deux machines avec des paramètres donnés.
    @param routing : Algorithme de routage utilisé.
    @return : Instance de Call_impl.
    """
    # On appel se fait obligatoirement entre deux CA d'indices différents
    source,dest = random.sample(CA_INDEX, 2)
    return Call_impl(source=source,
                dest=dest,
                start=random_timestamp(),
                duration=random.randint(1 * 60, 5 * 60), #un appel fait entre 1 et 5 min
                routing=routing,
                )


def initialise_timeline(routing):
    """
    Initialise la timeline avec un certain nombre donné d'appels aléatoires.
    @param routing : Algorithme de routage utilisé.
    @return : Instance de Timeline remplie d'événements.
    """
    timeline = Timeline_impl()
    # genère CALLS_NUMBER appel et les ajoute dans la timeline
    for _ in range(get_call_nbr()):
        call = random_call(routing)
        EventStartCall(call, timeline)
    return timeline
    
    
def render_usage(tab_usage, ax):
    """
    Visualise l'utilisation des liens sous forme de graphe.
    @param tab_usage : Tableau contenant les données d'utilisation des liens.
    @param ax : Axes de la figure matplotlib.
    """
    # Création du graphe dirigé
    G = nx.DiGraph()
    edgelist = [
        ('CA1', 'CA2'), ('CA1', 'CTS1'), ('CA1', 'CTS2'),
        ('CA2', 'CA3'), ('CA2', 'CTS1'), ('CA2', 'CTS2'),
        ('CA3', 'CTS1'), ('CA3', 'CTS2'),
        ('CTS1', 'CTS2')
    ]
    G.add_edges_from(edgelist)

    # Positionnement des noeuds
    pos = {
        'CTS1': [-1, 2],
        'CTS2': [1, 2],
        'CA1': [-2, -2],
        'CA2': [0, -2],
        'CA3': [2, -2],
    }
    # Configuration des couleurs des arêtes en fonction de l'utilisation
    colors = [
        tab_usage[0][1], tab_usage[0][3], tab_usage[0][4],
        tab_usage[1][2], tab_usage[1][3], tab_usage[1][4],
        tab_usage[2][3], tab_usage[2][4],
        tab_usage[3][4]
    ]

    colors = [cm.hot(c) for c in colors] # Échelle de couleur (0 = noir, 1 = jaune)

    #visualisation du graphe
    nx.draw_networkx_nodes(G, pos, node_size=1000, ax=ax)
    nx.draw_networkx_labels(G, pos, ax=ax)
    nx.draw_networkx_edges(G, pos, edgelist=edgelist, edge_color=colors, arrows=False, ax=ax)