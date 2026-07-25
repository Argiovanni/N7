# Rapport déploiement de réseaux
## Alexandre Vanicotte--Hochman, Arthur Bongiovanni

### 1.Introduction
AFDX est un super protocole que vous connaissez au moins aussi bien que nous. Dans ce projet, l'objectif est d'utiliser DPDK pour changer les règles de commutation d'un switch AFDX simulé et introduire donc du VL forwarding puis du VL multicasting afin de calculer des délais pires cas (le délai moyen ne nous intéresse pas puisqu'on cherche à certifier avec le pire cas).
Pour le protocole opératoire, nous branchons 2 PC de salle c308. 
Le PC 1 servira de simulateur de trafic à l'aide d'un script Python et d'une commande Bash qui permet d'envoyer les trames dès que possible. Ce script enverra de façon alternée des messages sur le VL 1 et 2.
```bash
for i in {1..2000};do
sudo python send.py;
done
```
Le PC 2 servira de switch et est équipé de 2 ports parallèles.
On relie les interfaces eth2 et eth3 de la machine 1 aux ports parallèles de la machine 2  selon la logique suivante avec des câbles RJ45:
```
eth3<->port 0
eth2<->port 1 
```

Pour calculer le timing de réception, on utilise la fonction `m->udata64 = rte_get_tsc_cycles();` qui charge dans le [champ data utilisateur](https://doc.dpdk.org/api-2.0/structrte__mbuf.html#afd0ffb02780e738d4c0a10ab833b7834) de la trame le timing d'entrée de la trame (lors de sa lecture dans le buffer) dans le commutateur. Ensuite, nous calculons la fin du timing lorsque la trame est introduite dans le buffer d'envoi. 
``` c
uint64_t t_in  = m->udata64;
uint64_t t_out = rte_get_timer_cycles();
uint64_t hz    = rte_get_timer_hz();

uint64_t diff_ns = (t_out - t_in) * 1000000000 / hz;
```
Nous ne conserverons pour chaque port que le délai maximal puisque nous ne sommes intéressés que par celui-ci dans le cadre de sa certification.
### 2.VL forwarding

Dans ce premier cas, on active la macro
```c
//#define MCASTVLFORWARD
 #define VLFORWARD
// #define FORWARD
```
Le programme va récupérer le VL dans les champs d'adresse puis le diriger vers le bon port.
```c

static void
l2fwd_VL_forward(struct rte_mbuf *m)
{
	...
	eth_h = rte_pktmbuf_mtod(m, struct ether_hdr *);

	addr_dest = eth_h->d_addr;
	addr1 = addr_dest.addr_bytes[4];		// première partie du champ VL de l'adresse destination
	addr2 = addr_dest.addr_bytes[5];		// Seconde partie du champ VL de l'adresse destination
	VLid = ((u_int16_t)addr1 << 8) + addr2; // de la tambouille c comme on aime pour récuperer l'info qui nous interesse
	
	...

	dst_port = l2fwd_VL_dst_ports[VLid];
	...
	buffer = tx_buffer[dst_port];
	sent = rte_eth_tx_buffer(dst_port, 0, buffer, m);
	...

}
```
La table de commutation [](route_VL-fwd.txt) est un fichier texte dont les lignes sont de cette forme:
`VL port`
Comme intuité dans le code, la table de commutation est un tableau statique.

On obtient au bout de 2000 trames envoyées vers le port 0: 
- D $_{commutation~max~port~0}$=351 ns
- D $_{commutation~max~port~1}$=705 ns

On obtient donc des valeurs bien inférieures à 8 µs (délai de certification).

### 3.VL Multicast

Dans ce second cas, on active la macro

```c
#define MCASTVLFORWARD
// #define VLFORWARD
// #define FORWARD
```

```c

static void
l2fwd_mcVL_forward(struct rte_mbuf *m)
{
	...
	struct ether_hdr *eth_h = rte_pktmbuf_mtod(m, struct ether_hdr *);

	struct rte_mbuf *copied_msg = rte_pktmbuf_clone(m, l2fwd_pktmbuf_pool);
	// copie m car le buffer est consommé par l'envoi

	addr_dest = eth_h->d_addr;
	addr1 = addr_dest.addr_bytes[4];		// première partie du champ VL de l'adresse destination
	addr2 = addr_dest.addr_bytes[5];		// Seconde partie du champ VL de l'adresse destination
	VLid = ((u_int16_t)addr1 << 8) + addr2; // de la tambouille c comme on aime pour récuperer l'info qui nous interesse

    ...
	port_node_t *node = l2fwd_mcast_VL_dst_ports[VLid];
    ...
	/* premier envoi */
	dst_port = node->port_id;
	buffer = tx_buffer[dst_port];
	sent = rte_eth_tx_buffer(dst_port, 0, buffer, copied_msg);
    ...
	node = node->next;

	/* envois suivants : clones pour chaque port */
	while (node)
	{ // itère sur la liste des ports liés à ce VL
		struct rte_mbuf *copied_msg = rte_pktmbuf_clone(m, l2fwd_pktmbuf_pool);
		// copie m car le buffer est consommé par l'envoi
            ...
		dst_port = node->port_id;
		buffer = tx_buffer[dst_port];
		sent = rte_eth_tx_buffer(dst_port, 0, buffer, copied_msg);
    ...
    node = node->next;
	}

	rte_pktmbuf_free(m);
}

```
Dans ce second cas, le code est un peu plus long, mais fait les choses de façon assez similaire, avec tout de même l'ajout de la copie du buffer pour l'intégrer à plusieurs  buffers de sortie. Dans ce cas, le format choisi pour la table de commutation est un tableau statique de listes chaînées.

Dans ce second cas, les 2000 trames sont envoyées vers le port 0, encore une fois alternativement sur VL 1 et 2.

La table de commutation [](route_VL-mcast.txt) est un fichier texte dont les lignes sont de cette forme:
`VL port1 port2 .... port n`

On obtient au bout de 2000 trames envoyées vers le port 0: 
- D $_{commutation~max~port~0}$=1500 ns
- D $_{commutation~max~port~1}$=1047 ns

On obtient donc aussi des valeurs bien inférieures à 8 µs (délai de certification).

On observe une inversion des maxima dans le cas de l'inversion de l'ordre dans la table de commutation. En effet, la structure est un tableau de listes chaînées, la tête est alors la fin de la ligne sur la table de commutation.
### 4.Critique de la méthode
Notre méthodologie met en évidence des délais largement satisfaisants. Cependant, les valeurs mesurées ne sont pas constantes et résultent de quelques observations (mais aucune de ces dernières n’a fait état d’un délai excessif). Le BAG permettrait d’espacer les envois de trames et donc d’éviter des pertes et des saturations côté switch. Notre démonstration montre toutefois qu’avec un débit continu, les paquets sont correctement transmis au niveau du switch, et donc que le BAG ne pourrait qu’améliorer la situation.

Fun Fact: au départ, le port 1 n'était pas physiquement connecté, le buffer d'envoi se sature alors avec 542 paquets. 

### 5.Conclusion
Nous avons donc programmé un switch qui pourrait être certifié selon nos observations.


