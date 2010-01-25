#include "RssiTest.h"

configuration RssiTestAppC
{
}
implementation
{
  components MainC,RssiTestC as App, LedsC;
  components new TimerMilliC() as Timer;
  components new AMSenderC(AM_RADIO_MSG);
  components new AMReceiverC(AM_RADIO_MSG);
  components ActiveMessageC;
  components  RF230ActiveMessageC;

  App -> MainC.Boot;
  App.Timer -> Timer;
  App.Leds -> LedsC;
  App.AMSend -> AMSenderC;
  App.Packet -> AMSenderC;
  App.Receive -> AMReceiverC;
  App.AMControl -> ActiveMessageC;
  App.PacketRSSI -> RF230ActiveMessageC.PacketRSSI;
}