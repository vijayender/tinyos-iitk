/**
 * @author K. Vijayender Reddy <karnaty@iitk.ac.in>
 */

#ifndef TCPLISTENER_H
#define TCPLISTENER_H

class TCPListener
{
public:
    TCPListener();
    virtual ~TCPListener();
    setAddr();
    is_connected();
    setCallBackFunc(void(*call_back)());
    writePacket();
    startListening();
};

#endif
