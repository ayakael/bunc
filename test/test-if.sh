#!/bin/bash

source "../lib/if.sh"

echo "_if_array_contains test started"
for result in 2 2 0 1; do
    echo "Exit code should be ${result}"
    eArray=(aa ab 0 dsa 2)
    i=${result}
    _if_array_contains "${i}" "${eArray[@]}"
    echo $?
done
echo "_if_array_contains test ended"

echo "_if_is_integer test started"
for result in 0 1; do
    echo "Exit code should be ${result}"
    if [ ${result} == 0 ]; then 
        i=0
    else
        i=a
    fi
    _if_is_integer ${i}
    echo $?
done
echo "_if_is_integer test ended"
