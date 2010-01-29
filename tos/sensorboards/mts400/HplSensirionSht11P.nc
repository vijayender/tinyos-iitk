#include "Timer.h"
#include "mts400.h"

/**
 * HplSensirionSht11P is a low-level component that controls power for
 * the Sensirion SHT11 sensor on the telosb platform.
 *
 * TODO: Too many debug statments. Decrease them.
 */

module HplSensirionSht11P {
  provides interface SplitControl;
  uses interface SplitControl as MTSGlobal;
  uses interface Timer<TMilli>;
  uses interface Switch as PowerSwitch;
  uses interface Switch as DataSwitch;
}

implementation {
  enum{
    POWER_TURN_ON,		/* To power on the machine */
    POWER_ON,
    POWER_TURN_OFF,
    POWER_OFF,
  }
  powerStatus = POWER_OFF;
  
  command error_t SplitControl.start() {
    error_t err;
    if(powerStatus == POWER_ON)
      return EALREADY;
    if(powerStatus != POWER_OFF)
      return EBUSY;
    err = call MTSGlobal.start();	/* Init the mts sensorboard */
    if(err == FAIL || err == EBUSY){
      return err;
    }else if(err == EALREADY) {
      call Timer.startOneShot(10);
    }
    return SUCCESS;
  }
  
  event void MTSGlobal.startDone(error_t err){
    if(err == SUCCESS){
      powerStatus = POWER_TURN_ON;
      call PowerSwitch.set(PWR_HUMIDITY,1);
    }
    else
      signal SplitControl.startDone(err);
  }

  event void Timer.fired(){
    //Turn on the power to SHT11
    powerStatus = POWER_TURN_ON;
    call PowerSwitch.set(PWR_HUMIDITY,1);
  }

  event void PowerSwitch.setDone(error_t err){
    if(powerStatus == POWER_TURN_ON){
      if(err == SUCCESS){	// Why on earth would it go wrong ??
	call DataSwitch.mask(HUMIDITY_SCK | HUMIDITY_DATA,0);
      }else{
	signal SplitControl.startDone(err);
      }
    }else if(powerStatus == POWER_TURN_OFF){
      if(err == SUCCESS)
	powerStatus == POWER_OFF;
      signal SplitControl.stopDone(err);
    }
  }

  event void DataSwitch.maskDone(error_t err){
    if( powerStatus == POWER_TURN_ON){
      if(err == SUCCESS){
	powerStatus = POWER_ON;
      }
      signal SplitControl.startDone(err);
    } else if ( powerStatus == POWER_TURN_OFF){
      if(err == SUCCESS){
	call PowerSwitch.set(PWR_HUMIDITY, 0);
      }else
	signal SplitControl.stopDone(err);
    }
  }

  command error_t SplitControl.stop() {
    powerStatus = POWER_TURN_OFF;
    call DataSwitch.mask(0, HUMIDITY_DATA | HUMIDITY_SCK );
    return SUCCESS;
  }

  event void DataSwitch.setDone(error_t err){}
  event void DataSwitch.setAllDone(error_t error){}
  event void PowerSwitch.setAllDone(error_t error){}
  event void PowerSwitch.maskDone(error_t error){}
  event void DataSwitch.getDone(error_t error, uint8_t value){}
  event void PowerSwitch.getDone(error_t error, uint8_t value){}
  event void MTSGlobal.stopDone(error_t error){}

}