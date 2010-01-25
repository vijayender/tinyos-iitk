

configuration LightDecoderAppC
{
}

implementation
{
  components MainC, LightDecoderC as App, LedsC;
  components new TimerMilliC() as light_Timer;
  
  components new PhotoC();

  App -> MainC.Boot;
  App.Timer -> light_Timer;
  App.Leds -> LedsC;
  App.Photo -> PhotoC;
}