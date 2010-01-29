/**
 * This module tests the power Switch on mda4X0 board
 * On success red led is blinking and green and yellow leds are constantly on
 */


module humidityC
{
  uses
  {
    interface Leds;

    interface Timer<TMilli> as Timer0;
    interface SplitControl as Sht11;
    interface Read<uint16_t> as Temperature;
    interface Read<uint16_t> as Humidity;
    interface HalSht11Advanced;

    interface Boot;
  }
}

implementation
{
  uint16_t value = 0;
  event void Boot.booted(){
    call Leds.led0Toggle();
    call Sht11.start();
  }
  
  event void Sht11.startDone(error_t err){
    if(err == SUCCESS){
      call Leds.led0Toggle();
      call Timer0.startPeriodic(1000);
    } else {
      //report error
    }
  }

  event void Timer0.fired(){
    call Temperature.read();
  }
  
  event void Temperature.readDone(error_t err, uint16_t val){
    switch(err){
    case EOFF:
      call Leds.led1On();
      call Leds.led2Off();
      call Leds.led0Off();
      break;
    case EBUSY:
      call Leds.led2On();
      call Leds.led1Off();
      call Leds.led0Off();
      break;
    case FAIL:
      call Leds.led0On();
      call Leds.led1Off();
      call Leds.led2Off();
      break;
    default :
      call Leds.led1On();
      call Leds.led2On();
      call Leds.led0Off();
    }
  }

  event void Humidity.readDone(error_t err, uint16_t val){
  }

  event void Sht11.stopDone(error_t err){}
  event void HalSht11Advanced.getVoltageStatusDone(error_t error, bool isLow){}
  event void HalSht11Advanced.setHeaterDone(error_t error){}
  event void HalSht11Advanced.setResolutionDone(error_t error){}

}
