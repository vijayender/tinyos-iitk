
#include <HplRF230.h>
#include "../RssiToA.h"
#include "../lightdecoder/RssiTest.h"
#define NUM 10

module mote1C {
  uses {
    interface Leds;
    interface Boot;
    interface Receive;
    interface Receive as controller;
    interface AMSend;
    interface AMSend as pcCommunicator;
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
    interface LogWrite;
    interface LogRead;
  }
}
implementation {
  typedef nx_struct logentry {
    nx_uint8_t toa;
    nx_uint8_t rssi[2];
    nx_uint8_t lqi[2];
    nx_uint8_t retr[2];
    nx_uint16_t v[2];
  } logentry_t;

  typedef nx_struct pcentry {
    nx_uint32_t counter;
    nx_uint8_t toa;
    nx_uint8_t rssi[2];
    nx_uint8_t lqi[2];
    nx_uint8_t retr[2];
    nx_uint16_t v[2];
  } pcentry_t;

  uint16_t counter = 0, counter2 = 0;
  message_t packet;
  uint32_t pcentrycounter = 0;
  uint32_t tx_tmsp;
  uint32_t rx_tmsp;
  uint32_t tx_tms[2][NUM+1];  //0 stands for message from mote1 -> mote2
  uint32_t rx_tms[2][NUM+1];  //1 stands for message from mote2 -> mote1
  uint8_t rssi[2][NUM+1];
  uint16_t v[2][NUM+1];
  uint8_t lqi[2][NUM+1];
  uint8_t retr[2][NUM+1];
  bool rssiTransport = FALSE;
  bool packetInTransmission = FALSE;
  logentry_t m_entry;
  pcentry_t pc_entry;
  bool busy = FALSE;
  bool logAvailable = TRUE;
  

  task void sendData();
  task void dumpData();
  task void eofData();
  void checkErr(error_t err);
  
  event void Boot.booted(){
    call AMControl.start();
  }

  event void AMControl.startDone(error_t err){
    if(err == SUCCESS){
      //      call Timer.startOneShot(1000);
      call Leds.led0On();
    } else 
      call AMControl.start();
  }
  
  event void AMControl.stopDone(error_t err){
  }

  event void Timer.fired(){
    //    printf("timer fired");
    call Leds.led2Off();
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
	retr[0][counter] = 0;
	packetInTransmission = TRUE;
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
    int toa;
    if(counter2 < NUM){
      call Leds.led1Toggle();
      //Compute the data and print using printf
      toa = tx_tms[0][counter2]-rx_tms[0][counter2]+tx_tms[1][counter2]-rx_tms[1][counter2];
      /*printf("Data counter %d, toa %d, rssi %d~%d, lqi %d~%d, retr %d~%d, v %d~%d \n",counter2,toa,
	     rssi[0][counter2],rssi[1][counter2],
	     lqi[0][counter2],lqi[1][counter2],
	     retr[0][counter2],retr[1][counter2],
	     v[0][counter2],v[1][counter2]);
	     printfflush();*/
      if(toa > 0 && toa <100)
	m_entry.toa = toa;
      else
	m_entry.toa = 0xff;
      m_entry.rssi[0] = rssi[0][counter2];
      m_entry.rssi[1] = rssi[1][counter2];
      m_entry.lqi[0] = lqi[0][counter2];
      m_entry.lqi[1] = lqi[1][counter2];
      m_entry.retr[0] = retr[0][counter2];
      m_entry.retr[1] = retr[1][counter2];
      m_entry.v[0] = v[0][counter2];
      m_entry.v[1] = v[1][counter2];
      if(call LogWrite.append(&m_entry,sizeof(logentry_t)) != SUCCESS)
	//post errorLeds();
	call Leds.set(LEDS_LED2|LEDS_LED1|LEDS_LED0);
      counter2++;
      //call Timer.startOneShot(100);
      /*control_msg_t* rcm;
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
	rcm->retr =retr[i][j];
	call Leds.led1Toggle();
	counter2++;
	call AMSend.send(1,&packet,sizeof(control_msg_t));
	}*/
    }else{
      //Get ready for next round
      call LogWrite.sync();
      counter=0;counter2=0;rssiTransport=FALSE;
    }
  }

  event void AMSend.sendDone(message_t* bufPtr, error_t error) {
    packetInTransmission = FALSE;
    if(rssiTransport) call Timer.startOneShot(50);
    else{
      if(call PacketAcknowledgements.wasAcked(bufPtr)){
	call Timer2.startOneShot(4000);
	tx_tmsp = call PacketTimeStampRadio.timestamp(bufPtr);
	tx_tms[0][counter]=tx_tmsp;
      }else{
	if(retr[0][counter] < MAXRETRIES){
	  retr[0][counter]++;
	  call Timer2.startOneShot(10);
	}else{
	  //give up and update false values
	  tx_tms[0][counter]=0xffffffff;
	  rx_tms[0][counter] = 0xffffffff;
	  rssi[0][counter] = 0xff;
	  lqi[0][counter] = 0xff;
	  v[1][counter] = 0xffff;
	  rx_tms[1][counter] = 0xffffffff;
	  retr[1][counter] = 0xff;
	  if(counter>0){
	    tx_tms[1][counter-1] = 0xffffffff;
	  }
	  rssi[1][counter] = 0xff;
	  lqi[1][counter] = 0xff;
	  counter++;
	  call Voltage.read();
	}
      }
    }
  }

  event void Timer2.fired(){
    if(packetInTransmission){
      //Reached here impiles the other side failed to transmit even after number of trials
      //Store 0xFF in place of rssi for the failed transmission.
      rx_tms[0][counter] = 0xffffffff;
      rssi[0][counter] = 0xff;
      lqi[0][counter] = 0xff;
      v[1][counter] = 0xffff;
      rx_tms[1][counter] = 0xffffffff;
      retr[1][counter] = 0xff;
      if(counter>0){
	tx_tms[1][counter-1] = 0xffffffff;
      }
      rssi[1][counter] = 0xff;
      lqi[1][counter] = 0xff;
      counter++;
      call Voltage.read();
    }else{
      call PacketAcknowledgements.requestAck(&packet);
      packetInTransmission = TRUE;
      call AMSend.send(4,&packet,sizeof(control_msg_t));
    }
  }

  event message_t* controller.receive(message_t* bufPtr, void* payload, uint8_t len){
    if(busy)
      return bufPtr;
    if (len!= sizeof(command_msg_t)){
      return bufPtr;
    }else{
      //TODO: check if busy
      command_msg_t* rcm = (command_msg_t*)payload;
      switch (rcm->control){
      case 1://Command from the lightdecoder mote
	busy = TRUE;
	call Timer.startOneShot(1000);	
	break;
      case 2://Command from the pc saying hello
	call Leds.set(LEDS_LED2);
	break;
      case 3://Command from the pc saying erase all log
	call Leds.set(LEDS_LED1);
	busy = TRUE;
	if(call LogWrite.erase() != SUCCESS)
	  call Leds.set(LEDS_LED1|LEDS_LED2|LEDS_LED0);
	break;
      case 4://Command from the pc saying retreive all log
	call Leds.set(LEDS_LED1|LEDS_LED2);
	busy = TRUE;
	logAvailable = TRUE;
	post dumpData();
	break;
      default:
	//	printf("Shouldn't be here\n");
      }
      return bufPtr;
    }
  }

  task void dumpData(){
    //printf("size %d\n",(int)sizeof(logentry_t));
    //printfflush();
    if (call LogRead.read(&m_entry, sizeof(logentry_t)) != SUCCESS){
      call Leds.set(LEDS_LED2|LEDS_LED1|LEDS_LED0);
      //EOF
      post eofData();
    }
  }

  task void eofData(){
    pcentry_t* rcm;
    rcm = (pcentry_t*) call Packet.getPayload(&packet, sizeof(pcentry_t));
    logAvailable = FALSE;
    if(rcm != NULL){
      rcm->v[1] = 0;
      call pcCommunicator.send(1,&packet,sizeof(pcentry_t));
    }
  }
  
  event message_t* Receive.receive(message_t* bufPtr, 
				   void* payload, uint8_t len) {
    call Timer2.stop();
    if (len != sizeof(control_msg_t)) {return bufPtr;}
    else {
      control_msg_t* rcm = (control_msg_t*)payload;
      rx_tms[0][counter] = rcm->rx_tmsp;
      rssi[0][counter] = rcm->rssi;
      lqi[0][counter] = rcm->lqi;
      v[1][counter] = rcm->v;
      rx_tmsp = call PacketTimeStampRadio.timestamp(bufPtr);
      rx_tms[1][counter] = rx_tmsp;
      retr[1][counter] = rcm->retr;
      if(counter>0){
	tx_tms[1][counter-1] = rcm->tx_tmsp;
      }
      rssi[1][counter] = call PacketRSSI.get(bufPtr);
      lqi[1][counter] = call PacketLinkQuality.get(bufPtr);
      counter++;
      call Voltage.read();
      return bufPtr;
    }
  }

  event void Voltage.readDone(error_t err, uint16_t result){
    v[0][counter] = result;
    call Timer.startOneShot(100);
  }

  event void LogRead.readDone(void* buf, storage_len_t len, error_t err){
    pcentry_t* rcm;
    //    printf("sizes %d %d -- %d\n",(int)len,(int)sizeof(logentry_t),100);
    //printfflush();
    if( (len == sizeof(logentry_t)) && (buf == &m_entry) ){
      rcm = (pcentry_t*) call Packet.getPayload(&packet, sizeof(pcentry_t));
      rcm->counter = pcentrycounter++;
      if(rcm != NULL){
	
	*((logentry_t *)&(rcm->toa)) = *((logentry_t *)buf);
	call pcCommunicator.send(1,&packet,sizeof(pcentry_t));
      }
    }else{
      //EOF
      post eofData();
    }
  }

  event void LogWrite.appendDone(void* buf, storage_len_t len, 
		      bool recordsLost, error_t err){
    call Leds.led1Toggle();
    call Timer.startOneShot(100);
  }

  event void LogWrite.syncDone(error_t err){
    checkErr(err);
    busy = FALSE;
    call Leds.led2On();
  }

  event void LogWrite.eraseDone(error_t err){
    checkErr(err);
    logAvailable = FALSE;
    post eofData(); //Signalling completion
    call Leds.led2On();
  }

  event void pcCommunicator.sendDone(message_t* bufPtr, error_t error){
    if(error == SUCCESS){
      if(logAvailable)
	post dumpData();
      else{
	pcentrycounter = 0;
	logAvailable = TRUE;
	busy = FALSE;
      }
    }
  }

  event void LogRead.seekDone(error_t err){}

  void checkErr(error_t err){
    if(err != SUCCESS)
      call Leds.set(LEDS_LED0|LEDS_LED1|LEDS_LED2);
  }

}