#include "../RssiToA.h"

configuration mote1AppC {}

implementation {
  components MainC, mote1C as App, LedsC;
  components new AMSenderC(AM_CONTROL_MSG);
  components new AMReceiverC(AM_CONTROL_MSG);
  components new TimerMilliC();
  components new VoltageC();
  components ActiveMessageC;
  components  RF230ActiveMessageC;
  
  App.Boot -> MainC.Boot;
  
  App.Receive -> AMReceiverC;
  App.AMSend -> AMSenderC;
  App.AMControl -> ActiveMessageC;
  App.Leds -> LedsC;
  App.Timer -> TimerMilliC;
  App.Packet -> AMSenderC;
  App.PacketTimeStampRadio -> RF230ActiveMessageC.PacketTimeStampRadio;
  App.PacketRSSI -> RF230ActiveMessageC.PacketRSSI;
  App.PacketAcknowledgements -> RF230ActiveMessageC;
  //  App.PacketTransmitPower -> RF230ActiveMessageC.PacketTransmitPower;
  App.PacketLinkQuality -> RF230ActiveMessageC.PacketLinkQuality;
  App.Voltage -> VoltageC;
}