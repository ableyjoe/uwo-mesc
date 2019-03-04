# All About Traceroute

## Summary

Traceroute is a tool which shows you the path that your packets
take when you send them over [the
Internet](http://www.bcp38.info/index.php/The_Internet) or any other
network that uses the IP protocol. It's familiar and simple; you
type `traceroute` with an address or a hostname as a parameter and
it shows you the path. However, interpretation of traceroute's
output requires some appreciation for the Internet routing architecture,
not to mention practicalities about its deployment. This tutorial
aims to illustrate that traceroute is not always as simple as it
seems.

## Overview

### History

Traceroute is a tool originally written by [Van
Jacobson](https://en.wikipedia.org/wiki/Van_Jacobson) based, he
says, on an idea he heard from [Steve
Deering](https://en.wikipedia.org/wiki/Steve_Deering). Some of Van's
original notes about his implementation in 1987 are preserved as
comments in the the source code of various free software operating
systems that ship with his code, e.g. [`traceroute.c` in
OpenBSD](https://cvsweb.openbsd.org/cgi-bin/cvsweb/~checkout~/src/usr.sbin/traceroute/traceroute.c?rev=1.159&content-type=text/plain).

Today, traceroute functionality is available for more or less every
platform that ships with user-accessible diagnostic tools. On Windows
it has been known as `tracert` since around the time of third-party
WINSOCK libraries shipped to run on Windows 3.1, due to the FAT
filesystem restriction on filenames (_traceroute_ is two letters
too long).

### Other Protocols

Traceroute functionality exists in
[IPv6](https://tools.ietf.org/html/rfc8200) networks as well as
[IPv4](https://tools.ietf.org/rfc/rfc791.txt), and the implementation
is directly analogous; the TTL loop-avoidance mechanism of IPv4 was
preserved in IPv6, and [ICMPv6](https://tools.ietf.org/rfc/rfc4443.txt)
type 3 maps directly to [ICMP](https://tools.ietf.org/rfc/rfc792.txt)
type 11. On Unix and Unix-like systems traceroute for IPv6 is
sometimes provided as a separate tool `traceroute6`, although some
operating systems support both address families in a single
`traceroute` tool.

This tutorial only refers to IPv4 as a kindness to the reader, since
explicit inclusion of IPv6 references would really just double the
size of the text without providing any additional information. What
is spoken here for v4 goes for v6, too.

Kindness to the reader is further extended by the refusal to talk
about similar functionality available in other protocols, such as
[DECNet](https://en.wikipedia.org/wiki/DECnet),
[IPX/SPX](https://en.wikipedia.org/wiki/IPX/SPX),
[Appletalk](https://en.wikipedia.org/wiki/AppleTalk) and
[OSI](https://en.wikipedia.org/wiki/OSI_model), none of which are
relevant at the time of writing for practical, large-scale networking.

## Mechanism in IPv4

Packet networks generally require protocol support to mitigate
topological loops; if they did not, any network would be vulnerable
to capacity exhaustion through deliberate or accidental exploitation
of routing loops. (As an aside, even with loop mitigation facilities,
protocols can still be vulnerable to these kinds of attacks; see,
for example, [RFC5095](https://tools.ietf.org/rfc/rfc5095.txt) which
deprecates type 0 routing headers in IPv6 for precisely this reason.)

In IPv4, the IP datagram header includes an eight-bit Time to Live
(TTL) field. Although originally imagined as a time value, in
practice it is treated as a hop count; a router, receiving a datagram
through an interface, decrements the TTL field. If the resulting
TTL is greater than zero, the datagram is handled appropriately,
e.g. routed towards a destination through an outbound interface if
a suitable route exists for the destination address.  If the TTL
becomes zero, the router discards the packet and originates a control
message to the datagram's source indicating that the datagram has
expired in transit.

Control messages in IPv4 are encoded in [Internet Control Message
Protocol (ICMP)](https://tools.ietf.org/rfc/rfc792.txt) datagrams,
encapsulated within IP as protocol number 1. All ICMP packets include
an 8-octet header that includes an 8-bit type and code fields; the
particular type of message used in traceroute is type 11 code 0,
indicating "TTL expired in transit".


