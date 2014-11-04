#!/bin/bash

my_dir=${0%/*}
source "$my_dir/common.sh"

# read from kernel log what sectors were mentioned in ATA errors. These are not necessarily all the uncorrectable read errors.
# dd direct read all these sectors: the result of this can be used to see which really couldn't read.

truncate -s0 $REALLYBADSECTORS

"$my_dir/get-logged-bad-sectors.sh" | "$my_dir/reread-given-sectors.sh" >> $REALLYBADSECTORS

