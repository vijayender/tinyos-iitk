
#ifndef MTS310_H
#define MTS310_H

typedef nx_struct mts310_msg {
  nx_uint16_t counter;
  //  nx_uint16_t temperature;
  nx_uint16_t photoIntensity;
} mts310_msg_t;

enum {
  AM_RADIO_COUNT_MSG = 6,
};

#endif
