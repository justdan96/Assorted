#!/usr/bin/env python
"""

NetMaskCalc

This is a Python port of this Perl program, by thorkill:
http://thorkill.einherjar.de/code/hostCount2NetMask.pl

Although this version has a lot more features.

Converting IPs to Longs and Back Found Here:
http://code.activestate.com/recipes/66517/

Check if a number is a power of two & the next power of two:
http://www.willmcgugan.com/blog/tech/2007/7/1/profiling-bit-twiddling-in-python/

Requires the ipaddr.py library, available here, or on Python versions 3.1+:
http://code.google.com/p/ipaddr-py/

"""

from __future__ import division

__author__ = 'Dan Bryant'
__version__ = '0.0.9'
__date__ = '2009/06/07'

import optparse
import math
import ipaddr
import socket, struct

def is_power_of_2(v):
    return (v & (v - 1)) == 0

def next_power_of_2(v):
    v -= 1
    v |= v >> 1
    v |= v >> 2
    v |= v >> 4
    v |= v >> 8
    v |= v >> 16
    return v + 1

def dottedQuadToNum(ip):
    "convert decimal dotted quad string to long integer"
    "!L = big-endian quad, L = little-endian quad"
    return struct.unpack('!L',socket.inet_aton(ip))[0]

def numToDottedQuad(n):
    "convert long int to dotted quad string"
    "!L = big-endian quad, L = little-endian quad"
    return socket.inet_ntoa(struct.pack('!L',n))

def TotalHosts(ip, hosts):
    " We need to work out if they will not be able to fit their hosts into the subnet"
    " Find out the next power of 2 (e.g. 32), then find if we are 1 less than or equal to it"
    " If we are (e.g. 31) we must use the next bit on the SNM - because there are 2 reserved addresses"
    " We tell the algorithm we have the next power of 2 plus 1 (e.g. 33) hosts, to ensure we are on the next bit"
    x = next_power_of_2(int(hosts))
    if 0 <= x-int(hosts) <=1:
        hosts = x+1

    " This function is straight from the Perl script, it calculates the slash notation (no. of bits) mask for the no. of hosts"
    tot = 32-(math.log(float(hosts))/math.log(float(2)))

    " We create a new ipaddr object using the input IP and the generated slash notation mask"
    addr = ipaddr.IPv4(ip + '/' + str(int(tot)))

    " Pump out all the stats ipaddr has to offer"
    print 'IP Address /Mask:     ' + addr.ip_ext + ' /' + str(int(tot))
    print 'Subnet Mask:          ' + addr.netmask_ext
    print 'Network Address:      ' + addr.network_ext
    print 'Broadcast Address:    ' + addr.broadcast_ext
    print 'No. of Hosts:         ' + str(addr.numhosts)
    " Minus two from the number of hosts for the two reserved addresses"
    print 'No. Usable Hosts:     ' + str(addr.numhosts-2)
    " Take integer representation of network address, add one and convert to dotted quad format to give the first usable host address"
    print 'First Usable Address: ' + str(numToDottedQuad(addr.network+1))
    " Take integer representation of broadcast address, minus one and convert to dotted quad format to give the last usable host address"
    print 'Last Usable Address:  ' + str(numToDottedQuad(addr.broadcast-1))

    return  

def Main():
    oParser = optparse.OptionParser(usage='usage: %prog [options]', version='%prog ' + __version__)
    oParser.add_option('-i', '--ip', default='', help='The IP address')
    oParser.add_option('-n', '--numhosts', default='', help='The number of hosts')
    (options, args) = oParser.parse_args()

    if len(args) == 0:
        if options.ip != '' and options.numhosts != '':
            TotalHosts(options.ip, options.numhosts)
        else:
            print '//NetMaskCalc'
            print '//Version = ' + __version__
            print '//Calculate addressing scheme given an input IP address and the number of hosts required'
            print ''
            oParser.print_help()        
    else:
        oParser.print_help()
        print 'Incorrect arguments supplied'

    return

if __name__ == '__main__':
    Main()
