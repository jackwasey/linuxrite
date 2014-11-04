#!/bin/bash

my_dir=${0%/*}
source "$my_dir/common.sh"

# TODO: output in stdout is a list of blocks that didn't read back what I wrote in.
# all other output on stderr

# create a zero block to compare against later
ZERODAT=$SECTORDATDIR/zeroes.dat
dd if=/dev/zero of=$ZERODAT bs=4096 count=1

while read sector; do
 printf "WRITING %sb sector %s" $LOGBLK $sector 1>&2
 bigblock=$((sector * LOGBLK / PHYSBLK))
 printf " which is %sb block number: %s\n" $PHYSBLK $bigblock 1>&2

 SECTORFILE=$SECTORDATDIR/$sector.dat
 SECTORFILECMP=$SECTORDATDIR/${sector}cmp.dat
 SECTORFILECMPZ=$SECTORDATDIR/${sector}cmpz.dat

 printf "Testing sector data file $SECTORFILE\n" 1>&2 
 if [ ! -f $SECTORFILE ]; then
   SECTORFILE=/dev/zero
 fi
 printf "Using sector  data  file $SECTORFILE\n" 1>&2


 # write recovered data, or zero if none
 sudo dd \
   if=$SECTORFILE \
   of=$DISK \
   count=1 \
   bs=$PHYSBLK \
   seek=$bigblock \
   oflag=direct \
   status=none \
   conv=noerror 

 # what do we get back?
sudo dd \
    if=$DISK \
    of=$SECTORFILECMP \
    count=1 \
    bs=$PHYSBLK \
    skip=$bigblock \
    status=none \
    conv=noerror \
    iflag=direct

CMP=$(cmp $SECTORFILE $SECTORFILECMP)
if [ "$CMP" != "" ]; then
  printf "re-read data differs from written data for sector %s\n" $sector
else
  printf "re-read data correct for sector %s\n" $sector
fi

 # write zeroes
 sudo dd \
   if=/dev/zero \
   of=$DISK \
   count=1 \
   bs=$PHYSBLK \
   seek=$bigblock \
   oflag=direct \
   status=none \
   conv=noerror 

 # what do we get back?
sudo dd \
    if=$DISK \
    of=$SECTORFILECMPZ \
    count=1 \
    bs=$PHYSBLK \
    skip=$bigblock \
    status=none \
    conv=noerror \
    iflag=direct


CMPZ=$(cmp $ZERODAT $SECTORFILECMPZ)
if [ "$CMPZ" != "" ]; then
  printf "re-read zeroes differs from zeroes written to sector %s\n" $sector
else
  printf "re-read zeroes correct for sector %s\n" $sector
fi


 # write recovered data, or zero if none
 sudo dd \
   if=$SECTORFILE \
   of=$DISK \
   count=1 \
   bs=$PHYSBLK \
   seek=$bigblock \
   oflag=direct \
   status=none \
   conv=noerror 

 # what do we get back?
sudo dd \
    if=$DISK \
    of=$SECTORFILECMP \
    count=1 \
    bs=$PHYSBLK \
    skip=$bigblock \
    status=none \
    conv=noerror \
    iflag=direct

CMP=$(cmp $SECTORFILE $SECTORFILECMP)
if [ "$CMP" != "" ]; then
  printf "re-read data differs from written data for sector %s\n" $sector
else
  printf "re-read data correct for sector %s\n" $sector
fi


done

