#include <HplRF230.h>
#include "../RssiToA.h"

module mote2C {
  uses {
    interface Leds;
    interface Boot;
    interface Receive;
    interface AMSend;
    interface Timer<TMilli>;
    interface Timer<TMilli> as Timer2;
    interface SplitControl as AMControl;
    interface PacketTimeStamp<TRF230, uint32_t> as PacketTimeStampRadio;
    interface Packet;
    interface PacketField<uint8_t> as PacketRSSI;
    //    interface PacketField<uint8_t> as PacketTransmitPower;
    interface PacketField<uint8_t> as PacketLinkQuality;
    interface PacketAcknowledgements;
    interface Read<uint16_t> as Voltage;
  }
}
implementation {
  uint8_t rssi;
  //  uint8_t tx_pwr;
  uint8_t lqi;
  uint8_t retr;
  uint16_t v;
  message_t packet;
  uint32_t tx_tmsp;
  uint32_t rx_tmsp;

  event void Boot.booted(){
    call AMControl.start();
  }

  event void AMControl.startDone(error_t err){
    if(err == SUCCESS){
      call Leds.led0On();
    } else 
      call AMControl.start();
  }

  event void AMControl.stopDone(error_t err){
  }

  event void Timer.fired(){
    control_msg_t* rcm;
    call Leds.led0Toggle();

    rcm = (control_msg_t*) call Packet.getPayload(&packet,sizeof(control_msg_t));
    if(rcm  != NULL){
      rcm->rssi = rssi;
      rcm->lqi = lqi;
      //      rcm->tx_pwr = tx_pwr;
      rcm->tx_tmsp = tx_tmsp;
      rcm->rx_tmsp = rx_tmsp;
      rcm->v = v;
      rcm->retr = retr;
      call PacketAcknowledgements.requestAck(&packet);
      retr = 0;
      call AMSend.send(3,&packet,sizeof(control_msg_t));
    }
    // counter++; Shall be done in Send Done
  }
  
  event void AMSend.sendDone(message_t* bufPtr, error_t error) {
    if(call PacketAcknowledgements.wasAcked(bufPtr)){
      tx_tmsp = call PacketTimeStampRadio.timestamp(bufPtr);
      //      tx_pwr = call PacketTransmitPower.get(bufPtr);
    }else {
      if(retr < MAXRETRIES){
	retr++;
	call Timer2.startOneShot(10);
      }
    }
  }

  event void Timer2.fired(){
    call PacketAcknowledgements.requestAck(&packet);
    call AMSend.send(3,&packet,sizeof(control_msg_t));
  }

  event message_t* Receive.receive(message_t* bufPtr, 
				   void* payload, uint8_t len) {
    if (len != sizeof(control_msg_t)) {return bufPtr;}
    else {
      rx_tmsp = call PacketTimeStampRadio.timestamp(bufPtr);
      rssi = call PacketRSSI.get(bufPtr);
      lqi = call PacketLinkQuality.get(bufPtr);
      
      //call Leds.led1Toggle();
      call Voltage.read();
      //      call Timer.startOneShot(100);
      return bufPtr;
    }
  }

  event void Voltage.readDone(error_t err, uint16_t result){
    v = result;
    call Timer.startOneShot(100);
  }
}

