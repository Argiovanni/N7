from Network import Network_impl
from utils import initialise_timeline, render_usage, configure_routing
from constant import SIMULATION_END_TIME, LINKS_CAP, NBR_OF_MACHINES


class Simulation_impl:
    def __init__(self, algorithm_type):
        self._network = None  # Réseau simulé
        self._algorithm_type = algorithm_type  # Type de routage
        self._timeline = None  # Liste des événements simulés

    def run(self, thread_id=0, display_usage=False, subplot=None):
        """
        Exécute la simulation.
        @param thread_id : Identifiant du thread (utilisé dans le pool multiprocessing).
        @param display_usage : Affiche les statistiques d'usage des liens si True.
        @param subplot : Sous-plot matplotlib pour les graphiques (uniquement si display_usage=True).
        """
        # Initialisation de l'environnement de simulation
        self._network = Network_impl()
        self._timeline = initialise_timeline(configure_routing(self._algorithm_type, self._network))
        
        usage_stats = []  # Matrice pour collecter les statistiques d'usage des liens
        snapshot_count = 0  # Nombre de snapshots collectés
        active_calls_sum = 0  # Somme des appels actifs pour la moyenne
        peak_calls = 0  # Maximum d'appels actifs simultanés
        timestamps = None

        if display_usage:
            # Initialisation pour les métriques d'usage des liens
            usage_stats = [[0 for _ in range(NBR_OF_MACHINES)] for _ in range(NBR_OF_MACHINES)]
            timestamps = list(range(SIMULATION_END_TIME + 6 * 60))  # Timeline étendue de 6 min car un appel fait max 5 min (on garde une marge de sécurité)

        # Parcours des événements dans la simulation
        for current_event in self._timeline:
            if display_usage and timestamps:
                while current_event.get_timestamp() > timestamps[0]:
                    snapshot_count += 1
                    timestamps.pop(0)

                    # Mise à jour des données d'usage
                    usage_stats = [
                        [
                            usage_stats[row][col] + self._network.get_usage_rate(row, col)
                            for col in range(NBR_OF_MACHINES)
                        ]
                        for row in range(NBR_OF_MACHINES)
                    ]
                    # Mise à jour des appels actifs
                    active_calls = self._network.get_active_call_count()
                    active_calls_sum += active_calls
                    peak_calls = max(peak_calls, active_calls)

            # Exécute l'événement
            current_event.run(self._network)

        if display_usage:
            # Calcul des moyennes et affichage des résultats
            average_usage = [
                [
                    usage_stats[row][col] / snapshot_count
                    for col in range(NBR_OF_MACHINES)
                ]
                for row in range(NBR_OF_MACHINES)
            ]
            render_usage(average_usage, subplot)  # Affichage graphique des usages

            # Analyse des capacités et des taux d'utilisation
            link_utilization = [
                [
                    usage_stats[row][col] / snapshot_count * LINKS_CAP[row * NBR_OF_MACHINES + col]
                    for col in range(NBR_OF_MACHINES)
                ]
                for row in range(NBR_OF_MACHINES)
            ]
            total_usage = sum(sum(row) for row in link_utilization)
            total_capacity = sum(LINKS_CAP)

            # Affiche les statistiques finales
            print(f"Utilisation moyenne totale des liens : {total_usage} ({total_usage / total_capacity:.2%})")
            print(f"Appels simultanés moyens : {active_calls_sum / snapshot_count}")
            print(f"Appels simultanés maximum : {peak_calls}")
            print(f"Nombre de snapshots collectés : {snapshot_count}")

        # Retourne le nombre d'appels échoués
        return self._network.get_failed_call_count()
