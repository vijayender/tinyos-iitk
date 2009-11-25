#include "Timer.h"

interface SensorMonitor{
  command void read_once(uint16_t version);

  command void read_stream(uint32_t usPeriod, uint16_t count, uint16_t version);
  
  command void read_to_oscilloscope(uint32_t usPeriod, uint16_t version);

  command void stop();
}