#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <inttypes.h>
#include <sys/types.h>
#include <sys/queue.h>
#include <netinet/in.h>
#include <setjmp.h>
#include <stdarg.h>
#include <ctype.h>
#include <errno.h>
#include <getopt.h>
#include <signal.h>
#include <stdbool.h>
#include <time.h>

#include <rte_common.h>
#include <rte_log.h>
#include <rte_malloc.h>
#include <rte_memory.h>
#include <rte_memcpy.h>
#include <rte_memzone.h>
#include <rte_eal.h>
#include <rte_per_lcore.h>
#include <rte_launch.h>
#include <rte_atomic.h>
#include <rte_cycles.h>
#include <rte_prefetch.h>
#include <rte_lcore.h>
#include <rte_per_lcore.h>
#include <rte_branch_prediction.h>
#include <rte_interrupts.h>
#include <rte_pci.h>
#include <rte_random.h>
#include <rte_debug.h>
#include <rte_ether.h>
#include <rte_ethdev.h>
#include <rte_mempool.h>
#include <rte_mbuf.h>

static volatile bool force_quit;

#define RTE_LOGTYPE_L2FWD RTE_LOGTYPE_USER1
#define NB_MBUF 8192

/* le routage employé*/
#define MCASTVLFORWARD
// #define VLFORWARD
// #define FORWARD

#define MAX_PKT_BURST 32
#define BURST_TX_DRAIN_US 100 /* TX drain every ~100us */
#define MEMPOOL_CACHE_SIZE 256

/*
 * Configurable number of RX/TX ring descriptors
 */
#define RTE_TEST_RX_DESC_DEFAULT 128
#define RTE_TEST_TX_DESC_DEFAULT 512
static uint16_t nb_rxd = RTE_TEST_RX_DESC_DEFAULT;
static uint16_t nb_txd = RTE_TEST_TX_DESC_DEFAULT;

/* ethernet addresses of ports */
static struct ether_addr l2fwd_ports_eth_addr[RTE_MAX_ETHPORTS];

/* mask of enabled ports */
static uint32_t l2fwd_enabled_port_mask = 0;

/* list of enabled ports */
static uint32_t l2fwd_dst_ports[RTE_MAX_ETHPORTS];

#define RTE_MAX_VLPORTS 65535
static uint32_t l2fwd_vl_dst_ports[RTE_MAX_VLPORTS];

typedef struct port_node
{
	unsigned port_id;
	struct port_node *next;
} port_node_t;
static port_node_t* l2fwd_mcast_VL_dst_ports[RTE_MAX_VLPORTS];

void load_routes(const char *filename); // initialize léfwd_vl_dst_ports from external file

static unsigned int l2fwd_rx_queue_per_lcore = 1;

#define MAX_RX_QUEUE_PER_LCORE 16
#define MAX_TX_QUEUE_PER_PORT 16
struct lcore_queue_conf
{
	unsigned n_rx_port;
	unsigned rx_port_list[MAX_RX_QUEUE_PER_LCORE];
} __rte_cache_aligned;
struct lcore_queue_conf lcore_queue_conf[RTE_MAX_LCORE];

static struct rte_eth_dev_tx_buffer *tx_buffer[RTE_MAX_ETHPORTS];

static const struct rte_eth_conf port_conf = {
	.rxmode = {
		.split_hdr_size = 0,
		.header_split = 0,	 /**< Header Split disabled */
		.hw_ip_checksum = 0, /**< IP checksum offload disabled */
		.hw_vlan_filter = 0, /**< VLAN filtering disabled */
		.jumbo_frame = 0,	 /**< Jumbo Frame Support disabled */
		.hw_strip_crc = 1,	 /**< CRC stripped by hardware */
	},
	.txmode = {
		.mq_mode = ETH_MQ_TX_NONE,
	},
};

struct rte_mempool *l2fwd_pktmbuf_pool = NULL;

/* Per-port statistics struct */
struct l2fwd_port_statistics
{
	uint64_t tx;
	uint64_t rx;
	uint64_t dropped;
	time_t max_time;
} __rte_cache_aligned;
struct l2fwd_port_statistics port_statistics[RTE_MAX_ETHPORTS];

#define MAX_TIMER_PERIOD 86400 /* 1 day max */
/* A tsc-based timer responsible for triggering statistics printout */
static uint64_t timer_period = 10; /* default period is 10 seconds */

/* Print out statistics on packets dropped */
static void
print_stats(void)
{
	uint64_t total_packets_dropped, total_packets_tx, total_packets_rx;
	unsigned portid;

	total_packets_dropped = 0;
	total_packets_tx = 0;
	total_packets_rx = 0;

	const char clr[] = {27, '[', '2', 'J', '\0'};
	const char topLeft[] = {27, '[', '1', ';', '1', 'H', '\0'};

	/* Clear screen and move to top left */
	printf("%s%s", clr, topLeft);

	printf("\nPort statistics ====================================");

	for (portid = 0; portid < RTE_MAX_ETHPORTS; portid++)
	{
		/* skip disabled ports */
		if ((l2fwd_enabled_port_mask & (1 << portid)) == 0)
			continue;
		printf("\nStatistics for port %u ------------------------------"
			   "\nPackets sent: %24" PRIu64
			   "\nPackets received: %20" PRIu64
			   "\nPackets dropped: %21" PRIu64,
			   portid,
			   port_statistics[portid].tx,
			   port_statistics[portid].rx,
			   port_statistics[portid].dropped);
		printf("\nMax active time: %" PRIu64 " ns\n",
			port_statistics[portid].max_time);


		total_packets_dropped += port_statistics[portid].dropped;
		total_packets_tx += port_statistics[portid].tx;
		total_packets_rx += port_statistics[portid].rx;
	}
	printf("\nAggregate statistics ==============================="
		   "\nTotal packets sent: %18" PRIu64
		   "\nTotal packets received: %14" PRIu64
		   "\nTotal packets dropped: %15" PRIu64,
		   total_packets_tx,
		   total_packets_rx,
		   total_packets_dropped);
	printf("\n====================================================\n");
}

static void
l2fwd_simple_forward(struct rte_mbuf *m, unsigned portid)
{
	unsigned dst_port;
	int sent;
	struct rte_eth_dev_tx_buffer *buffer;

	dst_port = l2fwd_dst_ports[portid];
	uint64_t t_in  = m->udata64;
	uint64_t t_out = rte_get_timer_cycles();
	uint64_t hz    = rte_get_timer_hz();

	uint64_t diff_ns = (t_out - t_in) * 1000000000ULL / hz;
	if (diff_ns > port_statistics[dst_port].max_time)
		port_statistics[dst_port].max_time = diff_ns;

	buffer = tx_buffer[dst_port];
	sent = rte_eth_tx_buffer(dst_port, 0, buffer, m);
	if (sent)
		port_statistics[dst_port].tx += sent;
}

/*
Our work starts here
*/

static void
l2fwd_vl_forward(struct rte_mbuf *m)
{
	uint16_t vlid;
	struct ether_addr addr_dest;
	uint8_t addr1;
	uint8_t addr2;
	int sent;
	unsigned dst_port;
	struct rte_eth_dev_tx_buffer *buffer;
	struct ether_hdr *eth_h;
	eth_h = rte_pktmbuf_mtod(m, struct ether_hdr *);

	addr_dest = eth_h->d_addr;
	addr1 = addr_dest.addr_bytes[4];		// première partie du champs vl de l'adresse destination
	addr2 = addr_dest.addr_bytes[5];		// Seconde partie du champs vl de l'adresse destination
	vlid = ((u_int16_t)addr1 << 8) + addr2; // de la tambouille c comme on aime pour récuperer l'info qui nous interesse
	
	/* sécurité : VL hors limites */
	if (vlid >= RTE_MAX_VLPORTS)
	{
		rte_pktmbuf_free(m);
		return;
	}

	dst_port = l2fwd_vl_dst_ports[vlid];
	uint64_t t_in  = m->udata64;
	uint64_t t_out = rte_get_timer_cycles();
	uint64_t hz    = rte_get_timer_hz();

	uint64_t diff_ns = (t_out - t_in) * 1000000000ULL / hz;
	if (diff_ns > port_statistics[dst_port].max_time)
		port_statistics[dst_port].max_time = diff_ns;
	buffer = tx_buffer[dst_port];
	sent = rte_eth_tx_buffer(dst_port, 0, buffer, m);
	if (sent)
	{
		port_statistics[dst_port].tx += sent;
	}
}

static void
l2fwd_mcvl_forward(struct rte_mbuf *m)
{
	uint16_t vlid;
	struct ether_addr addr_dest;
	uint8_t addr1;
	uint8_t addr2;
	int sent;
	unsigned dst_port;
	struct rte_eth_dev_tx_buffer *buffer;
	struct ether_hdr *eth_h = rte_pktmbuf_mtod(m, struct ether_hdr *);

	struct rte_mbuf *copied_msg = rte_pktmbuf_clone(m, l2fwd_pktmbuf_pool);
	// copie m car le buffer est consomé par l'envoi

	addr_dest = eth_h->d_addr;
	addr1 = addr_dest.addr_bytes[4];		// première partie du champs vl de l'adresse destination
	addr2 = addr_dest.addr_bytes[5];		// Seconde partie du champs vl de l'adresse destination
	vlid = ((u_int16_t)addr1 << 8) + addr2; // de la tambouille c comme on aime pour récuperer l'info qui nous interesse

	/* sécurité : VL hors limites */
	if (vlid >= RTE_MAX_VLPORTS)
	{
		rte_pktmbuf_free(m);
		return;
	}

	port_node_t *node = l2fwd_mcast_VL_dst_ports[vlid];
	if (!node)
	{
		rte_pktmbuf_free(m);
		return;
	}

	/* premier envoi : on utilise le mbuf original */
	dst_port = node->port_id;
	buffer = tx_buffer[dst_port];
	sent = rte_eth_tx_buffer(dst_port, 0, buffer, copied_msg);
	if (sent)
	{
		port_statistics[dst_port].tx += sent;
	}
	uint64_t t_in  = m->udata64;
	uint64_t t_out = rte_get_timer_cycles();
	uint64_t hz    = rte_get_timer_hz();

	uint64_t diff_ns = (t_out - t_in) * 1000000000ULL / hz;

	if (diff_ns > port_statistics[dst_port].max_time)
		port_statistics[dst_port].max_time = diff_ns;

	node = node->next;

	/* envois suivants : clones pour chaque port */
	while (node)
	{ // itére sur la liste des ports lié à ce VL
		struct rte_mbuf *copied_msg = rte_pktmbuf_clone(m, l2fwd_pktmbuf_pool);
		// copie m car le buffer est consommé par l'envoie
		if (!copied_msg)
		{
			port_statistics[node->port_id].dropped++;
			node = node->next;
			continue;
		}
		dst_port = node->port_id;
		buffer = tx_buffer[dst_port];
		sent = rte_eth_tx_buffer(dst_port, 0, buffer, copied_msg);
		if (sent)
		{
			port_statistics[dst_port].tx += sent;
		}
		uint64_t t_in  = m->udata64;
		uint64_t t_out = rte_get_timer_cycles();
		uint64_t hz    = rte_get_timer_hz();

		uint64_t diff_ns = (t_out - t_in) * 1000000000 / hz;

		if (diff_ns > port_statistics[dst_port].max_time)
			port_statistics[dst_port].max_time = diff_ns;
		node = node->next;
	}

	rte_pktmbuf_free(m);
}

void load_routes(const char *filename)
/*outil pour charger les routes depuis un fichiers de configuration*/
{
	FILE *fp = fopen(filename, "r");
	if (!fp)
	{
		perror("Impossible d'ouvrir le fichier route");
		return;
	}
#ifdef MCASTVLFORWARD
	/* Initialise les listes */
	int i;
	for (i = 0; i < RTE_MAX_VLPORTS; i++)
	{
		l2fwd_mcast_VL_dst_ports[i] = NULL;
	}

	char buffer[256];

	while (fgets(buffer, sizeof(buffer), fp))
	{

		char *token = strtok(buffer, " \t\n");
		if (!token)
			continue;

		int vlid = atoi(token);

		if (vlid < 0 || vlid >= RTE_MAX_VLPORTS)
		{
			fprintf(stderr, "VLID hors limites : %d\n", vlid);
			continue;
		}

		/* Lire tous les ports restant sur la ligne */
		while ((token = strtok(NULL, " \t\n")) != NULL)
		{
			unsigned port_id = (unsigned)atoi(token);

			port_node_t *new_node = malloc(sizeof(port_node_t));
			if (!new_node)
			{
				fprintf(stderr, "Erreur d'allocation mémoire\n");
				break;
			}

			new_node->port_id = port_id;
			new_node->next = l2fwd_mcast_VL_dst_ports[vlid]; // insertion en tête
			l2fwd_mcast_VL_dst_ports[vlid] = new_node;
		}
	}
#else
	int vlid, port_id;

	while (fscanf(fp, "%d %d", &vlid, &port_id) == 2)
	{
		if (vlid >= 0 && vlid < RTE_MAX_VLPORTS)
		{
			l2fwd_vl_dst_ports[vlid] = port_id;
		}
		else
		{
			fprintf(stderr, "VLID hors limites : %d\n", vlid);
		}
	}
#endif
	fclose(fp);
}

/* Free memory used by multicast routes */
static void
free_mcast_routes(void)
{
#ifdef MCASTVLFORWARD
	unsigned i;
	for (i = 0; i < RTE_MAX_VLPORTS; i++) {
		port_node_t *node = l2fwd_mcast_VL_dst_ports[i];
		while (node) {
			port_node_t *temp = node;
			node = node->next;
			free(temp);
		}
	}
#endif
}

/*
 */

/* main processing loop */
static void
l2fwd_main_loop(void)
{
	struct rte_mbuf *pkts_burst[MAX_PKT_BURST];
	struct rte_mbuf *m;
	int sent;
	unsigned lcore_id;
	uint64_t prev_tsc, diff_tsc, cur_tsc, timer_tsc;
	unsigned i, j, portid, nb_rx;
	struct lcore_queue_conf *qconf;

	const uint64_t drain_tsc = (rte_get_tsc_hz() + US_PER_S - 1) / US_PER_S * BURST_TX_DRAIN_US;

	struct rte_eth_dev_tx_buffer *buffer;

	prev_tsc = 0;
	timer_tsc = 0;

	lcore_id = rte_lcore_id();
	qconf = &lcore_queue_conf[lcore_id];

	if (qconf->n_rx_port == 0)
	{
		RTE_LOG(INFO, L2FWD, "lcore %u has nothing to do\n", lcore_id);
		return;
	}

	RTE_LOG(INFO, L2FWD, "entering main loop on lcore %u\n", lcore_id);

	for (i = 0; i < qconf->n_rx_port; i++)
	{

		portid = qconf->rx_port_list[i];
		RTE_LOG(INFO, L2FWD, " -- lcoreid=%u portid=%u\n", lcore_id,
				portid);
	}
	while (!force_quit)
	{

		cur_tsc = rte_rdtsc();

		/*
		 * TX burst queue drain
		 */
		diff_tsc = cur_tsc - prev_tsc;
		if (unlikely(diff_tsc > drain_tsc))
		{
			for (i = 0; i < qconf->n_rx_port; i++)
			{
				portid = l2fwd_dst_ports[qconf->rx_port_list[i]];
				buffer = tx_buffer[portid];

				sent = rte_eth_tx_buffer_flush(portid, 0, buffer);

				if (sent)
					port_statistics[portid].tx += sent;
				
			}

			/* if timer is enabled */
			if (timer_period > 0)
			{

				/* advance the timer */
				timer_tsc += diff_tsc;

				/* if timer has reached its timeout */
				if (unlikely(timer_tsc >= timer_period))
				{

					/* do this only on master core */
					if (lcore_id == rte_get_master_lcore())
					{
						print_stats();
						/* reset the timer */
						timer_tsc = 0;
					}
				}
			}

			prev_tsc = cur_tsc;
		}

		/*
		 * Read packet from RX queues
		 */
		for (i = 0; i < qconf->n_rx_port; i++)
		{

			portid = qconf->rx_port_list[i];
			nb_rx = rte_eth_rx_burst((uint8_t)portid, 0,
									 pkts_burst, MAX_PKT_BURST);
			nb_rx = rte_eth_rx_burst((uint8_t)portid, 0,
                         pkts_burst, MAX_PKT_BURST);

			port_statistics[portid].rx += nb_rx;
			for (j = 0; j < nb_rx; j++)
			{
				m = pkts_burst[j];
				m->udata64 = rte_get_tsc_cycles();
				rte_prefetch0(rte_pktmbuf_mtod(m, void *));

#ifdef FORWARD
				l2fwd_simple_forward(m, portid);
#endif
#ifdef VLFORWARD
				l2fwd_vl_forward(m);
				// not sure what to do more here...
#endif
#ifdef MCASTVLFORWARD
				l2fwd_mcvl_forward(m);
#endif
			}
		}
	}
}

static int
l2fwd_launch_one_lcore(__attribute__((unused)) void *dummy)
{
	l2fwd_main_loop();
	return 0;
}

/* display usage */
static void
l2fwd_usage(const char *prgname)
{
	printf("%s [EAL options] -- -p PORTMASK [-q NQ]\n"
		   "  -p PORTMASK: hexadecimal bitmask of ports to configure\n"
		   "  -q NQ: number of queue (=ports) per lcore (default is 1)\n"
		   "  -T PERIOD: statistics will be refreshed each PERIOD seconds (0 to disable, 10 default, 86400 maximum)\n",
		   prgname);
}

static int
l2fwd_parse_portmask(const char *portmask)
{
	char *end = NULL;
	unsigned long pm;

	/* parse hexadecimal string */
	pm = strtoul(portmask, &end, 16);
	if ((portmask[0] == '\0') || (end == NULL) || (*end != '\0'))
		return -1;

	if (pm == 0)
		return -1;

	return pm;
}

static unsigned int
l2fwd_parse_nqueue(const char *q_arg)
{
	char *end = NULL;
	unsigned long n;

	/* parse hexadecimal string */
	n = strtoul(q_arg, &end, 10);
	if ((q_arg[0] == '\0') || (end == NULL) || (*end != '\0'))
		return 0;
	if (n == 0)
		return 0;
	if (n >= MAX_RX_QUEUE_PER_LCORE)
		return 0;

	return n;
}

static int
l2fwd_parse_timer_period(const char *q_arg)
{
	char *end = NULL;
	int n;

	/* parse number string */
	n = strtol(q_arg, &end, 10);
	if ((q_arg[0] == '\0') || (end == NULL) || (*end != '\0'))
		return -1;
	if (n >= MAX_TIMER_PERIOD)
		return -1;

	return n;
}

static const char options[] =
	"p:" /* portmask */
	"q:" /* number of queues */
	"T:" /* timer period */
	;

/* Parse the argument given in the command line of the application */
static int
l2fwd_parse_args(int argc, char **argv)
{
	int opt, ret, timer_secs;
	char **argvopt;
	char *prgname = argv[0];

	argvopt = argv;

	while ((opt = getopt(argc, argvopt, options)) != EOF)
	{

		switch (opt)
		{
			/* portmask */
		case 'p':
			l2fwd_enabled_port_mask = l2fwd_parse_portmask(optarg);
			if (l2fwd_enabled_port_mask == 0)
			{
				printf("invalid portmask\n");
				l2fwd_usage(prgname);
				return -1;
			}
			break;

			/* nqueue */
		case 'q':
			l2fwd_rx_queue_per_lcore = l2fwd_parse_nqueue(optarg);
			if (l2fwd_rx_queue_per_lcore == 0)
			{
				printf("invalid queue number\n");
				l2fwd_usage(prgname);
				return -1;
			}
			break;

			/* timer period */
		case 'T':
			timer_secs = l2fwd_parse_timer_period(optarg);
			if (timer_secs < 0)
			{
				printf("invalid timer period\n");
				l2fwd_usage(prgname);
				return -1;
			}
			timer_period = timer_secs;
			break;

		default:
			l2fwd_usage(prgname);
			return -1;
		}
	}

	if (optind >= 0)
		argv[optind - 1] = prgname;

	ret = optind - 1;
	optind = 1; /* reset getopt lib */
	return ret;
}

/* Check the link status of all ports in up to 9s, and print them finally */
static void
check_all_ports_link_status(uint8_t port_num, uint32_t port_mask)
{
#define CHECK_INTERVAL 100 /* 100ms */
#define MAX_CHECK_TIME 90  /* 9s (90 * 100ms) in total */
	uint8_t portid, count, all_ports_up, print_flag = 0;
	struct rte_eth_link link;

	printf("\nChecking link status");
	fflush(stdout);
	for (count = 0; count <= MAX_CHECK_TIME; count++)
	{
		if (force_quit)
			return;
		all_ports_up = 1;
		for (portid = 0; portid < port_num; portid++)
		{
			if (force_quit)
				return;
			if ((port_mask & (1 << portid)) == 0)
				continue;
			memset(&link, 0, sizeof(link));
			rte_eth_link_get_nowait(portid, &link);
			/* print link status if flag set */
			if (print_flag == 1)
			{
				if (link.link_status)
					printf("Port %d Link Up - speed %u "
						   "Mbps - %s\n",
						   (uint8_t)portid,
						   (unsigned)link.link_speed,
						   (link.link_duplex == ETH_LINK_FULL_DUPLEX) ? ("full-duplex") : ("half-duplex\n"));
				else
					printf("Port %d Link Down\n",
						   (uint8_t)portid);
				continue;
			}
			/* clear all_ports_up flag if any link down */
			if (link.link_status == ETH_LINK_DOWN)
			{
				all_ports_up = 0;
				break;
			}
		}
		/* after finally printing all link status, get out */
		if (print_flag == 1)
			break;

		if (all_ports_up == 0)
		{
			printf(".");
			fflush(stdout);
			rte_delay_ms(CHECK_INTERVAL);
		}

		/* set the print_flag if all ports up or timeout */
		if (all_ports_up == 1 || count == (MAX_CHECK_TIME - 1))
		{
			print_flag = 1;
			printf("done\n");
		}
	}
}

static void
signal_handler(int signum)
{
	if (signum == SIGINT || signum == SIGTERM)
	{
		printf("\n\nSignal %d received, preparing to exit...\n",
			   signum);
		force_quit = true;
	}
}

int main(int argc, char **argv)
{
	struct lcore_queue_conf *qconf;
	struct rte_eth_dev_info dev_info;
	int ret;
	uint8_t nb_ports;
	uint8_t nb_ports_available;
	uint8_t portid, last_port;
	uint16_t vlid;
	unsigned lcore_id, rx_lcore_id;
	unsigned nb_ports_in_mask = 0;

	/* init EAL */
	ret = rte_eal_init(argc, argv);
	if (ret < 0)
		rte_exit(EXIT_FAILURE, "Invalid EAL arguments\n");
	argc -= ret;
	argv += ret;

	force_quit = false;
	signal(SIGINT, signal_handler);
	signal(SIGTERM, signal_handler);

	/* parse application arguments (after the EAL ones) */
	ret = l2fwd_parse_args(argc, argv);
	if (ret < 0)
		rte_exit(EXIT_FAILURE, "Invalid L2FWD arguments\n");

	/* convert to number of cycles */
	timer_period *= rte_get_timer_hz();

	/* create the mbuf pool */
	l2fwd_pktmbuf_pool = rte_pktmbuf_pool_create("mbuf_pool", NB_MBUF,
												 MEMPOOL_CACHE_SIZE, 0, RTE_MBUF_DEFAULT_BUF_SIZE,
												 rte_socket_id());
	if (l2fwd_pktmbuf_pool == NULL)
		rte_exit(EXIT_FAILURE, "Cannot init mbuf pool\n");

	nb_ports = rte_eth_dev_count();
	if (nb_ports == 0)
		rte_exit(EXIT_FAILURE, "No Ethernet ports - bye\n");

	/* reset l2fwd_dst_ports */
	for (portid = 0; portid < RTE_MAX_ETHPORTS; portid++)
		l2fwd_dst_ports[portid] = 0;
	/* reset l2fwd_vl_dst_ports */
	for (vlid = 0; vlid < RTE_MAX_VLPORTS; vlid++)
		l2fwd_vl_dst_ports[vlid] = 0;
	#ifdef VLFORWARD
	load_routes("route_vl-fwd.txt");
	#endif
	#ifdef MCASTVLFORWARD
	load_routes("route_vl-mcast.txt");
	# endif 
	last_port = 0;
	/*
	 * Each logical core is assigned a dedicated TX queue on each port.
	 */
	for (portid = 0; portid < nb_ports; portid++)
	{
		/* skip ports that are not enabled */
		if ((l2fwd_enabled_port_mask & (1 << portid)) == 0)
			continue;

		if (nb_ports_in_mask % 2)
		{
			l2fwd_dst_ports[portid] = last_port;
			l2fwd_dst_ports[last_port] = portid;
		}
		else
			last_port = portid;

		nb_ports_in_mask++;

		rte_eth_dev_info_get(portid, &dev_info);
	}
	if (nb_ports_in_mask % 2)
	{
		printf("Notice: odd number of ports in portmask.\n");
		l2fwd_dst_ports[last_port] = last_port;
	}

	rx_lcore_id = 0;
	qconf = NULL;

	/* Initialize the port/queue configuration of each logical core */
	for (portid = 0; portid < nb_ports; portid++)
	{
		/* skip ports that are not enabled */
		if ((l2fwd_enabled_port_mask & (1 << portid)) == 0)
			continue;

		/* get the lcore_id for this port */
		while (rte_lcore_is_enabled(rx_lcore_id) == 0 ||
			   lcore_queue_conf[rx_lcore_id].n_rx_port ==
				   l2fwd_rx_queue_per_lcore)
		{
			rx_lcore_id++;
			if (rx_lcore_id >= RTE_MAX_LCORE)
				rte_exit(EXIT_FAILURE, "Not enough cores\n");
		}

		if (qconf != &lcore_queue_conf[rx_lcore_id])
			/* Assigned a new logical core in the loop above. */
			qconf = &lcore_queue_conf[rx_lcore_id];

		qconf->rx_port_list[qconf->n_rx_port] = portid;
		qconf->n_rx_port++;
		printf("Lcore %u: RX port %u\n", rx_lcore_id, (unsigned)portid);
	}

	nb_ports_available = nb_ports;

	/* Initialise each port */	
	for (portid = 0; portid < nb_ports; portid++)
	{
		/* skip ports that are not enabled */
		if ((l2fwd_enabled_port_mask & (1 << portid)) == 0)
		{
			printf("Skipping disabled port %u\n", (unsigned)portid);
			nb_ports_available--;
			continue;
		}
		/* init port */
		printf("Initializing port %u... ", (unsigned)portid);
		fflush(stdout);
		ret = rte_eth_dev_configure(portid, 1, 1, &port_conf);
		if (ret < 0)
			rte_exit(EXIT_FAILURE, "Cannot configure device: err=%d, port=%u\n",
					 ret, (unsigned)portid);

		rte_eth_macaddr_get(portid, &l2fwd_ports_eth_addr[portid]);
				
		/* init one RX queue */
		fflush(stdout);
		ret = rte_eth_rx_queue_setup(portid, 0, nb_rxd,
									 rte_eth_dev_socket_id(portid),
									 NULL,
									 l2fwd_pktmbuf_pool);
		if (ret < 0)
			rte_exit(EXIT_FAILURE, "rte_eth_rx_queue_setup:err=%d, port=%u\n",
					 ret, (unsigned)portid);

		/* init one TX queue on each port */
		fflush(stdout);
		ret = rte_eth_tx_queue_setup(portid, 0, nb_txd,
									 rte_eth_dev_socket_id(portid),
									 NULL);
		if (ret < 0)
			rte_exit(EXIT_FAILURE, "rte_eth_tx_queue_setup:err=%d, port=%u\n",
					 ret, (unsigned)portid);

		/* Initialize TX buffers */
		tx_buffer[portid] = rte_zmalloc_socket("tx_buffer",
											   RTE_ETH_TX_BUFFER_SIZE(MAX_PKT_BURST), 0,
											   rte_eth_dev_socket_id(portid));
		if (tx_buffer[portid] == NULL)
			rte_exit(EXIT_FAILURE, "Cannot allocate buffer for tx on port %u\n",
					 (unsigned)portid);

		rte_eth_tx_buffer_init(tx_buffer[portid], MAX_PKT_BURST);

		ret = rte_eth_tx_buffer_set_err_callback(tx_buffer[portid],
												 rte_eth_tx_buffer_count_callback,
												 &port_statistics[portid].dropped);
		if (ret < 0)
			rte_exit(EXIT_FAILURE, "Cannot set error callback for "
								   "tx buffer on port %u\n",
					 (unsigned)portid);

		/* Start device */
		ret = rte_eth_dev_start(portid);
		if (ret < 0)
			rte_exit(EXIT_FAILURE, "rte_eth_dev_start:err=%d, port=%u\n",
					 ret, (unsigned)portid);

		printf("done: \n");

		rte_eth_promiscuous_enable(portid);

		printf("Port %u, MAC address: %02X:%02X:%02X:%02X:%02X:%02X\n\n",
			   (unsigned)portid,
			   l2fwd_ports_eth_addr[portid].addr_bytes[0],
			   l2fwd_ports_eth_addr[portid].addr_bytes[1],
			   l2fwd_ports_eth_addr[portid].addr_bytes[2],
			   l2fwd_ports_eth_addr[portid].addr_bytes[3],
			   l2fwd_ports_eth_addr[portid].addr_bytes[4],
			   l2fwd_ports_eth_addr[portid].addr_bytes[5]);

		/* initialize port stats */
		memset(&port_statistics, 0, sizeof(port_statistics));

	}

	if (!nb_ports_available)
	{
		rte_exit(EXIT_FAILURE,
				 "All available ports are disabled. Please set portmask.\n");
	}

	check_all_ports_link_status(nb_ports, l2fwd_enabled_port_mask);

	ret = 0;
	/* launch per-lcore init on every lcore */
	rte_eal_mp_remote_launch(l2fwd_launch_one_lcore, NULL, CALL_MASTER);
	RTE_LCORE_FOREACH_SLAVE(lcore_id)
	{
		if (rte_eal_wait_lcore(lcore_id) < 0)
		{
			ret = -1;
			break;
		}
	}

	for (portid = 0; portid < nb_ports; portid++)
	{
		if ((l2fwd_enabled_port_mask & (1 << portid)) == 0)
			continue;
		printf("Closing port %d...", portid);
		rte_eth_dev_stop(portid);
		rte_eth_dev_close(portid);
		printf(" Done\n");
	}

	free_mcast_routes();

	printf("Bye...\n");

	return ret;
}
