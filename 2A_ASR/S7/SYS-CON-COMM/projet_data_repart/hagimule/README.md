# *HagiMule*

    Auteurs : 
        BONGIOVANNI Arthur 
        BEDROSSIAN Paul

## Objectifs

Implantation d'une infrastructure de téléchargement **parallèle** de **grand fichiers**.

### Principe général

Un client peut télécharger en parallèle des fichiers à partir de plusieurs sources (d'autres clients).

- Annuaire : enregistrement des fichiers (unique nom pour chaque fichier) que les clients connectés possèdent 
et donne la liste des fichiers aux clients.
- Client : Enregistre les fichiers qu'il possède (y compris ceux tous juste téléchargé), permet le 
téléchargement de fragment de ces fichiers et peut télécharger.

## Architecture

Le projet *HagiMule* est composé de :

### Diary (Serveur)

C'est l'annuaire, il enregistre les fichiers des clients connectés
(accessible par RMI).

### Daemon (Client)

C'est la partie qui gère le téléchargement de fragments depuis d'autres clients
(accessible par TCP).

### Downloader (Client)

C'est la partie qui gère le téléchargement d'un fichier en parallèle depuis
le client.

## Améliorations futures

- &#x2611; Gestion de pannes durant le téléchargement
- &#x2611; Prendre en compte dynamiquement l'arrivé de nouvelles sources
- &#x2611; Prendre en compte l'occupation des ressources
- &#x2611; Compresion (tester les performences entre par fichiers ou par fragments)

## Dev Blog

### [NOTE] #1 (10/12/2024)

- [STABLE] **HagiMule**_v1.0 : 
    - Lancer un démon qui héberge des fichiers.
    - L'annuaire enregistre les fichiers ainsi que les ports et addresses des fournisseurs.
    - Le client peut lister les fichiers disponibles.
    - Le client peut télécharger un fichier à partir d'une ou plusieurs sources.
    - Si une ressource est occupée ou *down* elle est immédiatement retirer de la liste des fournisseurs dans l'annuaire.

- *Bugs* :
    - Un port peut être utilisé (et donc retirer de la liste des fournisseurs) mais ne peut pas encore être remis a disposition si son utilisation est terminée. **[FIXED]**
    - Lorsqu'un port est utilisé, il est normalement retirer que de la liste des ports disponibles, cependant, dans notre cas présent, il est retiré de la liste des ports utilisés par *HagiMule*. **[FIXED]**
    - Le rate ne se mets pas correctement à jour. **[FIXED]**
    - Certaines exceptions ne sont pas encore bien gérée.
    - On ne détecte pas encore les erreurs et aucun mécanisme de correction n'est encore implenté. **[FIXED]**

- Améliorations envisagées :
    - Le client doit être réécrit pour ne pas avoir de chemin écrit dans le code ni d'addresse. **[DONE]**
    - Inclure une interface pour voir le temps d'un téléchargement en rappelant la configuration. **[DONE]**
    - Inclure les améliorations discutées dans la section *Améliorations futures*. **[DONE]**
    - Générer un test de grande envergure pour le *POC* avec une automatisation des variations des paramètres et du stockage des résultats afin de générer des courbes (paramètres/temps).
    - Un jeu de tests avec plusieurs fournisseurs de fichiers différents pour être plus fin.

### [NOTE] #2 (17/12/2024)

- [STABLE] **HagiMule**_v2.0 :
    - Choix du mode (compression de tout le fichier, compression des fragments, ou pas de compression).
    - Améliorations de l'interface utilisateur.
    - Fichier de log pour le téléchargement.
    - Reprise du téléchargement sur erreurs.
    - Corrections des bugs de la version précédente.

- *Bugs* : 
    - Un fichier trop peu volumineux a une compression bizarre (a enquêter).
    - Le méchanisme de reprise sur erreurs ne semble pas attendre les 5 secondes de délai avant d'annuler le téléchargement.

- Améliorations envisagées :
    - Générer un test de grande envergure pour le *POC* avec une automatisation des variations des paramètres et du stockage des résultats afin de générer des courbes (paramètres/temps).
    - Un jeu de tests avec plusieurs fournisseurs de fichiers différents pour être plus fin.