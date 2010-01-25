#include "DataForwarder.h"
configuration TestAppC
{
}
implementation
{
  components MainC, TestC,new AMSenderC(12) as AMSender1,  new AMSenderC(20) as AMSender2, ActiveMessageC,new QueueC(data_packet_t *,10), new PoolC(data_packet_t,10);

  TestC -> MainC.Boot;
  TestC.AMSend1 -> AMSender1;
  TestC.AMSend2 -> AMSender2;
  TestC.SplitControl -> ActiveMessageC;
  TestC.Queue -> QueueC;
  TestC.Pool -> PoolC;
 
}