#!/bin/bash

grep ", sector " /var/log/kern.log{,.1} | \
  awk -F', sector ' '{ print $2 }' | \
  sort -n -u

