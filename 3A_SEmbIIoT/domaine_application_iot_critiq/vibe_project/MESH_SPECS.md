# Spécifications du Routage Link-State

## Concept
Contrairement au routage par vecteur de distance, l'approche **Link-State** permet à chaque nœud de posséder une carte complète du réseau.

## Fonctionnement
1. **Hello/Scan** : Découverte des voisins immédiats via BLE.
2. **LSA (Link State Advertisement)** : Chaque nœud émet un paquet contenant la liste de ses voisins directs et le coût du lien (RSSI).
3. **Inondation (Flooding)** : Les paquets LSA sont relayés par tous les nœuds (TTL décrémenté).
4. **Calcul de Route** : Chaque nœud peut calculer le chemin le plus court vers n'importe quelle destination connue dans sa base de données topologique.

## Structure du Paquet
`ID|SOURCE|DESTINATION|TYPE|TTL|PAYLOAD`
- `TYPE` : `ROUTING_UPDATE` pour les échanges de liens.
- `PAYLOAD` : Format `NodeA:NodeB:Cost,NodeA:NodeC:Cost`