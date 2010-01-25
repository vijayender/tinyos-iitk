#include "MTS310.h"

configuration MTS310AppC
{
}
implementation
{
  components MainC, MTS310C as App, LedsC;
  components new TimerMilliC() as Timer;
  components new AMSenderC(AM_RADIO_COUNT_MSG);
  components ActiveMessageC;
  

  App -> MainC.Boot;
  App.Timer -> Timer;
  App.Leds -> LedsC;
  App.AMSend -> AMSenderC;
  App.Packet -> AMSenderC;
  App.AMControl -> ActiveMessageC;


  /* Wiring sensors onboard MTS310 */
  components new PhotoC();//, new TempC();
  App.Photo -> PhotoC;
  //  App.Temp -> TempC;
}
