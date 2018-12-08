#!/usr/bin/awk -f
#
# Read an uncompressed dnscount-format summary with FILENAME of the form
#
#   xxxN_.*_udp_YYYYMMDD-HHMMSS
#
# xxxN is a site code. YYYYMMDD-HHMMSS is a UTC timestamp.
#
# Each such summary contains space-separated records, one per line, of
# the form
#
#   time_t server_address client_address QTYPE QNAME RCODE FLAGS
#
# server_address is either a v4 or v6 address in presentation format;
# QNAME is a domain name; all other fields are numeric.
#
# Produce summary records in CSV format for each unique client_address
# with the following columns:
#
#   out_timestamp
#   out_sitecode
#   out_client
#   out_class
#   out_responses
#   out_max_labelsize
#   out_mean_labelsize
#   out_tlds_seen
#   out_slds_seen
#   out_prop_1_label
#   out_prop_2_label
#   out_prop_3_label
#   out_prop_4_label
#   out_prop_rcode_0 # NOERROR
#   out_prop_rcode_3 # NXDOMAIN
#   out_prop_qtype_1 # A
#   out_prop_qtype_2 # NS
#   out_prop_qtype_5 # CNAME
#   out_prop_qtype_6 # SOA
#   out_prop_qtype_10 # NULL
#   out_prop_qtype_12 # PTR
#   out_prop_qtype_15 # MX
#   out_prop_qtype_16 # TXT
#   out_prop_qtype_28 # AAAA
#   out_prop_qtype_33 # SRV
#   out_prop_qtype_35 # NAPTR
#   out_prop_qtype_37 # CERT
#   out_prop_qtype_38 # A6
#   out_prop_qtype_43 # DS
#   out_prop_qtype_44 # SSHFP
#   out_prop_qtype_46 # RRSIG
#   out_prop_qtype_48 # DNSKEY
#   out_prop_qtype_52 # TLSA
#   out_prop_qtype_99 # SPF
#   out_prop_qtype_255 # ANY
#   out_prop_qtype_256 # URI
#   out_prop_qtype_257 # CAA
#   out_prop_qtype_32769 # DLV

BEGIN {
  # require filenme variable to be set; we don't expect to be able to
  # rely upon FILENAME being useful since we are probably in a pipeline
  # with bzip2

  if (filename !~ /^[a-z]+[0-9]_.*_[0-9]+-[0-9]+$/) {
    exit 1
  }

  n = split(filename, a_filename, /_/);
  out_sitecode = a_filename[1];
  out_timestamp = a_filename[n];
}


# match all input lines
{
  # identify fields from input
  in_timestamp = $1;
  in_server = $2;
  in_client = $3;
  in_qtype = $4;
  in_qname = tolower($5);
  in_rcode = $7;

  # only check clients that we care about
  class = "";

  if (in_client ~ /^(2607:f8b0:|2800:3f0:|2a00:1450:)/) {
    class = "google";
  }

  if (in_client ~ /^(31\.13\.11[2345]\.|66\.220\.149\.|66\.220\.152\.|66\.220\/156\.|69\.63\.188\.|69\.171\.22[45]\.|69\.171\.240\.|69\.171\.251\.|173\.252\.8[456789]\.|173\.252\.12|173\.252\.243\.)/) {
    class = "facebook";
  }

  if (in_client ~ /^(138\.246\.253\.|107\.161\.26\.|137\.236\.113\.|189\.90\.40\.|193\.106\.30\.|192\.243\.53\.)/) {
    class = "other";
  }

  if (!class) {
    next;
  }

  # remember this client
  client[in_client] = 1;

  # for out_class
  out_class[in_client] = class;

  # count this response
  out_responses[in_client]++;

  # deconstruct QNAME
  labels = split(in_qname, a_qname, /\./);

  # for out_max_labelsize and out_mean_labelsize
  for (i = 1; i <= labels; i++) {
    size = length(a_qname[i]);
    if (size > out_max_labelsize[in_client]) {
      out_max_labelsize[in_client] = size;
    }
    sum_labelsize[in_client] += size;
  }
  count_labels[in_client] += labels;

  # for out_tlds_seen
  domain = a_qname[labels];
  if (!seen_domain[in_client, domain]) {
    seen_domain[in_client, domain] = 1;
    out_tlds_seen[in_client]++;
  }

  # for out_slds_seen
  if (labels > 1) {
    domain = a_qname[labels - 1] "." a_qname[labels];
    if (!seen_domain[in_client, domain]) {
      seen_domain[in_client, domain] = 1;
      out_slds_seen[in_client]++;
    }
  }

  # for out_prop_1_label
  if (labels == 1) {
    count_1_label[in_client]++;
  }

  # for out_prop_2_label
  if (labels == 2) {
    count_2_label[in_client]++;
  }

  # for out_prop_3_label
  if (labels == 3) {
    count_3_label[in_client]++;
  }

  # for out_prop_4_label
  if (labels == 4) {
    count_4_label[in_client]++;
  }

  # for out_prop_rcode_0
  if (rcode == 0) {
    count_rcode_0[in_client]++;
  }

  # for out_prop_rcode_3
  if (rcode == 3) {
    count_rcode_3[in_client]++;
  }

  # for out_prop_qtype_1
  if (in_qtype == 1) {
    count_qtype_1[in_client]++;
  }

  # for out_prop_qtype_2
  if (in_qtype == 2) {
    count_qtype_2[in_client]++;
  }

  # for out_prop_qtype_5
  if (in_qtype == 5) {
    count_qtype_5[in_client]++;
  }

  # for out_prop_qtype_6
  if (in_qtype == 6) {
    count_qtype_6[in_client]++;
  }

  # for out_prop_qtype_10
  if (in_qtype == 10) {
    count_qtype_10[in_client]++;
  }

  # for out_prop_qtype_12
  if (in_qtype == 12) {
    count_qtype_12[in_client]++;
  }

  # for out_prop_qtype_15
  if (in_qtype == 15) {
    count_qtype_15[in_client]++;
  }

  # for out_prop_qtype_16
  if (in_qtype == 16) {
    count_qtype_16[in_client]++;
  }

  # for out_prop_qtype_28
  if (in_qtype == 28) {
    count_qtype_28[in_client]++;
  }

  # for out_prop_qtype_33
  if (in_qtype == 33) {
    count_qtype_33[in_client]++;
  }

  # for out_prop_qtype_35
  if (in_qtype == 35) {
    count_qtype_35[in_client]++;
  }

  # for out_prop_qtype_37
  if (in_qtype == 37) {
    count_qtype_37[in_client]++;
  }

  # for out_prop_qtype_38
  if (in_qtype == 38) {
    count_qtype_38[in_client]++;
  }

  # for out_prop_qtype_43
  if (in_qtype == 43) {
    count_qtype_43[in_client]++;
  }

  # for out_prop_qtype_44
  if (in_qtype == 44) {
    count_qtype_44[in_client]++;
  }

  # for out_prop_qtype_46
  if (in_qtype == 46) {
    count_qtype_46[in_client]++;
  }

  # for out_prop_qtype_48
  if (in_qtype == 48) {
    count_qtype_48[in_client]++;
  }

  # for out_prop_qtype_52
  if (in_qtype == 52) {
    count_qtype_52[in_client]++;
  }

  # for out_prop_qtype_99
  if (in_qtype == 99) {
    count_qtype_99[in_client]++;
  }

  # for out_prop_qtype_255
  if (in_qtype == 255) {
    count_qtype_255[in_client]++;
  }

  # for out_prop_qtype_256
  if (in_qtype == 256) {
    count_qtype_256[in_client]++;
  }

  # for out_prop_qtype_257
  if (in_qtype == 257) {
    count_qtype_257[in_client]++;
  }

  # for out_prop_qtype_32769
  if (in_qtype == 32769) {
    count_qtype_32769[in_client]++;
  }
}

# produce one observation vector per (out_timestamp, out_sitecode, out_client)
# tuple

END {
  for (out_client in client) {
    print \
      out_timestamp "," \
      out_sitecode "," \
      out_client "," \
      out_class[out_client] "," \
      out_responses[out_client] "," \
      out_max_labelsize[out_client] "," \
      sum_labelsize[out_client] / count_labels[out_client] "," \
      out_tlds_seen[out_client] + 0 "," \
      out_slds_seen[out_client] + 0 "," \
      count_1_label[out_client] / out_responses[out_client] "," \
      count_2_label[out_client] / out_responses[out_client] "," \
      count_3_label[out_client] / out_responses[out_client] "," \
      count_4_label[out_client] / out_responses[out_client] "," \
      count_rcode_0[out_client] / out_responses[out_client] "," \
      count_rcode_3[out_client] / out_responses[out_client] "," \
      count_qtype_1[out_client] / out_responses[out_client] "," \
      count_qtype_2[out_client] / out_responses[out_client] "," \
      count_qtype_5[out_client] / out_responses[out_client] "," \
      count_qtype_6[out_client] / out_responses[out_client] "," \
      count_qtype_10[out_client] / out_responses[out_client] "," \
      count_qtype_12[out_client] / out_responses[out_client] "," \
      count_qtype_15[out_client] / out_responses[out_client] "," \
      count_qtype_16[out_client] / out_responses[out_client] "," \
      count_qtype_28[out_client] / out_responses[out_client] "," \
      count_qtype_33[out_client] / out_responses[out_client] "," \
      count_qtype_35[out_client] / out_responses[out_client] "," \
      count_qtype_37[out_client] / out_responses[out_client] "," \
      count_qtype_38[out_client] / out_responses[out_client] "," \
      count_qtype_43[out_client] / out_responses[out_client] "," \
      count_qtype_44[out_client] / out_responses[out_client] "," \
      count_qtype_46[out_client] / out_responses[out_client] "," \
      count_qtype_48[out_client] / out_responses[out_client] "," \
      count_qtype_52[out_client] / out_responses[out_client] "," \
      count_qtype_99[out_client] / out_responses[out_client] "," \
      count_qtype_255[out_client] / out_responses[out_client] "," \
      count_qtype_256[out_client] / out_responses[out_client] "," \
      count_qtype_257[out_client] / out_responses[out_client] "," \
      count_qtype_32769[out_client] / out_responses[out_client];
  }
}

