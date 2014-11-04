#!/bin/bash

# find and overwrite bad sectors full auto. MASSIVE DANGER OF MISTAKES HERE.


my_dir=${0%/*}
source "$my_dir/common.sh"

"$my_dir/reread-bad-sectors.sh"
"$my_dir/rewrite-bad-sectors.sh"

