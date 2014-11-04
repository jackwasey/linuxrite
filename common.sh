#!/bin/bash


my_dir=${0%/*}
source "$my_dir/local.sh"

PHYSBLK=4096
LOGBLK=512

SECTORDATDIR=/tmp/badsctrs/dat
SECTORERRDIR=/tmp/badsctrs/err

REALLYBADSECTORS=/tmp/badsctrs/really-bad-512byte.txt
