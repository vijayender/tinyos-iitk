

module LightDecoder
{
  uses {
    interface Timer<TMilli> as Timer;
    interface Leds;
    interface Boot;
    interface Read<uint16_t> as Photo;
  }
}
implementation
{
  uint8_t photoValue=0;
  uint8_t pos=0;

  event void Boot.booted()
  {
    call Leds.led2Toggle();
    call Timer.startOneShot(1000);
  }
  
  event void Timer.fired(){
    call Leds.led2Toggle();
    call Photo.read();
  }

  event void Photo.readDone(error_t ok, uint16_t val) {
    if (ok == SUCCESS){
      photoValue = photoValue | ((val<768) << pos);
      if(val<768)
	call Leds.led1On();
      else
	call Leds.led1Off();
      if(photoValue){
	if(pos++ == 2){
	  // CALL YOUR CODE FROM HERE.
	  call Leds.set(photoValue);
	  photoValue = pos = 0;
	  call Timer.startOneShot(5000);
	}else
	call Timer.startOneShot(1000);
      }else
      call Timer.startOneShot(1000);
    }else
      call Photo.read();
  }
}