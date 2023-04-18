/**
 * \file
 *         A RPL+TSCH node acting as a DAG Root and waiting for UDP
 *         datagrams
 */

#include "contiki.h"
#include "sys/node-id.h"
#include "sys/log.h"
#include "net/ipv6/uip-ds6-route.h"
#include "net/ipv6/uip-sr.h"
#include "net/mac/tsch/tsch.h"
#include "net/routing/routing.h"

// - BEGIN JUL
#include "random.h"
#include "net/netstack.h"
#include "net/ipv6/simple-udp.h"
// - FIN JUL

#define LOG_MODULE "App"
#define LOG_LEVEL LOG_LEVEL_INFO
#define UDP_CLIENT_PORT 8765
#define UDP_SERVER_PORT 5678
#define WITH_SERVER_REPLY 1

#define DEBUG DEBUG_PRINT
#include "net/ipv6/uip-debug.h"

static struct simple_udp_connection udp_conn;

/*---------------------------------------------------------------------------*/
PROCESS (node_process, "UDP DST");
AUTOSTART_PROCESSES (&node_process);

/*---------------------------------------------------------------------------*/

static void udp_rx_callback (struct simple_udp_connection *c,
			     const uip_ipaddr_t *sender_addr,
			     uint16_t sender_port,
			     const uip_ipaddr_t *receiver_addr,
			     uint16_t receiver_port,
			     const uint8_t *data,
			     uint16_t datalen)
{

  LOG_INFO ("Received request '%.*s' from ", datalen, (char *) data);
  LOG_INFO_6ADDR (sender_addr);
  LOG_INFO_ ("\n");
#if WITH_SERVER_REPLY
  LOG_INFO("sending response\n");
  simple_udp_sendto (&udp_conn, data, datalen, sender_addr);
#endif /* WITH_SERVER_REPLY */
}

PROCESS_THREAD (node_process, ev, data)
{
  PROCESS_BEGIN ();

  // the coordinator starts building the network
  NETSTACK_ROUTING.root_start ();
  NETSTACK_MAC.on ();

  // init UDP connection
  simple_udp_register (&udp_conn, UDP_SERVER_PORT, NULL,
		       UDP_CLIENT_PORT, udp_rx_callback);

  PROCESS_END ();
}
/*---------------------------------------------------------------------------*/
