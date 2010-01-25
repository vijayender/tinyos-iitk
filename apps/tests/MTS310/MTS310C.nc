#include "MTS310.h"

module MTS310C @safe()
{

  uses {
    interface Timer<TMilli> as Timer;
    interface Leds;
    interface Boot;
    interface AMSend;
    interface SplitControl as AMControl;
    interface Packet;
    interface Read<uint16_t> as Photo;
    //    interface Read<uint16_t> as Temp;
  }
}
implementation
{
  message_t packet;
  bool locked;		/* lock implies a packet under transmission */

  /* Payload contents */
  uint16_t counter = 0;
  //  uint16_t temperature = 0;
  uint16_t photoIntensity = 0;

  /* Booleans indicating retrieval of all payload contents */
  /* TODO: Optimize this using a union kinda datastructure */
  //  bool tempIndicator = FALSE;
  //  bool photoIndicator = FALSE;

  task void sendPacket();

  event void Boot.booted()
  {

    /* TODO: Start the MTS310  */
    /*    It's done automatically */
    
    call AMControl.start();			  /* Starting radio */
  }

  event void AMControl.startDone(error_t err) {
    if (err == SUCCESS) {
      call Timer.startPeriodic(250);
    }
    else {
      call AMControl.start();
    }
  }

  event void AMControl.stopDone(error_t err) {
    // do nothing
  }
  
  event void Timer.fired()
  {
    call Leds.led1Toggle();
    call Photo.read();
    //   call Temp.read();
    //  post sendPacket();
  }

  task void sendPacket(){
    if (locked ) {	/* return if locked or lack of data */
      return;
    }
    else {
      mts310_msg_t* payload = (mts310_msg_t*)call Packet.getPayload(&packet, sizeof(mts310_msg_t));
      if (payload == NULL) {
	return;
      }
      
      /* Feed data into payload */
      payload->counter = counter++;
      //      payload->temperature = temperature;
      payload->photoIntensity = photoIntensity;
      
      if (call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(mts310_msg_t)) == SUCCESS){	
	//	tempIndicator = FALSE;
	//	photoIndicator = FALSE;
	locked = TRUE;
      }
    }
  }

  event void AMSend.sendDone(message_t* bufPtr, error_t error) {
    if (&packet == bufPtr) {
      locked = FALSE;
    }
  }
  
  event void Photo.readDone(error_t ok, uint16_t val) {
    if (ok == SUCCESS){
      photoIntensity = val;
      //     photoIndicator = TRUE;
       post sendPacket(); 
    }else
      call Photo.read();
  }
  
  /*  event void Temp.readDone(error_t ok, uint16_t val) {
    if (ok == SUCCESS){
      temperature = val;
      tempIndicator = TRUE;
      // post sendPacket();
    }else
      call Temp.read();
      }*/
}