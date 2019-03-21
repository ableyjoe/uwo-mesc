# CVE-2008-1447: The Kaminsky Attack

## Summary

[CVE-2008-1447](https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2008-1447)
describes a protocol-level vulnerability in the Domain Name System
(DNS) that was famously described by [Dan
Kaminsky](https://en.wikipedia.org/wiki/Dan_Kaminsky) in 2008 and
is colloquially known as the *Kamnisky Attack*.

The vulnerability exploits a weakness in the DNS protocol that is
exacerbated by particular implementation choices. The weakness had
been [observed](http://cr.yp.to/djbdns/forgery.html) by [Dr Daniel
J. Bernstein](http://cr.yp.to/djbdns/forgery.html) long before
Kaminsky [presented his
findings](https://www.blackhat.com/presentations/bh-dc-09/Kaminsky/BlackHat-DC-09-Kaminsky-DNS-Critical-Infrastructure.pdf)
at BlackHat but the potential impact of systematic abuse had not
really been recognised.  Bernstein had written his own DNS
implementation, djbdns, and had a history at the time of being
critical of the DNS protocol and of other DNS implementations (e.g.
see [Under the hood: DNS problems](http://cr.yp.to/djbdns.html)).
It seems possible that this particular observation was lost in the
rhetorical rainstorm. At the time of Kaminsky's work, Bernstein's
implementation was one of only a handful that were not trivial to
exploit.

## The DNS Protocol

### History

The DNS Protocol is old, the [original
specification](https://tools.ietf.org/rfc/rfc1034.txt) dating from
1987, an age when network abuse was rare and [the Internet was
small](https://www.computerhistory.org/internethistory/1980s/), far
from a necessity for people outside academia and a small number of
commercial companies. The design of the DNS has aged remarkably
well, considering that like many of its peer protocols it was
motivated more on functionality than robustness, privacy or
performance.

The original purpose of the DNS was to provide a scaleable way to
map names to addresses used on the Internet in a way that was
consistent with the distributed nature of the Internet as a network
of networks. The DNS as specified by [Dr Paul
Mockapetris](https://en.wikipedia.org/wiki/Paul_Mockapetris) was
the successful conclusion to this work, a collaboration between
many pioneers who communicated using the namedroppers mailing list,
mediated over a long period by [Dr Jon
Postel](https://en.wikipedia.org/wiki/Jon_Postel). The DNS protocol
introduced many novel concepts and accommodated the publication and
retrieval of many other data types beyond IP addresses.

The DNS is commonly described in terms of three separate concepts:
its namespace, the resource records that are attached to nodes in
that namespace and the infrastructure on which the whole system is
deployed.

### Namespace

The DNS uses a now-familiar, hierarchical namespace. Individual
names consist of an ordered series of labels. The conventional
notation is for those labels to be ordered, left to right, from
least-significant to most-significant and separated by dot characters
(ASCII 0x2E), significance relating to the hierarchy.

Most-significant labels (at the right) are colloquially known as
top-level domains (TLDs).

The maximum length of a label is 63 octets, and the maximum length
of a domain name is 255 octets.

Domain names may be presented with labels in scripts other than
US-ASCII.  In this case the representation of the label is known
as a U-Label; U-Labels are encoded into a US-ASCII form for
transmission between DNS clents and servers, known as A-Labels. The
whole business of dealing with Unicode in the DNS is [fraught with
complication](https://tools.ietf.org/rfc/rfc5890.txt); however, for
the purposes of this description the existence of U-Labels can be
safely ignored and A-Labels treated as any other US-ASCII DNS label.

Convenient examples of DNS names are WHISPERLAB.ORG and WWW.ENG.UWO.CA.

### Resource Records



### Infrastructure

### The Glue that BINDs

## The Kaminsky Attack

### Key Insights

### Impact and Exploitation

### Disclosure Process and Aftermath

### Legacy

