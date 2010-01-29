#include "mts400.h"

module MTSGlobalC{
  provides interface SplitControl;
  uses interface Switch as PowerSwitch;
  uses interface Switch as DataSwitch;
}
implementation{
  bool started = FALSE;
  command error_t SplitControl.start(){
    atomic {
      if(started)
	return EALREADY;
      started = TRUE;
    }
    call PowerSwitch.setAll(ALLOFF);
    return SUCCESS;
  }
  
  event void PowerSwitch.setAllDone(error_t err){
    if(err == SUCCESS)
      call DataSwitch.setAll(ALLOFF);
    else{
      started = FALSE;
      signal SplitControl.startDone(err);
    }
  }

  event void DataSwitch.setAllDone(error_t err){
    if(err != SUCCESS)
      started = FALSE;
    signal SplitControl.startDone(err);
  }
  
  command error_t SplitControl.stop(){
    //Not implemented
    return FAIL;
  }
  
  event void DataSwitch.setDone(error_t err){}
  event void DataSwitch.maskDone(error_t error){}
  event void DataSwitch.getDone(error_t error, uint8_t value){}
  event void PowerSwitch.setDone(error_t error){}
  event void PowerSwitch.maskDone(error_t error){}
  event void PowerSwitch.getDone(error_t error, uint8_t value){}

}