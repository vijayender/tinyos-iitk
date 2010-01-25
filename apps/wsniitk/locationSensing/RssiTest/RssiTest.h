#ifndef RSSITEST_H
#define RSSITEST_H

typedef nx_struct control_msg {
  nx_uint16_t control;
  nx_uint16_t rssi;
  nx_uint16_t abcd[10];
} control_msg_t;

enum {
  AM_RADIO_MSG = 6,
};

#endif
