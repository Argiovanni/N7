from Simulation import Simulation_impl
import matplotlib.pyplot as plt
import multiprocessing
import statistics
from utils import RoutingAlgorithmType
from constant import REPET_NUMBER, get_call_nbr, set_call_nbr, LINKS_CAP

if __name__ == "__main__":
    call_volumes = []  # Liste pour stocker les volumes d'appels
    hierarchical_results = []  # Résultats pour l'algorithme hiérarchique
    shared_load_results = []  # Résultats pour le routage avec partage de charge
    adaptive_results = []  # Résultats pour le routage adaptatif

    # Création de la figure principale et des sous-figures
    main_figure = plt.figure(constrained_layout=True, num="Analyse des Algorithmes de Routage")
    (top_fig, bottom_fig) = main_figure.subfigures(2, 1)
    (plot1, plot2, plot3) = top_fig.subplots(1, 3)
    overall_plot = bottom_fig.subplots()

    top_fig.suptitle("Utilisation des liens pour une charge de 6000 appels/h")

    # Simulation pour chaque type de routage
    print("===== DÉMARRAGE DE LA SIMULATION : ROUTAGE HIERARCHIQUE =====")
    sim_hierarchical = Simulation_impl(RoutingAlgorithmType.HIERARCHICAL)
    sim_hierarchical.run(display_usage=True, subplot=plot1)
    plot1.set_title('Algorithme Hiérarchique')

    print("===== DÉMARRAGE DE LA SIMULATION : ROUTAGE PARTAGE DE CHARGE =====")
    sim_shared = Simulation_impl(RoutingAlgorithmType.SHARELOAD)
    sim_shared.run(display_usage=True, subplot=plot2)
    plot2.set_title('Partage de Charge')

    print("===== DÉMARRAGE DE LA SIMULATION : ROUTAGE ADAPTATIF =====")
    sim_adaptive = Simulation_impl(RoutingAlgorithmType.ADAPTATIV)
    sim_adaptive.run(display_usage=True, subplot=plot3)
    plot3.set_title('Algorithme Adaptatif')

    # Comparaison des algorithmes pour différentes charges d'appels
    print("===== COMPARAISON DES ALGORITHMES =====")
    for traffic in range(100, 10000, 800):
        # Mettre à jour la charge d'appels
        set_call_nbr(traffic)
        current_call_nbr = get_call_nbr()
        call_volumes.append(current_call_nbr)

        # Test pour l'algorithme hiérarchique
        sim_hierarchical_test = Simulation_impl(RoutingAlgorithmType.HIERARCHICAL)
        with multiprocessing.Pool() as pool:
            failed_calls = pool.map(sim_hierarchical_test.run, range(REPET_NUMBER))
        hierarchical_results.append(statistics.mean(failed_calls) / current_call_nbr)

        # Test pour le routage avec partage de charge
        sim_shared_test = Simulation_impl(RoutingAlgorithmType.SHARELOAD)
        with multiprocessing.Pool() as pool:
            failed_calls = pool.map(sim_shared_test.run, range(REPET_NUMBER))
        shared_load_results.append(statistics.mean(failed_calls) / current_call_nbr)

        # Test pour le routage adaptatif
        sim_adaptive_test = Simulation_impl(RoutingAlgorithmType.ADAPTATIV)
        with multiprocessing.Pool() as pool:
            failed_calls = pool.map(sim_adaptive_test.run, range(REPET_NUMBER))
        adaptive_results.append(statistics.mean(failed_calls) / current_call_nbr)

    # Tracé des résultats
    overall_plot.plot(call_volumes, hierarchical_results, label='Hiérarchique')
    overall_plot.plot(call_volumes, shared_load_results, label='Partage de Charge')
    overall_plot.plot(call_volumes, adaptive_results, label='Adaptatif')
    overall_plot.set_xlabel('Volume d\'appels (par heure)')
    overall_plot.set_ylabel('% d\'appels rejetés')
    overall_plot.set_title('Évaluation des Algorithmes de Routage')

    plt.legend()
    plt.savefig('comparaison_routage.pdf')  # Sauvegarde des graphes dans un fichier PDF
    plt.show()
