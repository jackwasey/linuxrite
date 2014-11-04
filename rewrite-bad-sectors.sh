#!/bin/bash

my_dir=${0%/*}
source "$my_dir/common.sh"

read -p "Extreme danger. This will write blocks directly to a hard-coded drive. Run reread-bad-sectors first. 
We assume the disk is 512b logical formatted and 4KiB physically formatted.
Press a key to continue..."

if [ ! -e $REALLYBADSECTORS ]; then
  echo "Seriously, run reread-bad-sectors first, then there will be input data which has list of sectors definitely not read"
  exit 0
fi

cat $REALLYBADSECTORS | "$my_dir/rewrite-given-bad-sectors.sh"

