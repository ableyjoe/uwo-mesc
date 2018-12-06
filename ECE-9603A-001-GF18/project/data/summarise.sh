#!/bin/sh

SUMMARISE=./summarise.awk
SOURCE=./source
DATA=./summary

day=$1

if [ -z "${day}" ]
then
  echo "specify a two-digit day" >&1
  exit 1
fi

find -L ${SOURCE}/${d} -type f -name "*201811${day}-*bz2" | while read f
do
  filename=$(basename ${f} .bz2)

  if [ -f ${DATA}/${filename}.csv ]
  then
    echo "bzipping ${filename}.csv"
    bzip2 ${DATA}/${filename}.csv
  fi

  if [ -f ${DATA}/${filename}.csv.bz2 ]
  then
    echo "already processed ${f}"
  else
    echo "processing ${f}"
    bzip2 -cd ${f} | awk -v filename=${filename} -f summarise.awk \
      >${DATA}/${filename}.csv
    bzip2 ${DATA}/${filename}.csv
  fi
done

