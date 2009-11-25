#include "DataForwarder.h"


interface DataForwarder{
  command void send_data(data_packet_t* data);
  command data_packet_t* getBuffer();
  command uint16_t getBufferLength();
}
