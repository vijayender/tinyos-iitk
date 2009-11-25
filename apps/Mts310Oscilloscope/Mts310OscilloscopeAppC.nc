#include "Mts310Oscilloscope.h"
#include "DataForwarder.h"

/* You can straight away wire the SensorMts300C() */
configuration Mts310OscilloscopeAppC
{
}

implementation
{
  components Mts310OscilloscopeC, SensorMonitorC, DataForwarderC, new QueueC(data_packet_t *, 10), new PoolC(data_packet_t, 10), 
    new DemoSensorC() as Read, new DemoSensorStreamC() as ReadStream,
    ActiveMessageC, new AMSenderC(10) as control_send, new AMSenderC(11) as error_send, new AMReceiverC(12) as control_receive,
    new AMSenderC(13) as data_send, MainC, new TimerMilliC() as Timer, ErrorReportC, LedsC, new QueueC(uint8_t, 10) as Queue_uint8;

  Mts310OscilloscopeC.Boot -> MainC;
  Mts310OscilloscopeC.RadioControl -> ActiveMessageC;
  Mts310OscilloscopeC.Receive -> control_receive;
  Mts310OscilloscopeC.AMSend -> control_send;
  Mts310OscilloscopeC.ErrorReport -> ErrorReportC;
  Mts310OscilloscopeC.SensorMonitor -> SensorMonitorC;

  DataForwarderC.AMSend -> data_send;
  DataForwarderC.PacketAcknowledgements -> ActiveMessageC;
  DataForwarderC.Queue -> QueueC;
  DataForwarderC.Pool -> PoolC;
  DataForwarderC.ErrorReport -> ErrorReportC;
  
  SensorMonitorC.Read -> Read;
  SensorMonitorC.ReadStream -> ReadStream;
  SensorMonitorC.Timer -> Timer;
  SensorMonitorC.ErrorReport -> ErrorReportC;
  SensorMonitorC.DataForwarder -> DataForwarderC;

  ErrorReportC.Send_error -> error_send;
  ErrorReportC.PacketAcknowledgements -> ActiveMessageC;
  ErrorReportC.Leds -> LedsC;
  ErrorReportC.error_queue -> Queue_uint8;
}