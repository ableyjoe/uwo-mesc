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
#   out_prop_rcode_1 # FORMERR
#   out_prop_rcode_2 # SERVFAIL
#   out_prop_rcode_3 # NXDOMAIN
#   out_prop_rcode_4 # NOTIMP
#   out_prop_rocde_5 # REFUSED
#   out_prop_rcode_6 # YXDOMAIN
#   out_prop_rcode_7 # YXRRSET
#   out_prop_rcode_8 # NXRRSET
#   out_prop_rcode_9 # NOTAUTH
#   out_prop_rcode_10 # NOTZONE
#   out_prop_qtype_1 # A
#   out_prop_qtype_2 # NS
#   out_prop_qtype_5 # CNAME
#   out_prop_qtype_6 # SOA
#   out_prop_qtype_15 # MX
#   out_prop_qtype_16 # TXT
#   out_prop_qtype_28 # AAAA
#   out_prop_qtype_48 # DNSKEY
#   out_prop_qtype_255 # ANY

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
  in_rcode = $6;
  in_flags = $7;

  # discard responses to queries that arrived with RD=1
  # (check bit 1)
  if (int(in_flags / 2) % 2 == 1)
    next;

  # remember this client
  client[in_client] = 1;

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
  if (in_rcode == 0) {
    count_rcode_0[in_client]++;
  }

  # for out_prop_rcode_1
  if (in_rcode == 1) {
    count_rcode_1[in_client]++;
  }

  # for out_prop_rcode_2
  if (in_rcode == 2) {
    count_rcode_2[in_client]++;
  }

  # for out_prop_rcode_3
  if (in_rcode == 3) {
    count_rcode_3[in_client]++;
  }

  # for out_prop_rcode_4
  if (in_rcode == 4) {
    count_rcode_4[in_client]++;
  }

  # for out_prop_rcode_5
  if (in_rcode == 5) {
    count_rcode_5[in_client]++;
  }

  # for out_prop_rcode_5
  if (in_rcode == 6) {
    count_rcode_6[in_client]++;
  }

  # for out_prop_rcode_5
  if (in_rcode == 7) {
    count_rcode_7[in_client]++;
  }

  # for out_prop_rcode_5
  if (in_rcode == 8) {
    count_rcode_8[in_client]++;
  }

  # for out_prop_rcode_5
  if (in_rcode == 9) {
    count_rcode_9[in_client]++;
  }

  # for out_prop_rcode_5
  if (in_rcode == 10) {
    count_rcode_10[in_client]++;
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

  # for out_prop_qtype_48
  if (in_qtype == 48) {
    count_qtype_48[in_client]++;
  }

  # for out_prop_qtype_255
  if (in_qtype == 255) {
    count_qtype_255[in_client]++;
  }

  # for out_prop_qtype_other
  if (in_qtype == 1) {
    count_qtype_1[in_client]++;
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
      count_rcode_1[out_client] / out_responses[out_client] "," \
      count_rcode_2[out_client] / out_responses[out_client] "," \
      count_rcode_3[out_client] / out_responses[out_client] "," \
      count_rcode_4[out_client] / out_responses[out_client] "," \
      count_rcode_5[out_client] / out_responses[out_client] "," \
      count_rcode_6[out_client] / out_responses[out_client] "," \
      count_rcode_7[out_client] / out_responses[out_client] "," \
      count_rcode_8[out_client] / out_responses[out_client] "," \
      count_rcode_9[out_client] / out_responses[out_client] "," \
      count_rcode_10[out_client] / out_responses[out_client] "," \
      count_qtype_1[out_client] / out_responses[out_client] "," \
      count_qtype_2[out_client] / out_responses[out_client] "," \
      count_qtype_5[out_client] / out_responses[out_client] "," \
      count_qtype_6[out_client] / out_responses[out_client] "," \
      count_qtype_15[out_client] / out_responses[out_client] "," \
      count_qtype_16[out_client] / out_responses[out_client] "," \
      count_qtype_28[out_client] / out_responses[out_client] "," \
      count_qtype_48[out_client] / out_responses[out_client] "," \
      count_qtype_255[out_client] / out_responses[out_client];
  }
}

