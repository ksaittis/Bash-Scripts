#!/bin/bash

readarray INSTANCES < ./describe-instances2.txt

display_array()
{
    for i in ${!INSTANCES[@]}; do
        echo -n "${INSTANCES[$i]}"
    done
}

getSpecificIp()
{
    :
}

loop_instances()
{
    j=0
    for i in $@; do
        echo $j: $i
        ((j++))
    done
}

# loop_instances $@
display_array
