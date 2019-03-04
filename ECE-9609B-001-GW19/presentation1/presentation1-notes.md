# All About Traceroute

## Summary

Traceroute is a tool which shows you the path that your packets
take when you send them over [the
Internet](http://www.bcp38.info/index.php/The_Internet) or any other
network that uses the IP protocol. It's familiar and simple; you
type `traceroute` with an address or a hostname as a parameter and
it shows you the path. However, interpretation of traceroute's
output requires some appreciation for the Internet routing architecture,
not to mention practicalities about its deployment. Even experienced
network operators at well-known, large carriers have been known to draw
dubious conclusions from traceroute's output.

This tutorial aims to illustrate that traceroute is not always as
simple as it seems by exploring a few common pitfalls and artifacts.
It is by no means an exhaustive treatment.

## Overview

### Application

The purpose of traceroute is to map the path taken by a packet from
one host on the Internet to another. Examples of why this might be
useful include:

* a network engineer wants to check the routing policy in a network
in order to confirm that observed behaviour matches the intended design;
* an end-user or a service provider wants to troubleshoot performance
problems over the Internet in order to try and find a solution;
* a white-hat security engineer wants to determine what information about
a remote, private network can be discerned from a remote, untrusted
network.

In the context of this course, being able to map a remote network
topology is fundamental to discovering addressing schemes, topologies
and connected devices. In a more benign, diagnostic sense the ability
of a host on an IP network to map the topology of the wider
infrastructure in-band, without other sources of information, is
an important reason why the Internet exists and why the popularity
and sucess of IP as a protocol exceeded that of its rivals.


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

## Underlying Mechanism in IPv4

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

## Base Traceroute Algorithm

Traceroute originates multiple probe packets towards a destination
address with different values TTL in the outermost, encapsulating
IP header. Probe packets with different TTL values will trigger
ICMP messages from different routers along the path; each such ICMP
message will be sourced from the router that generated it, allowing
the originator of the probe packets to collect a list of router
addresses along the path that together constitute the outbound path
to the destination. The destination host to which probe packets
were sent should ideally respond with some other response, indicating
to the traceroute tool what range of TTL values encompass the path;
once data has been collected from all intermediate routers (or when
the tool has timed out waiting for responses) the results can be
presented to the user.

The elapsed time between the origination of a probe packet and the
receipt of a response (of whatever kind) can be used to present
a measure of round-trip latency for each hop in the results.

## Variations in Implementation

### Probe Protocol

The original Van Jaconson implementation of traceroute used UDP
datagrams as probe packets. These used a destination UDP port of
33434, incrementing once for each successive probe. The terminal
host is expected to respond to its probe packet with an ICMP type
3 code 3 response, "Destination port unreachable"; 33434 was chosen
as an arbitrary but (usually) ephemeral port number that most of
the time you could rely on an application not to listen on.

Windows `tracert.exe` has always used ICMP type 8 "Echo Request"
probes, which are the mechanism used by the `ping(8)` utility. The
destination host must respond with an ICMP type 0 "Echo Reply" in
order to signal that the path has been fully traversed.

Various traceroute implementations support multiple protocols,
including TCP SYN probe packets, which can be useful to traverse
firewalls; for example, a web server's HTTP endpoint might be
reachable via a stateless packet filter that blocks UDP and ICMP
type 8 probes, but can be expected to pass 80/tcp or 443/tcp SYN
probes since they are relied upon for proper operation of HTTP using
that protocol's [assigned well-known port
number](https://www.iana.org/assignments/service-names-port-numbers/service-names-port-numbers.xhtml).

### Multiple Probe Packets

Most traceroute implementations originate multiple probe packets for
each value of TTL; Van Jacobson traceroute sent three probes per
hop.  Since the ICMP response packets preserve some of the payload
from the discarded probe packets, the probe payloads can be used
to provide further identification of the responses, e.g. allowing
`traceroute(8)` on multi-user Unix systems to be run by multiple
users at once with the same destination without confusing one user's
probe packets with another. UDP and TCP destination port numbers
allow further demuxing, as does the ICMP echo request sequence
number field.

### Asynchronous or Synchronous Origination of Probe Packets

Van Jacobson traceroute sent probe packets in order, starting with
TTL=1, and not continuing with larger TTL probes until data for the
first one had been collected. Traceroute over a long path could
hence take a noticeable amount of time to complete.

Some other implementations send subsequent probe packets without
delay, taking advantage of the payload and transport addresses
identified in the responses to sort them and present a path regardless
of the order in which they are received.

## Practical Considerations

### Round-Trip Latency

As described, traceroute measures the round-trip latency involved
in sending a probe packet and receiving some kind of corresponding
response (from something). It is not a measurement of elapsed time
between the originator of the probe packet and a particular hop on
the path.

The latency recorded by traceroute has multiple components:

* _Queuing Delay_ and _Serialisation Delay_ -- the time taken for a
datagram to be inserted into a queue and for that queue to be drained
through an essentially serial network interface. These effects are
minimal in modern networks with high-speed (e.g. 10G+) interfaces,
but become significant when interfaces face congestion because they
are over-subscribed. An interface that is 80% utilised is one that
is busy transmitting frames 80% of the time, increasing the probability
that a probe packet will be delayed in a queue, increasing the
observed round-trip latency.
* _Propagation Delay_ -- the time taken for a datagram to travel over
a network. In the case of an optical network this can be approximated by
the speed of light in the transmission medium, e.g. 0.67c in a fibre
core with a refractive index of 1.48 (1/0.67). A hop through a
geostationary satellite involves a signal path of 35,786km up and
the same down, adding around 250ms; low Earth orbit (LEO) satellites
add around 40ms by comparison, and medium Earth orbit (MEO) around
125ms.
* _Processing Delay_ -- whilst some routers can process TTL-expired
packets and ICMP message synthesis in FPGAs on line cards, others
require general-purpose CPUs to do the processing which can add
noticeable delay. Even those routers that don't incur the delay of
a trip across a control bus and a spin around a CPU frequently
rate-limit the number of such responses that can generated, which
can result in response queueing delays or dropped responses.

Individual latency measurements can be inflated by transient network
conditions, which provides the motivation for the observed behaviour
of many traceroute implementations to send multiple probe packets
for each hop so that outliers can be more readily identified.

On a path with no asymmetric routing effects, processing delay can
be identified by a spike in latency measurements that is not observed
in subsequent hops.

### Asymmetric Paths

Routing on the Internet is asymmetric -- that is, in general, the path
across the network from a source A to a destination B is not the same
as the path from B to A. IP routing is only concerned with destination
addresses, not source addresses.

Since latency measurements in traceroute are of the whole round-trip, and
since traceroute only shows you the outbound path and not the return,
the numbers observed in traceroute can be misleading. 

Whilst an asymmetric return path within a single autonomous system
might not introduce significantly different delay than the forward
path, an autonomous system boundary represents a potentially more
dramatic change in routing policy and topology. For example, a
forward path that routes from a host in Toronto to a target in
Vancover via Chicago and Seattle might have a correspionding return
path via San Jose and Ashburn, Virginia from routers west of Chicago.
Observed latency would increase significantly on the forward path
after Chicago which might be interpreted as congestion, when in
fact the increased path distance on the returb path is the real
cause, due to a different routing policy in the provider interconnecting
in Chicago.

### Equal-Cost Multi-Path (ECMP) Routing

Capacity between routers can be expanded by choosing transmission
networks that provide greater bandwidth, e.g. by upgrading from a
10Gbit/s STM-64 (OC-192 in SONET) interface to a 40Gbit/s STM-256
(OC-768). However, an alternative approach is to combine multiple
lower-speed interfaces in order to provide integer multiples of
capacity, perhaps to avoid the cost of new higher-speed interfaces.

In some cases intefaces can be combined to provide a single interface
at the IP layer, e.g. using [multilink
PPP](https://tools.ietf.org/rfc/rfc1990.txt) or using ethernet
802.1AX Link Aggregation. In other cases multiple, parallel IP-layer
connections between adjacent routers can be provisioned, relying
upon equal-cost routes to share traffic across multiple candidate
egress interfaces in each direction using some suitable heuristic.
Flow hashing is often used to ensure that individual datagrams
associated with a single transaction (a "flow") are constrained to
a single link, e.g. to avoid packet reordering. The use of different
transport-layer destination ports in traceroute can often cause
successive probe packets to appear as distinct flows, meaning that
different probe packets with the same TTLs can be carried over
different links.

Observing multiple different links at a particular hop in the output
of traceroute is relatively easy to interpret; however, in some
cases different equal-cost paths will have different path lengths,
and in those cases the output can be confusing. The traceroute tool
is generally not able to reassemble individual paths in those cases.

### Multi-Protocol Label Switching (MPLS)

[Multi-Protocol Label Switching
(MPLS)](https://tools.ietf.org/rfc/rfc3031.txt) is an architectural
approach to core network design that employs switching elements
that forward based on a label rather than a destination address.
Such cores can provide transport for protocols such as IP as an
overlay for a small, high-performance packet core where individual
routers do not require Internet-scale routing tables and are somewhat
insulated from in-band communication from untrusted devices.

A label-switched core router carrying a traceroute probe packet
might decrease the TTL to zero but have no means to send an ICMP
message back to its source. One solution to this problem is to
tunnel the ICMP message through the MPLS core using the same label
that was used to switch the corresponding probe packet. This approach
ensures delivery of the ICMP message by a router in the correct
routing domain, but has the side effect of elongating the path over
which the ICMP response packet was sent. A traceroute over an MPLS
core can produce strange-looking output where whole sections of the
output have the same latency measurements reported.

### Variable Quality of Reverse DNS

Traceroute often displays [DNS](https://www.ietf.org/rfc/rfc1034.txt)
names as well as IP addresses in its output. This is very useful
in interpreting traceroute's output, since names are generally more
easily understood by humans than addresses. A DNS name might identify
the name of a network operator, a city, a router type and perhaps
even a router interface type (and hence interface capacity), all
of which provides useful metadata missing from a bare address.

However, with some notable exceptions principally related to the
delivery of e-mail, the mapping of IP addresses to DNS names
(so-called "reverse DNS") is not mandatory and doesn't really break
anything if it's missing or inaccurate. Whilst many network operators
do a pretty good job at keeping their reverse DNS maintained, there
are whole regions of the world that don't bother; Asia is an easy
example.

Network interconnects between autonomous systems also sometimes
show signs of reverse DNS that are misleading; for example, a peering
circuit between two tier-2 providers is likely to have endpoints
assigned by just one of the operators; that operator will also
generally be responsible for the corresponding reverse DNS entries.
Hence, although two addresses on such a link each refer to different
routers operated by different network providers, the reverse DNS
might suggest that both are operated by the same carrier.

