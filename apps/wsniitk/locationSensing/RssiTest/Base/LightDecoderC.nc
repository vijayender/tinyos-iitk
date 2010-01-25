#include "../RssiTest.h"

module LightDecoder
{
  uses {
    interface Timer<TMilli> as Timer;
    interface Leds;
    interface Boot;
    interface Read<uint16_t> as Photo;
    interface AMSend;
    interface SplitControl as AMControl;
    interface Packet;
  }
}
implementation
{

  message_t packet;
  uint8_t photoValue=0;
  uint8_t pos=0;

  event void Boot.booted()
  {
    call AMControl.start();
  }

  event void AMControl.startDone(error_t err)
  {
    if(err == SUCCESS){
      call Leds.led2Toggle();
      call Timer.startOneShot(1000);
    }else
      call AMControl.start();
  }

  event void AMControl.stopDone(error_t err)
  {
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
	  int moteId = (photoValue==7)?3:4;
	  control_msg_t* rcm;
	  call Leds.set(photoValue);
	  rcm = (control_msg_t*) call Packet.getPayload(&packet,sizeof(control_msg_t));
	  if(rcm  != NULL){
	    rcm->control = 1;
	    call AMSend.send(moteId,&packet,sizeof(control_msg_t));
	  }
	  // END OF CUSTOM CODE
	  photoValue = pos = 0;
	  call Timer.startOneShot(5000);
	}else
	call Timer.startOneShot(1000);
      }else
      call Timer.startOneShot(1000);
    }else
      call Photo.read();
  }

  event void AMSend.sendDone(message_t* bufPtr, error_t error) {
  }

}
