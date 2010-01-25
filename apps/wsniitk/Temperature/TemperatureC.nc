#include "/usr/avr/include/math.h"

module TemperatureC
{
  uses {
    interface Timer<TMilli> as Timer;
    interface Leds;
    interface Boot;
    interface Read<uint16_t> as Temp;
  }
}
implementation
{
  uint16_t temperature=0;
  int8_t pos=-1;

  event void Boot.booted()
  {
    call Leds.led2Toggle();
    call Timer.startOneShot(1000);
  }

  void setLeds(int val){
    (val&1)?call Leds.led0On():call Leds.led0Off();
    (val&2)?call Leds.led1On():call Leds.led1Off();
    (val&4)?call Leds.led2On():call Leds.led2Off();
  }

  event void Timer.fired(){
    if(pos == -1){
      call Leds.led2Toggle();
            call Temp.read();
      //      temperature = 12;
      //pos = 0;
      //call Timer.startOneShot(1000);
    }else{
      int val;
      if(pos == 12){
	pos = -1;
	setLeds(7);
	call Timer.startOneShot(5000);
	return;
      }
      if(pos%2){
	val = 0x07 & (temperature>>((pos++/2)*3));
	setLeds(val);
	call Timer.startOneShot(2000);
      }else{
	pos++;
	setLeds(7);
	call Timer.startOneShot(100);
      }
    }
  }

  event void Temp.readDone(error_t ok, uint16_t val) {
    if (ok == SUCCESS){
      //      double Rthr;
      //      Rthr = log(10*1000*(float)(1023-val)/val);
      //      temperature = (int)(1.0/(0.00130705+0.000214381*Rthr+0.000000093*Rthr*Rthr*Rthr) );
      call Leds.led1Toggle();
      temperature = val;
      pos = 0;
      call Timer.startOneShot(1000);
    }else
      call Temp.read();
  }
}