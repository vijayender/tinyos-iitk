module storageC{
  uses {
    interface Boot;
    interface Leds;
    interface LogRead;
    interface LogWrite;
    interface Timer<TMilli> as Timer0;
  }
}
implementation{
  
  typedef nx_struct logentry_t {
    nx_uint8_t len;
  } logentry_t;
  uint8_t i=0;
  uint8_t j=0;
  
  bool hasData = FALSE;
  logentry_t m_entry;

  event void Boot.booted(){
    printf("Boot finished\n");
    printfflush();
    if (call LogRead.read(&m_entry, sizeof(logentry_t)) != SUCCESS) {
      printf("LogRead.read failed\n");
      printfflush();
    }
  }


  event void LogRead.readDone(void* buf, storage_len_t len, error_t err) {
    if ( (len == sizeof(logentry_t)) && (buf == &m_entry) ) {
      hasData = TRUE;
      printf("m_entry.len %d\n",m_entry.len);
      printfflush();
      call Leds.led1On();
      if(j<2){
	j++;
	m_entry.len = 20+i++;
	if (call LogWrite.append(&m_entry, sizeof(logentry_t)) != SUCCESS) {
	  printf("LogRead.read in timer failed\n");
	  printfflush();
	}
      }
      call Timer0.startOneShot(1000);
    }
    else if(hasData) {
      printf("About to erase Log\n");
      if (call LogWrite.erase() != SUCCESS) {
	// Handle error.
	printf("Logwrite.erase error");
	printfflush();
      }
      call Leds.led0On();
    }else{
      printf("Starting counter\n");
      printfflush();
      call Timer0.startOneShot(1000);
    }
  }

  event void Timer0.fired(){
    if(hasData){
      if (call LogRead.read(&m_entry, sizeof(logentry_t)) != SUCCESS) {
	printf("LogRead.read in timer failed\n");
	printfflush();
      }
    }else{
      i++;
      if(i<10){
	m_entry.len = i;
	if (call LogWrite.append(&m_entry, sizeof(logentry_t)) != SUCCESS) {
	  printf("LogRead.read in timer failed\n");
	  printfflush();
	}      
      }else{
	call LogWrite.sync();
	call Leds.set(0xff);
      }
    }
  }

  event void LogWrite.eraseDone(error_t err) {
    if (err == SUCCESS) {
      printf("Erase succesful\n");
      printfflush();
    }
    else {
      // Handle error.
    }
    call Leds.led0Off();
  }

  event void LogWrite.appendDone(void* buf, storage_len_t len, 
                                 bool recordsLost, error_t err) {
    call Leds.led2Off();
    printf("Write done! %d\n",m_entry.len);
    printfflush();
    call Timer0.startOneShot(1000);
  }

  event void LogRead.seekDone(error_t err) {
  }

  event void LogWrite.syncDone(error_t err) {
    printf("Sync done\n");
  }

}