/**
 * This module tests the power Switch on mda4X0 board
 * On success red led is blinking and green and yellow leds are constantly on
 */
#include "printf.h"

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
  void debug(char *s, error_t err);

  void debug(char *s, error_t err){
    switch(err){
    case SUCCESS:
      printf("%s: SUCCESS \n",s);
      break;
    case FAIL:
      printf("%s: FAIL \n",s);
      break;
    case EALREADY:
      printf("%s: EALREADY \n",s);
      break;
    case EOFF:
      printf("%s: EOFF \n",s);
      break;
    case EBUSY:
      printf("%s: EBUSY \n",s);
      break;
    default:
      printf("%s:!%d \n",s,err);
    }
  }

  event void Boot.booted(){
    error_t err;
    printf("Hello world\n");
    call Leds.led0Toggle();
    err = call Sht11.start();
    debug("Sht11.start", err);
    printfflush();
  }
  
  event void Sht11.startDone(error_t err){
    debug("Sht11.startDone",err);
    printfflush();
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
    debug("Temperature.readDone", err);
    printf("val:%d\n",val);
    printfflush();
  }

  event void Humidity.readDone(error_t err, uint16_t val){
  }

  event void Sht11.stopDone(error_t err){}
  event void HalSht11Advanced.getVoltageStatusDone(error_t error, bool isLow){
    debug("VOL", error);
    printf("Vol status %d\n",isLow);
    printfflush();
  }
  event void HalSht11Advanced.setHeaterDone(error_t error){}
  event void HalSht11Advanced.setResolutionDone(error_t error){
    debug("resolution",error);
    printfflush();
  }

}
