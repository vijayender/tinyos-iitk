
#include <HplRF230.h>
#include "../RssiToA.h"
#define NUM 10

module mote1C {
  uses {
    interface Leds;
    interface Boot;
    interface Receive;
    interface AMSend;
    interface Timer<TMilli>;
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
  uint16_t counter = 0, counter2 = 0;
  message_t packet;
  uint32_t tx_tmsp;
  uint32_t rx_tmsp;
  uint32_t tx_tms[2][NUM+1];  //0 stands for message from mote1 -> mote2
  uint32_t rx_tms[2][NUM+1];  //1 stands for message from mote2 -> mote1
  uint8_t rssi[2][NUM+1];
  uint16_t v[2][NUM+1];
  uint8_t lqi[2][NUM+1];
  //  uint8_t tx_pwr[2][NUM+1];
  bool rssiTransport = FALSE;
  
  task void sendData();

  event void Boot.booted(){
    call AMControl.start();
  }

  event void AMControl.startDone(error_t err){
    if(err == SUCCESS){
      call Timer.startOneShot(1000);
      call Leds.led0On();
    } else 
      call AMControl.start();
  }
  
  event void AMControl.stopDone(error_t err){
  }

  event void Timer.fired(){
    if(rssiTransport){
      post sendData();
      return;
    }
    if(counter < NUM){
      control_msg_t* rcm;
      call Leds.led0Toggle();

      rcm = (control_msg_t*) call Packet.getPayload(&packet,sizeof(control_msg_t));
      if(rcm  != NULL){
	rcm->counter = counter;
	call PacketAcknowledgements.requestAck(&packet);
	call AMSend.send(4,&packet,sizeof(control_msg_t));
	//	call Leds.led1Toggle();
      }
      // counter++; Shall be done in Send Done
    }else{
      rssiTransport = TRUE;
      post sendData();
      //Send data to PC
      call Leds.set(0);
    }
  }

  task void sendData(){
    if(counter2 < 2*NUM){
      control_msg_t* rcm;
      rcm = (control_msg_t*) call Packet.getPayload(&packet,sizeof(control_msg_t));
      if(rcm  != NULL){
	int i,j;
	i = counter2/NUM;
	j = counter2%NUM;
	rcm->counter = counter2;
	rcm->rssi = rssi[i][j];
	rcm->rx_tmsp = rx_tms[i][j];
	rcm->tx_tmsp = tx_tms[i][j];
	rcm->v = v[i][j];
	//	rcm->tx_pwr = tx_pwr[i][j];
	rcm->lqi = lqi[i][j];
	call Leds.led1Toggle();
	counter2++;
	call AMSend.send(1,&packet,sizeof(control_msg_t));
      }
    }else{
      call Leds.led0On();
    }
  }

  event void AMSend.sendDone(message_t* bufPtr, error_t error) {
    if(rssiTransport) call Timer.startOneShot(50);
    else{
      if(call PacketAcknowledgements.wasAcked(bufPtr)){
	tx_tmsp = call PacketTimeStampRadio.timestamp(bufPtr);
	//	tx_pwr[0][counter] = call PacketTransmitPower.get(bufPtr);
	tx_tms[0][counter]=tx_tmsp;
	//call Leds.led2Toggle();
      }else{
	call PacketAcknowledgements.requestAck(&packet);
	call AMSend.send(4,&packet,sizeof(control_msg_t));
      }
    }
  }

  event message_t* Receive.receive(message_t* bufPtr, 
				   void* payload, uint8_t len) {
    if (len != sizeof(control_msg_t)) {return bufPtr;}
    else {
      control_msg_t* rcm = (control_msg_t*)payload;
      rx_tms[0][counter] = rcm->rx_tmsp;
      rssi[0][counter] = rcm->rssi;
      lqi[0][counter] = rcm->lqi;
      v[1][counter] = rcm->v;
      rx_tmsp = call PacketTimeStampRadio.timestamp(bufPtr);
      rx_tms[1][counter] = rx_tmsp;
      if(counter>0){
	tx_tms[1][counter-1] = rcm->tx_tmsp;
	//	tx_pwr[1][counter-1] = rcm->tx_pwr;
      }
      rssi[1][counter] = call PacketRSSI.get(bufPtr);
      lqi[1][counter] = call PacketLinkQuality.get(bufPtr);
      counter++;
      //call Leds.led1Toggle();
      call Voltage.read();
      //call Timer.startOneShot(100);
      return bufPtr;
    }
  }

  event void Voltage.readDone(error_t err, uint16_t result){
    v[0][counter] = result;
    call Timer.startOneShot(100);
  }
}
