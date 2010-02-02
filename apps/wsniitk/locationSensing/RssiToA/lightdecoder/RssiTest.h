#ifndef RSSITEST_H
#define RSSITEST_H

typedef nx_struct command_msg {
  nx_uint16_t control;
} command_msg_t;

enum {
  AM_RADIO_MSG = 9,
};

#endif
