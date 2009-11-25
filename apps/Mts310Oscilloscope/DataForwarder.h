#ifndef DATAFORWARDER_H
#define DATAFORWARDER_H

#define ADDR_BASESTATION 10
#define TOSH_DATA_LENGTH 50
#define MAX_RETRYCOUNT 10

#define NREADINGS 20 //28 - 2*2
typedef struct data_packet {
  uint16_t id;
  uint8_t from_device;
  uint8_t type;
  uint16_t count;
  uint16_t readings;
  uint16_t version;
  uint16_t data[NREADINGS];
} data_packet_t;


#endif
