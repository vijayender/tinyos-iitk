#include "DataForwarder.h"
#include "SensorMonitor.h"
#include "Timer.h"

module SensorMonitorC{
  provides {
    interface SensorMonitor;
  }
  uses {
    interface Read<uint16_t>;
    interface ReadStream<uint16_t>;
    interface Timer<TMilli>;
    interface ErrorReport;
    interface DataForwarder;
  }
}

implementation{
  //Read once data
  uint16_t once_version;
  //uint16_t id = 1;

  //Oscilloscope data
  uint16_t oscilloscope_version;
  uint32_t oscilloscope_usPeriod;
  bool oscilloscope_running = FALSE;

  //Read stream once data
  uint16_t currCount=0;
  uint16_t maxCount=0;
  uint32_t stream_usPeriod=-1;
  uint16_t stream_version;
  bool read_stream_once_running = FALSE;

  //Global buffer
  uint16_t* buffer;
  bool running = FALSE;
  bool stop = FALSE;
  uint16_t samples;
  
  data_packet_t* data;

  task void start_stream_read();

  command void SensorMonitor.read_once(uint16_t version)
  {
    once_version = version;
    if(call Read.read() != SUCCESS)
      call ErrorReport.report_error(ER_READ_ONCE);
    else
      running = TRUE;
  }

  event void Read.readDone(error_t error, uint16_t value)
  {
    if ( error != SUCCESS )
      call ErrorReport.report_error( ER_READ_ONCE_DONE);
    else {
      running = FALSE;
      data = call DataForwarder.getBuffer();
      if(data){
	//data->id = id;
	data->type = READ_ONCE;
	data->count = 0;
	data->readings = 1;
	data->version = once_version;
	data->data[0] = value;
	call DataForwarder.send_data(data);
      }else{
	call ErrorReport.report_error(ER_POOL_EMPTY);
      }
    }
  }

  command void SensorMonitor.read_stream(uint32_t _usPeriod, uint16_t _count, uint16_t _version)
  {
    stream_version = _version;
    maxCount = _count;
    stream_usPeriod = _usPeriod;

    if(!running){
      read_stream_once_running = TRUE;
      currCount = 0;
      post start_stream_read();
    }else
      call ErrorReport.report_error(ER_ALREADY_RUNNING);
  }

  task void start_stream_read()
  {
    uint16_t bufferLength;
    running = TRUE;
    if(read_stream_once_running){
      if(maxCount > currCount){
	bufferLength = call DataForwarder.getBufferLength();  
	samples = maxCount - currCount;
	samples = bufferLength>samples?samples:bufferLength;
	
	data = call DataForwarder.getBuffer();
	if(data){
	  //data->id = id;
	  data->type = READ_STREAM;
	  data->count = currCount;
	  data->readings = samples;
	  data->version = stream_version;

	  call ReadStream.postBuffer(data->data, samples);
	  call ReadStream.read(stream_usPeriod);
	}else{
	  call ErrorReport.report_error(ER_POOL_EMPTY);
	}
      }else{
	// Done with stream reading
	currCount = 0;
	maxCount = 0;
	running = FALSE;
	read_stream_once_running = FALSE;
      }
    }else if(oscilloscope_running){
      
      data = call DataForwarder.getBuffer();
      samples = call DataForwarder.getBufferLength();
      if(data){
	//data->id = id;
	data->type = READ_OSCIL;
	data->count = currCount;
	data->readings = samples;
	data->version = stream_version;
	
	call ReadStream.postBuffer(data->data, samples);
	call ReadStream.read(stream_usPeriod);
      }else{
	call ErrorReport.report_error(ER_POOL_EMPTY);
      }
    }
  }

  command void SensorMonitor.read_to_oscilloscope(uint32_t _usPeriod, uint16_t _version)
  {
    oscilloscope_usPeriod = _usPeriod;
    oscilloscope_version = _version;
    if(!running){
      oscilloscope_running = TRUE;
      post start_stream_read();
    }else
      call ErrorReport.report_error(ER_ALREADY_RUNNING);
  }

  command void SensorMonitor.stop()
  {
    running = FALSE;
    read_stream_once_running = FALSE;
    oscilloscope_running = FALSE;
    stop = FALSE;
    currCount = 0;
    maxCount = 0;
    return;
  }
  
  event void Timer.fired()
  {
    post start_stream_read();
  }


  event void ReadStream.bufferDone(error_t result, uint16_t *buf, uint16_t count)
  {
    uint32_t usPeriod=0;
    call DataForwarder.send_data(data);
    if(oscilloscope_running){
      usPeriod = oscilloscope_usPeriod;
    }else if(read_stream_once_running){
      usPeriod = stream_usPeriod;
    }
    currCount += count;
    call Timer.startOneShot(usPeriod);
  }

  event void ReadStream.readDone(error_t result, uint32_t usActualPeriod)
  {
    // Do nothing
  }
}
