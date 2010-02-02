#ifndef RSSITOA_H
#define RSSITOA_H

typedef nx_struct control_msg {
  nx_uint16_t counter;
  nx_uint32_t tx_tmsp;
  nx_uint32_t rx_tmsp;
  nx_uint8_t rssi;
  nx_uint8_t lqi;
  nx_uint8_t retr;
  //  nx_uint8_t tx_pwr;
  nx_uint16_t v;
  nx_uint16_t tmp[5];
} control_msg_t;

enum {
  AM_CONTROL_MSG = 6,
};

#endif
