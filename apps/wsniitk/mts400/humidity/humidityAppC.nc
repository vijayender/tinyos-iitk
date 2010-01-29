configuration humidityAppC
{
}

implementation
{
  components humidityC as App, MainC, LedsC, new TimerMilliC();
  App -> MainC.Boot;
  App.Leds -> LedsC;
  App.Timer0 -> TimerMilliC;
  
  components new SensirionSht11C() as Sht11;
  App.Temperature -> Sht11.Humidity;
  App.Humidity -> Sht11.Temperature;
  App.HalSht11Advanced -> Sht11.HalSht11Advanced;
  App.Sht11 -> Sht11.SplitControl;
  
  
}
