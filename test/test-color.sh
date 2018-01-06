#!/bin/bash

source ../lib/msg.sh
source ../lib/color.sh
source ../lib/if.sh

_msg ECHO "Begin color.sh test"
for cmd in fg bfg bg; do
    for col in blk red grn yel blu mag cyn gry; do
        echo "Testing _color $(_color ${cmd} ${col})${cmd} ${col}$(_color rs)"
    done
done
_msg ECHO "End color.sh test"

