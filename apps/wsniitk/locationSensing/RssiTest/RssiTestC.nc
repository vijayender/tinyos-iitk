#include "RssiTest.h"

module RssiTestC
{
  uses{
    interface Boot;
    interface Leds;
    interface Receive;
    interface AMSend;
    interface SplitControl as AMControl;
    interface Packet;
    interface Timer<TMilli> as Timer;
    interface PacketField<uint8_t> as PacketRSSI;
  }
}
implementation
{
  message_t packet;
  bool sendRssi = FALSE;
  uint16_t Rssi;

  event void Boot.booted(){
    call AMControl.start();
  }

  event void AMControl.startDone(error_t err){
    if(err == SUCCESS)
      call Leds.led0On();
    else 
      call AMControl.start();
  }

  event void AMControl.stopDone(error_t err)
  {
  }

  event message_t* Receive.receive(message_t* bufPtr, 
				   void* payload, uint8_t len) {
    if (len != sizeof(control_msg_t)) {return bufPtr;}
    else {
      control_msg_t* rcm = (control_msg_t*)payload;
      call Leds.set(rcm->control);
      switch((uint16_t)(rcm->control)){
      case 1:
	//	call Leds.led0Toggle();
	//wait 1 secs and send msg.
	sendRssi = FALSE;
	call Timer.startOneShot(1000);
	break;
      case 2:
	//	call Leds.led1Toggle();
	if( call PacketRSSI.isSet(bufPtr) ){
	  Rssi  = (uint16_t) call PacketRSSI.get(bufPtr);
	}else{
	  Rssi = 0;
	}
	sendRssi = TRUE;
	call Timer.startOneShot(1000);
	break;
	//computer rssi and send to basestation.
      default:
	//	call Leds.led2Toggle();
	//error.
      }
      //      call Leds.led0On();
      return bufPtr;
    }
  }

  event void Timer.fired(){
    control_msg_t* rcm;
    rcm = (control_msg_t*) call Packet.getPayload(&packet,sizeof(control_msg_t));
    if(rcm  != NULL){
      if(sendRssi){
	rcm->control = 3;
	rcm->rssi = Rssi;
      }
      else{
	rcm->control = 2;
	rcm->rssi = 0;
      }
      call AMSend.send(AM_BROADCAST_ADDR,&packet,sizeof(control_msg_t));
    }
  }

  event void AMSend.sendDone(message_t* bufPtr, error_t error) {
  }

}
