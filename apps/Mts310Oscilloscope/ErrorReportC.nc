/* this module requires that the network be turned on before hand */
#include "ErrorReport.h"

module ErrorReportC{
  uses{
    interface AMSend as Send_error;
    interface Queue<uint8_t> as error_queue;
    interface PacketAcknowledgements;
    interface Leds;
  }
  provides{
    interface ErrorReport;
  }
}

implementation {
  message_t errSendBuf;
  bool running = FALSE;
  uint16_t errRetryCount = 0;
  
  task void send_err_report();
  void __inline leds_set(uint8_t);

  command void ErrorReport.report_error(uint8_t error){
    error_t err;
    err = call error_queue.enqueue(error);
    if( !running )
      post send_err_report();
    leds_set(ERR_QUEUE_FULL);
  }
  
  task void send_err_report(){
    error_msg_t* msg;
    uint8_t error_no;

    if(call error_queue.empty()){
      leds_set(ERR_QUEUE_EMPTY);
      return;
    }
    error_no = call error_queue.head();
    msg = (error_msg_t*)call Send_error.getPayload(&errSendBuf, sizeof(error_msg_t));
    msg->node_id = TOS_NODE_ID;
    msg->error_no = error_no;
    call PacketAcknowledgements.requestAck(&errSendBuf);
    switch (call Send_error.send(ADDR_BASESTATION, &errSendBuf, sizeof(error_msg_t))){
    case SUCCESS:
      break;
    case EBUSY:
      post send_err_report();			   /* A random backoff ?? */
      break;
    default:		/* Covers FAIL */
      leds_set(ERR_RADIO);
      break;
    }
  }
  
  event void Send_error.sendDone(message_t* msg, error_t error){
    if(error == SUCCESS && call PacketAcknowledgements.wasAcked(msg)){
      errRetryCount=0;
      call error_queue.dequeue();
      if (! call error_queue.empty() ) 
	post send_err_report();
      else
	running = FALSE;
    }else if(errRetryCount < MAX_ERR_RETRY){
      errRetryCount++;
      leds_set(RADIO_SEND_FAIL);
      post send_err_report();
    } else 
      leds_set(ERR_MSG_ERR);
  }

  void __inline leds_set( uint8_t val ){
    call Leds.set(val);
  }
}