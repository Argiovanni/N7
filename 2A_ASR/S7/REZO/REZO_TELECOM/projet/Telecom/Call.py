class Call_impl():
    def __init__(self, source, dest, start, duration, routing):
        """
        Représente un appel entre deux machines.
        @param source : ID de la machine source de l'appel.
        @param dest : ID de la machine cible de l'appel.
        @param start : Temps de début de l'appel (en secondes).
        @param duration : Durée de l'appel (en secondes).
        @param routing : Algorithme de routage utilisé pour cet appel.
        """
        self.__source = source
        self.__dest = dest
        self.__start = start
        self.__duration = duration
        self.__routing = routing
        self.__route = [] # Liste des machines parcourues par l'appel

    def init_call(self, network):
        """
        Initialise l'appel et réserve les ressources réseau nécessaires.
        @param network : Instance du réseau.
        @return : True si l'appel est établi avec succès, False sinon.
        """
        road = self.__routing.find_route(self.__source, self.__dest)
        if len(road) > 0 :
            self.__route.append(road[0]) # Ajouter la machine source au chemin
            for i in range(1, len(road)): 
                is_available = network.allocate(self.__route[-1], road[i])
                if not is_available:
                    self.free_call(network) # libérations de liens précédent car la connexion ne peut être établie
                    return False
                self.__route.append(road[i]) # on ajoute chaque noeud à la route de l'appel
            return True    
        return False
        
    def free_call(self, network):
        """
        Libère les ressources réseau utilisées par cet appel.
        @param network : Instance du réseau.
        """
        while (len(self.__route)>1):
            id1 = self.__route.pop()
            id2 = self.__route[-1]
            network.free(id1,id2)
        self.__route = []

    def end_time(self):
        return self.__start + self.__duration
    
    def start_time(self):
        return self.__start
