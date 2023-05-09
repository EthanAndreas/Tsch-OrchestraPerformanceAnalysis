/**
 * \file
 *         A RPL+TSCH node acting as a UDP src
 */

#include "stdlib.h"
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
#define SIZE_STR 32
#define SEND_INTERVAL 10

#define DEBUG DEBUG_PRINT
#include "net/ipv6/uip-debug.h"

static struct simple_udp_connection udp_conn;

clock_time_t pings[1000];
static unsigned count;

/*---------------------------------------------------------------------------*/
PROCESS(node_process, "UDP SRC");
AUTOSTART_PROCESSES(&node_process);

/*---------------------------------------------------------------------------*/

static void udp_rx_callback(struct simple_udp_connection *c,
                            const uip_ipaddr_t *sender_addr,
                            uint16_t sender_port,
                            const uip_ipaddr_t *receiver_addr,
                            uint16_t receiver_port,
                            const uint8_t *data,
                            uint16_t datalen)
{

  LOG_INFO("Received response '%.*s' from ", datalen, (char *)data);
  LOG_INFO_6ADDR(sender_addr);
  int count_value = atoi((const char *)data + 6);
  pings[count_value] = clock_time() - pings[count_value];
  char str[1000];
  snprintf(str, 1000, "--> With %d of ping (%d) \n", (int)pings[count_value], CLOCK_SECOND);
  LOG_INFO_(str);
  while (!PROCESS_WAIT_EVENT_UNTIL(etimer_expired(&periodic_timer)) && !NETSTACK_ROUTING.get_root_ipaddr(&dest_ipaddr))

    PROCESS_WAIT_EVENT_UNTIL(etimer_expired(&periodic_timer));

  LOG_INFO("Sending request %u to ", count);
  LOG_INFO("\n");
  snprintf(str, SIZE_STR, "hello %d", count);
  simple_udp_sendto(&udp_conn, str, strlen(str), &dest_ipaddr);
  pings[count] = clock_time();
  count++;
}

PROCESS_THREAD(node_process, ev, data)
{
  static struct etimer periodic_timer;
  static char str[SIZE_STR];
  uip_ipaddr_t dest_ipaddr;

  PROCESS_BEGIN();

  NETSTACK_MAC.on();

  clock_init();

  // init UDP connection
  simple_udp_register(&udp_conn, UDP_CLIENT_PORT, NULL,
                      UDP_SERVER_PORT, udp_rx_callback);

  // set the periodic timer to send UDP datagram
  etimer_set(&periodic_timer, /*random_rand () %*/ SEND_INTERVAL);

  while (!PROCESS_WAIT_EVENT_UNTIL(etimer_expired(&periodic_timer)) && !NETSTACK_ROUTING.get_root_ipaddr(&dest_ipaddr))

    PROCESS_WAIT_EVENT_UNTIL(etimer_expired(&periodic_timer));

  LOG_INFO("Sending request %u to ", count);
  LOG_INFO("\n");
  snprintf(str, SIZE_STR, "hello %d", count);
  simple_udp_sendto(&udp_conn, str, strlen(str), &dest_ipaddr);
  pings[count] = clock_time();
  count++;


  PROCESS_END();
}
/*---------------------------------------------------------------------------*/
