#!/usr/bin/env python

import sys
import tos
import time

class Radio_packet(tos.Packet):
    def __init__(self, packet = None):
        tos.Packet.__init__(self,
                            [('control', 'int', 2)],
                            packet)

class pcPacket(tos.Packet):
    def __init__(self, packet = None):
        tos.Packet.__init__(self,
                            [('counter','int',4),
                             ('toa', 'int',1),
                             ('rssi1','int',1),
                             ('rssi2','int',1),
                             ('lqi1','int',1),
                             ('lqi2','int',1),
                             ('retr1','int',1),
                             ('retr2','int',1),
                             ('v1','int',2),
                             ('v2','int',2)],
                            packet)

if '-h' in sys.argv:
    print "Usage:", sys.argv[0], "serial@/dev/ttyUSB0:57600"
    print "      ", sys.argv[0], "network@host:port"
    sys.exit()

am = tos.AM()
i=0

command = sys.argv[2]

if(command == "get"):
    rp = Radio_packet();
    rp.control = 4;
    if(am.write(rp,9)):
        print "Success issuing command get"
        p = am.read()
        while p:
            m = pcPacket(p.data);
            if m.v2 == 0:
                break;
            print m;
            p = am.read()
    else:
        print ":( no hello"
elif (command == "erase"):
    rp = Radio_packet();
    rp.control = 3;
    if(am.write(rp,9)):
        print "Success issuing command erase"
        p = am.read();
        m = pcPacket(p.data);
        print "mote returned packet with v1",m.v2
    else:
        print ":( no hello"
elif(command == "hello"):
    rp = Radio_packet();
    rp.control = 2;
    if(am.write(rp,9)):
        print "Success saying hello"
    else:
        print ":( no hello"
    print "hello";
