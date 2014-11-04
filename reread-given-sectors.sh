#!/bin/bash

my_dir=${0%/*}
source "$my_dir/common.sh"

# read from stdin which sectors were mentioned in ATA errors. These are not necessarily all the uncorrectable read errors.
# dd direct read all these sectors: the result of this can be used to see which really couldn't read.

# create two dirs in which to store retrieved sector data and dd error logs, one sector per file.
# delete existing sectors (may be corrupt, from different disks, etc.)
# If re-running on the same disk, may be value in keeping, but this starts to get complicated a la Spinrite.

# sector errors
mkdir -p $SECTORERRDIR
rm $SECTORERRDIR/*

# sector data
mkdir -p $SECTORDATDIR
rm $SECTORDATDIR/*

while read sector; do
 printf "Reading %sb sector %s" $LOGBLK $sector 1>&2
 bigblock=$((sector * LOGBLK / PHYSBLK))
 printf " which is %sb block number: %s\n" $PHYSBLK $bigblock 1>&2

 # do dd and if as one long command with ampersand to background each process.
 sudo dd \
    if=$DISK \
    of=$SECTORDATDIR/$sector.dat \
    count=1 \
    bs=$PHYSBLK \
    skip=$bigblock \
    status=none \
    conv=noerror \
    iflag=direct 2>$SECTORERRDIR/$sector.err; \
    if grep --quiet error $SECTORERRDIR/$sector.err; then echo $sector; fi &
done


