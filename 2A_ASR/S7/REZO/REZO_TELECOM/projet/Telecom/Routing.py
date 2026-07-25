from abc import abstractmethod
import random
from constant import CA_INDEX, CA_NUMBER

def random_choice(choices, weights):
    """
    Renvoie un des choix possibles proportionnellement aux poids donnés.
    @param choices : Liste des choix possibles.
    @param weights : Liste des poids associés à chaque choix.
    @return : Le choix sélectionné.
    """
    # On utilise le carré des poids pour donner plus de poids aux valeurs élevées.
    weights = [w ** 2 for w in weights]
    random_value = random.random() * sum(weights)
    cumulative_weight = 0
    for i, choice in enumerate(choices):
        cumulative_weight += weights[i]
        if random_value <= cumulative_weight:
            return choice
    return None


class Routing():
    """
    Classe abstraite représentant un algorithme de routage.
    """
    
    def __init__(self, network):
        """
        Initialisation du routage avec un réseau donné.
        @param network : Instance du réseau.
        """
        self.network = network

    @abstractmethod
    def find_route(self, source, dest):
        """
        Trouve une route entre la source et la destination.
        @param source : ID de la source.
        @param dest : ID de la destination.
        @return : Liste des IDs des noeuds formant la route.
        """
        raise NotImplementedError(" Routing algorithm not implemented yet")
    

class HierarchicalRouting(Routing):
    """
    Algorithme de routage hiérarchique. Passe toujours par un CTS.
    """

    def find_route(self, id_source, id_destination):
        """
        Trouve une route statique en passant par un CTS.
        Attention : suppose que chaque CTS est relié à tous les CA.
        @param id_source : ID de la source.
        @param id_destination : ID de la destination.
        @return : Liste des IDs des noeuds formant la route.
        """
        route = [id_source]

        while route[-1] != id_destination:
            if route[-1] < CA_NUMBER:
                # Passe par un CTS (exemple d'un routage hiérarchique)
                route.append(((route[-1] + 1) // CA_NUMBER) + CA_NUMBER)
            else:
                route.append(id_destination)
        return route
    

class ShareLoadRouting(Routing):
    """
    Algorithme de routage répartissant la charge sur les liens disponibles.
    Donne la priorité aux liens ayant une plus grande capacité maximale.
    """
    
    def find_route(self, source, dest):
        """
        Trouve une route basée sur la capacité max des liens. 
        @param source : ID de la source.
        @param dest : ID de la destination.
        @return : Liste des IDs des noeuds formant la route ou une liste vide si aucune route n'est trouvée.
        """
        route = [source]
        visite = [source]
        while route and route[-1] != dest :
            neighbor = self.network.neighbors(route[-1])
            # Filtrer les noeuds déjà visités
            neighbor = list(filter(lambda x: x not in visite, neighbor))
            
            if len(route) >= 3 and dest in neighbor:
                # Si la destination est directement accessible
                route.append(dest)
                return route
            
            # Calcul des poids des liens en fonction de leur capacité maximale
            weight = [self.network.get_max_cap(route[-1], i) for i in neighbor ]
            next_node = random_choice(neighbor, weight)
            if next_node:
                route.append(next_node)
                visite.append(next_node)
            else:
                # Retourne une route vide si aucun chemin n'est trouvé
                return []
        return route
    

class AdaptiveRouting(Routing):
    """
    Algorithme de routage adaptatif basé sur la capacité réelle des liens.
    """
        
    def find_route(self, source, dest):
        """
        Trouve une route adaptative basée sur la capacité réelle restante des liens.
        @param source : ID de la source.
        @param dest : ID de la destination.
        @return : Liste des IDs des noeuds formant la route ou une liste vide si aucune route n'est trouvée.
        """
        route = [source]
        visite = [source]
        
        while route[-1] != dest :
            neighbor = self.network.neighbors(route[-1])
            # Filtrer les noeuds déjà visités
            neighbor = list(filter(lambda x: x not in visite, neighbor))
            
            if len(route) >= 3 and dest in neighbor:
                # Si la destination est directement accessible
                route.append(dest)
                return route
            
            # Calcul des poids des liens en fonction de leur capacité réelle
            weight = [self.network.get_real_cap(route[-1], i) for i in neighbor ]
            next_node = random_choice(neighbor, weight)
            if next_node:
                route.append(next_node)
                visite.append(next_node)
            else:
                # Retourne une route vide si aucun chemin n'est trouvé
                return []
        return route