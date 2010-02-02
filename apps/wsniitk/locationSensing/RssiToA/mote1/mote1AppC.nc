#include "../RssiToA.h"
#include "../lightdecoder/RssiTest.h"
#include "StorageVolumes.h"

configuration mote1AppC {}

implementation {
  components MainC, mote1C as App, LedsC;
  components new AMSenderC(AM_CONTROL_MSG);
  components new AMReceiverC(AM_CONTROL_MSG);
  components new AMReceiverC(AM_RADIO_MSG) as controller;
  components new AMSenderC(AM_RADIO_MSG) as pcCommunicator;
  components new TimerMilliC();
  components new TimerMilliC() as Timer2;
  components new VoltageC();
  components ActiveMessageC;
  components RF230ActiveMessageC;
  
  App.Boot -> MainC.Boot;
  App.Receive -> AMReceiverC;
  App.AMSend -> AMSenderC;
  App.AMControl -> ActiveMessageC;
  App.Leds -> LedsC;
  App.Timer -> TimerMilliC;
  App.Timer2 -> Timer2;
  App.Packet -> AMSenderC;
  App.pcCommunicator -> pcCommunicator;
  App.PacketTimeStampRadio -> RF230ActiveMessageC.PacketTimeStampRadio;
  App.PacketRSSI -> RF230ActiveMessageC.PacketRSSI;
  App.PacketAcknowledgements -> RF230ActiveMessageC;
  App.controller -> controller;
  //  App.PacketTransmitPower -> RF230ActiveMessageC.PacketTransmitPower;
  App.PacketLinkQuality -> RF230ActiveMessageC.PacketLinkQuality;
  App.Voltage -> VoltageC;

  components new LogStorageC(VOLUME_LOGTEST, FALSE);
  App.LogRead -> LogStorageC;
  App.LogWrite -> LogStorageC;
}