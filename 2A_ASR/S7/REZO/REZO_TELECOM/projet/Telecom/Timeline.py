import heapq

class Timeline_impl():
    """
    Timeline des appels sous forme de file de priorité basée sur un tas binaire (min-heap).
    Permet d'ajouter et de traiter les événements par ordre chronologique.
    """

    def __init__(self):
        """
        Initialise une timeline vide.
        """
        self.__index = 0
        self.__heap = []

    def add_event(self, event):
        """
        Ajoute un événement à la timeline.
        @param event : Instance d'un événement.
        """
        # Ajout de l'événement dans le tas avec un tuple (timestamp, index, event)
        heapq.heappush(self.__heap, (event.get_timestamp(), self.__index, event))
        self.__index += 1

    def pop(self):
        """
        Récupère et supprime le prochain événement dans la timeline.
        @return : L'événement avec le plus petit timestamp.
        """
        if not self.__heap:
            raise IndexError("La timeline est vide.")
        return heapq.heappop(self.__heap)[2]  # Retourne uniquement l'événement

    def __iter__(self):
        """
        Rend la timeline itérable.
        """
        return self

    def __next__(self):
        """
        Récupère le prochain événement pour l'itération.
        @return : L'événement avec le plus petit timestamp.
        """
        if self.__heap:
            return self.pop()
        else:
            raise StopIteration
    
    def __len__(self):
        """
        Retourne le nombre d'événements restants dans la timeline.
        @return : Nombre d'événements dans la timeline.
        """
        return len(self.__heap)
    
    def is_empty(self):
        """
        Vérifie si la timeline est vide.
        @return : True si la timeline est vide, False sinon.
        """
        return len(self.__heap) == 0