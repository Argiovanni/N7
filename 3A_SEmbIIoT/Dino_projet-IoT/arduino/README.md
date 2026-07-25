Pour l’instant nous avons réussi à simuler un bus CAN avec deux cartes Arduino uno en passant par un controller CAN (MCP2515). Le but ici est de simuler la communication dans une voiture de manière assez simplifié. Nous utilisons la librairie mcp2515 fourni par autowp (https://github.com/autowp/arduino-mcp2515).

La connection entre l’arduino et le MCP2515 est faite en spi et le MCP2515 permet d’envoyer les données sur le bus. 

Nous avons réussi à mettre en place la communication CAN avec des arduinos mais nous n’arrivons pas encore à intégrer la raspberry pi dans cette architecture (on ne peut pas lire les message dans le bus CAN avec la raspberry pi. Nous suspectons une erreur de configuration du protocole spi côté raspberry pi (https://github.com/autowp/arduino-mcp2515).

Il nous reste donc à régler ce souci de lecture et à définir une séquence de message CAN (bien ordonnancé) qui représente la communication dans une voiture. En suite, on pourra lancer le serveur web sur la raspberry pi.
# Code for Can simulator on arduino uno
