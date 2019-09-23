# Rough Notes

## Quick Links

 - [List of](implementations.md) Open Source DNSSEC key generation and validation implementations
 - [Roy Arends' walk down keytag lane](Quest_for_the_missing_keytags.pdf)
 - [Roland van Rijswijk-Deij's musings](RIPE-78-DNS-wg-Keytags.pdf) about the implications and suitability of the keytag algorithm in general

## Introducing the Problem

DNSSEC signatures that are published in the DNS are bundled with a keytag,
an identifier that provides hints to DNSSEC validators that need to identify
an appropriate public key with which to perform signature validation.

Keytags are computed rather than assigned, and it is possible that two
different public keys published with the same DNS owner name can have
identical key tags.

Keytags observed in the wild are observed not to be especially random;
the solution space contains structure. Some of this structure might be
related to the corresponding structure in the DNSKEY RDATA which is used
as input for the keytag algorithm. It is also possible that the algorithm
itself introduces some structure in its output. The probabilty density
of the keytag solution space makes keytag collisions more likely than
would otherwise be imagined.

We assess the impact of keytag collisions on the workload of DNSSEC
validators, and attempt to identify degenerate circumstances whereby
a miscreant could choose particular keys in order to maximise the
workload of a validator attempting to validate DNS responses that
are signed using keys that exhibit keytag collision. We provide a
theoretical risk assessment for potential vulnerabilities in DNSSEC
validators to denial of service attacks using these circumstances.

We compare the computational cost of open-source DNSSEC validators
exposed to the attack imagined above with the theoretical impact,
and identify any implementation differences between particular
packages that result in different degrees of vulnerability. We attempt
to identify improvements in the DNSSEC validator software that would
reduce the impact of this attack.

We analyse the generation of keytags over DNSKEY RRs corresponding to
algorithms and key lengths that are standardised and used at the time
of writing, and assess the characteristics of the keytag algorithm,
in particular with respect to the probability of multiple,
randomly-generated keys giving rise to the same keytags.

We compare the performance of the DNSSEC keytag algorithm with other
similar functions both in terms of complexity and collision resistance.

We review open-source DNSSEC key generation software and identify any
implementation-specific features that result in keytag collisions being
differently probable from that predicted from the analysis.

We propose changes to DNSSEC software to make keytag collisions less
prevalent, so that accidental attacks, although rare, could be made
impossible for zones whose keys are generated according to these
recommendations.

## Background

DNSSEC is the umbrella term for a set of security extensions to the
DNS, as documented in RFC 4033 and companion documents.

DNSSEC, loosely, is concerned with (a) the publication of keys and
cryptographic signatures in the DNS, together forming a verifiable
attestation of authenticity for DNS data that has otherwise been
shown to be fairly trivial to mess with, and (b) the validation of
signatures and the DNS data that the signatures were made over in
order to determine whether the DNS data is genuine. Data that is
not authentic can be discarded before it has a chance to cause
problems for end users or the applications they are using.

DNSSEC public keys are published in the DNS using DNSKEY resource records.
Each such resource record is anchored (like any other DNS resource record)
at a particular _owner name._ Other fields in the DNSKEY resource record
identify algorithms, etc. Here's an example.

```
hopcount.ca.		2178 IN	DNSKEY 256 3 13 (
				oJMRESz5E4gYzS/q6XDrvU1qMPYIjCWzJaOau8XNEZeq
				CYKD5ar0IRd8KqXXFJkqmVfRvMGPmM1x8fGAa2XhSA==
				) ; ZSK; alg = ECDSAP256SHA256 ; key id = 34505
```

The relevant field for this discussion in that example is the owner
name `hopcount.ca`, together with the fact that the key id `34505`
is not part of the RDATA of the DNSKEY RR, which is why it is highlighted
above as a comment. More about this, below.

The purpose of a key is to generate signatures. An example of a
signature generated using the private key corresponding to the
public key illustrated above is:

```
hopcount.ca.		2162 IN	SOA barbara.ns.cloudflare.com. dns.cloudflare.com. (
				2031987518 ; serial
				10000      ; refresh (2 hours 46 minutes 40 seconds)
				2400       ; retry (40 minutes)
				604800     ; expire (1 week)
				3600       ; minimum (1 hour)
				)
hopcount.ca.		2162 IN	RRSIG SOA 13 2 3600 (
				20190924041440 20190922021440 34505 hopcount.ca.
				lf20bhcb0rNhNLWIALprToOmB72cQjC4q96BoJPAmkEJ
				VuRVEXo6kkMXb2zN2RfnAJKluYOqQkDlKykqpE5EAg== )
```

Shown here is the SOA resource record for the `hopcount.ca` zone,
together with its signature (a DNSSEC signature over the SOA DNS
resource record) encoded as an RRSIG RR. The RRSIG RDATA
contains various fields such as inception and expiry dates, but
importantly for this discussion, it also specifies an owner name
for the key that should be used to validate this signature,
`hopcount.ca`, and a keytag, `34505`.

Since many different DNSKEY resource records may (and frequently are)
be associated with the same owner name, the keytag provides an
identifier that allows a validator to optimise what might otherwise
be an expensive search through all DNSKEY RRs it found for all signatures
made with that key, and instead just choose the public keys whose
keytags match; validation attempts using other public keys can be avoided
without risk to the security model.

The key id (or _keytag_) is computed using an
algorithm described in appendix B of RFC 4034, namely:

```
unsigned int
   keytag (
           unsigned char key[],  /* the RDATA part of the DNSKEY RR */
           unsigned int keysize  /* the RDLENGTH */
          )
   {
           unsigned long ac;     /* assumed to be 32 bits or larger */
           int i;                /* loop index */

           for ( ac = 0, i = 0; i < keysize; ++i )
                   ac += (i & 1) ? key[i] : key[i] << 8;
           ac += (ac >> 16) & 0xFFFF;
           return ac & 0xFFFF;
   }
```

(A different algorithm is specified for alorithm 1, RSA/MD5, for
historical reasons. However, since RSA/MD5 is no longer recommended
for use in DNSSEC, it is reaosnable to ignore it.)

## Other Relevant Work

The seeds that may yet germinate into some kind of coherent paper
were scattered liberally around a presentation that Roland van Rijswijk-Deij
delivered at the RIPE 78 meeting in Reykjavik in 2019.
[His slides are here](RIPE-78-DNS-wg-Keytags.pdf).

Some earlier work by Roy Arends at ICANN regarding the range of keytags
that were not observed in the wild is described in a presentation he
made at a DNS-OARC meeting in Buenos Aires.
[His slides are here](Quest_for_the_missing_keytags.pdf).

## Things to Look At

## Insights and Results

## Summary

## Areas for Future Study

