from constant import NBR_OF_MACHINES,LINKS_CAP

class Network_impl():
    def __init__(self):
        self.__realtime_capacity = LINKS_CAP.copy()
        self.__nb_failed_call = 0

    def get_nb_machine(self):
        """
        Retourne le nombre total de machines dans le réseau.
        """
        return NBR_OF_MACHINES

    def get_failed_call_count(self):
        """
        Retourne le nombre total d'appels échoués.
        """
        return self.__nb_failed_call

    def get_max_cap(self, id1, id2):
        """
        Donne la capacité maximale d'un lien en termes d'appels simultanés.
        @param id1 : ID de la première machine.
        @param id2 : ID de la deuxième machine.
        """
        return LINKS_CAP[(id1 * NBR_OF_MACHINES) + id2]

    def get_real_cap(self, id1, id2):
        """
        Donne la capacité réelle disponible sur un lien.
        @param id1 : ID de la première machine.
        @param id2 : ID de la deuxième machine.
        """
        return self.__realtime_capacity[(id1 * NBR_OF_MACHINES) + id2]
    
    def get_usage_rate(self, id1, id2):
        """
        Calcule le pourcentage d'utilisation d'un lien entre deux machines.
        @param id1 : ID de la première machine.
        @param id2 : ID de la deuxième machine.
        """
        max_cap = self.get_max_cap(id1,id2)
        if max_cap >0:
            rate = ( max_cap - self.get_real_cap(id1, id2)) / max_cap
        else:
            rate = 0
        return rate
        
    def get_active_call_count(self):
        """
        Calcule le nombre total d'appels actifs dans le réseau.
        """
        nb_calls = 0
        for i in range(NBR_OF_MACHINES):
            for j in range(i+1, NBR_OF_MACHINES):
                nb_calls += self.get_max_cap(i,j) - self.get_real_cap(i,j)
        return nb_calls
    
    def increment_failed_call(self):
        """
        Incrémente le compteur d'appels échoués.
        """
        self.__nb_failed_call += 1
    
    def neighbors(self, id_c):
        """
        Renvoie la liste des voisins directs d'une machine.
        @param id_c : ID de la machine.
        """
        neighbors_l = []
        for id_n in range(NBR_OF_MACHINES):
            if self.get_max_cap(id_c,id_n) > 0:
                neighbors_l.append(id_n)
        return neighbors_l
    
    def allocate(self, id1, id2):
        """
        Réserve une unité de capacité sur un lien pour un appel.
        @param id1 : ID de la première machine.
        @param id2 : ID de la deuxième machine.
        @return : True si la réservation est réussie, False sinon.
        """
        if self.get_real_cap(id1, id2):
            self.__realtime_capacity[(id1 * NBR_OF_MACHINES) + id2] -= 1
            self.__realtime_capacity[(id2 * NBR_OF_MACHINES) + id1] -= 1
            return True
        else:
            return False
    
    def free(self, id1, id2):
        """
        Libère une unité de capacité sur un lien après un appel.
        @param id1 : ID de la première machine.
        @param id2 : ID de la deuxième machine.
        """
        self.__realtime_capacity[(id1 * NBR_OF_MACHINES) + id2] += 1
        self.__realtime_capacity[(id2 * NBR_OF_MACHINES) + id1] += 1
