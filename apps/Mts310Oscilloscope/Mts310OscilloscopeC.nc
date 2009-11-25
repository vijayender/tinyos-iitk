#include "Timer.h"
#include "Mts310Oscilloscope.h"
#include "ErrorReport.h"
#include "SensorMonitor.h"

module Mts310OscilloscopeC
{
  uses {
    interface Boot;
    interface SplitControl as RadioControl;
    interface Receive;
    interface AMSend;
    interface ErrorReport;
    interface SensorMonitor;
  }
}
implementation
{
  message_t msgBuff;

  bool send_message(uint16_t control_packet_no)
  {
    control_confirm_msg_t* cmt_cfm;
    cmt_cfm = call AMSend.getPayload(&msgBuff,sizeof(control_confirm_msg_t));
    cmt_cfm->node_id = TOS_NODE_ID;
    cmt_cfm->control_packet_no = control_packet_no;
    return (call AMSend.send(ADDR_BASESTATION, &msgBuff, sizeof (control_msg_t)) == SUCCESS);
  }

  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) 
  {
    control_msg_t* cmt = (control_msg_t*) payload;
    if(cmt->node_id == TOS_NODE_ID){
      if(send_message(cmt->control_packet_no)){
	switch( cmt->control_setting ){
	case READ_ONCE:
	  call SensorMonitor.read_once(cmt->version);
	  //	  SensorMonitor[cmt->control_device].read_once();
	  break;
	case READ_STREAM:
	  call SensorMonitor.read_stream(cmt->usPeriod,cmt->setting_data,cmt->version);
	  break;
	case READ_OSCIL:
	  call SensorMonitor.read_to_oscilloscope(cmt->usPeriod, cmt->version);
	  break;
	case STOP:
	  call SensorMonitor.stop();
	  break;
	default:
	  call ErrorReport.report_error(ER_UNKOWN_COMMAND);
	}
      }
    }
    return msg;
  }
  
  event void Boot.booted()
  {
    /* Start Radio */
    if (call RadioControl.start() != SUCCESS)
      call ErrorReport.report_error(ER_RADIO_START); /* Toggle led0 */
  }

  event void RadioControl.startDone(error_t err)
  {
    send_message(0);
  }

  event void RadioControl.stopDone(error_t err)
  {
  }
  
  event void AMSend.sendDone(message_t* msg, error_t error)
  {
  }

}
