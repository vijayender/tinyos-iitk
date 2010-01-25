#ifndef RSSITEST_H
#define RSSITEST_H

typedef nx_struct control_msg {
  nx_uint16_t control;
} control_msg_t;

enum {
  AM_RADIO_MSG = 6,
};

#endif
