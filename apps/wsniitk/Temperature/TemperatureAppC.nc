

configuration TemperatureAppC
{
}

implementation
{
  components MainC, TemperatureC as App, LedsC;
  components new TimerMilliC() as light_Timer;
  
  components new TempC();

  App -> MainC.Boot;
  App.Timer -> light_Timer;
  App.Leds -> LedsC;
  App.Temp -> TempC;
}