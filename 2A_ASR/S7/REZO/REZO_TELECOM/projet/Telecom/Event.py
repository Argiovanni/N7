from abc import abstractmethod

class Event():
    """
    Représente un événement dans la timeline, tel que le début ou la fin d'un appel.
    """

    def __init__(self, timestamp, call):
        """
        Initialisation d'un événement.
        @param timestamp : Temps auquel l'événement se produit (en secondes).
        @param call : Instance de l'appel associé à cet événement.
        """
        self.__timestamp = timestamp
        self.__call = call
    
    def get_timestamp(self):
        return self.__timestamp
    
    def get_call(self):
        return self.__call

    @abstractmethod
    def run(self, network):
        """
        le code de l'événement (lancer/terminer l'appel)
        """
        raise NotImplementedError("Please implement run.")
    
    
class EventEndCall(Event):
    """
    Événement correspondant à la fin d'un appel.
    """
    
    def run(self, network):
        """
        Libère les ressources utilisées par l'appel
        """
        self.get_call().free_call(network)


class EventStartCall(Event):
    """
    Évent correspondant au début d'un appel
    """
    
    def __init__(self, call, timeline):
        """
        Initialise un événement de début d'appel et l'ajoute à la timeline.
        @param call : Instance de l'appel.
        @param timeline : Timeline dans laquelle cet événement est ajouté.
        """
        super().__init__(timestamp=call.start_time(), call=call)
        timeline.add_event(self)
        self.__timeline=timeline
        
    def run(self, network):
        """
        Initialise les ressources pour l'appel, en cas de réussite, 
        ajout dans la timeline de l'event de fin d'appel. 
        Sinon, incrémente le nombre d'appel refusé.
        """
        call = self.get_call()
        if call.init_call(network):
            self.__timeline.add_event(EventEndCall(timestamp=call.end_time(), call=call))
        else:
            network.increment_failed_call()
