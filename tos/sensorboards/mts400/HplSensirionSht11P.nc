#include "Timer.h"

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
    err = MTSGlobal.start();	/* Init the mts sensorboard */
    if(err == FAIL || err == EBUSY){
      return err;
    }else if(err == EALREADY) {
      Timer.startOneShot(10);
    }
    return SUCCESS;
  }
  
  event MTSGlobal.startDone(error_t err){
    if(err == SUCCESS){
      powerStatus = POWER_TURN_ON;
      PowerSwitch.set(PWR_HUMIDITY,1);
    }
    else
      signal SplitControl.startDone(err);
  }

  event void Timer.fired(){
    //Turn on the power to SHT11
    powerStatus = POWER_TURN_ON;
    PowerSwitch.set(PWR_HUMIDITY,1);
  }

  event void PowerSwitch.setDone(error_t err){
    if(powerStatus == POWER_TURN_ON){
      if(err == SUCCESS){	// Why on earth would it go wrong ??
	DataSwitch.mask(HUMIDITY_SCK | HUMIDITY_DATA,0);
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
	PowerSwitch.set(PWR_HUMIDITY, 0);
      }else
	signal SplitControl.stopDone(err);
    }
  }

  command error_t SplitControl.stop() {
    proc = STOP;
    DataSwitch.mask(0, HUMIDITY_DATA | HUMIDITY_SCK );
    return SUCCESS;
  }
}