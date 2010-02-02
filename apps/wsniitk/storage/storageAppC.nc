#include <Timer.h>
#include "StorageVolumes.h"

configuration storageAppC{
}
implementation{
  components MainC, LedsC, storageC as App;
  components new LogStorageC(VOLUME_LOGTEST, TRUE);
  components new TimerMilliC() as Timer0;

  App.Boot -> MainC;
  App.Leds -> LedsC;
  App.LogRead -> LogStorageC;
  App.LogWrite -> LogStorageC;
  App.Timer0 -> Timer0;
}