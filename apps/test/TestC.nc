#include "DataForwarder.h"
module TestC{
  uses {
    interface Boot;
    interface AMSend as AMSend1;
    interface AMSend as AMSend2;
    interface SplitControl;
    interface Queue<data_packet_t *>;
    interface Pool<data_packet_t>;
  }
}
implementation
{
  uint16_t* buff;

  event void AMSend1.sendDone(message_t *msg, error_t error){

  }
  event void AMSend2.sendDone(message_t *msg, error_t error){

  }  

  event void Boot.booted()
  {
    call SplitControl.start();
  }

  event void SplitControl.startDone(error_t err)
  {
  }
  
  event void SplitControl.stopDone(error_t err)
  {
  }
}