#!/usr/bin/env python

import sys
import tos

class Radio_packet(tos.Packet):
    def __init__(self, packet = None):
        tos.Packet.__init__(self,
                            [('counter', 'int', 2)],
                            packet)


if '-h' in sys.argv:
    print "Usage:", sys.argv[0], "serial@/dev/ttyUSB0:57600"
    print "      ", sys.argv[0], "network@host:port"
    sys.exit()

am = tos.AM()
i=0

while True:
    p = am.read()
    if p:
        m = Radio_packet(p.data);
	print "received ",m.counter;
    i=i+1
    rp = Radio_packet();
    rp.counter = i
    if(am.write(rp,6)):
        print "Successful transmission of", i
    else:
        print "Unsuccessful transmission :( of", i
            


