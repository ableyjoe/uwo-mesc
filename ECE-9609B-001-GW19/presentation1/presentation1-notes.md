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
filesystem restriction on filenames (/traceroute/ is two letters
too long).


