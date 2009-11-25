#include "DataForwarder.h"

module DataForwarderC
{
  provides interface DataForwarder;
  uses {
    interface AMSend;
    interface PacketAcknowledgements;
    interface Queue<data_packet_t *>;
    interface Pool<data_packet_t>;
    interface ErrorReport;
  }
}
implementation 
{
  error_t err;
  message_t buffMsg;
  task void send_message();
  uint16_t retryCount;

  command void DataForwarder.send_data(data_packet_t* data)
  {
    if(call Queue.enqueue(data) == SUCCESS){
      if(call Queue.size() == 1)
	post send_message();
    }else
      call ErrorReport.report_error(ER_QUEUE_FULL);
  }
 
  task void send_message()
  {
    data_packet_t* packet;
    if(call Queue.empty()){
      call ErrorReport.report_error(ER_QUEUE_EMPTY);
      return;
    }
    packet = call Queue.head();
    call PacketAcknowledgements.requestAck(&buffMsg);
    memcpy(call AMSend.getPayload(&buffMsg, sizeof(data_packet_t)),packet,sizeof(data_packet_t));
    if (call AMSend.send(ADDR_BASESTATION, &buffMsg, sizeof (data_packet_t)) != SUCCESS){
      call ErrorReport.report_error(ER_RADIO_SEND);
      post send_message();
    }
  }

  command data_packet_t* DataForwarder.getBuffer()
  {
    return call Pool.get();
  }

  command uint16_t DataForwarder.getBufferLength()
  {
    return NREADINGS;
  }

  event void AMSend.sendDone(message_t* msg, error_t result)
  {
    if(result == SUCCESS && call PacketAcknowledgements.wasAcked(&buffMsg) ){
      retryCount = 0;
      call Pool.put(call Queue.dequeue());
    }
    else if(retryCount < MAX_RETRYCOUNT){
      retryCount++;
      post send_message();
    }else
      call ErrorReport.report_error(ER_RADIO_FAIL);
    if(!call Queue.empty())
      post send_message();
  }
}
