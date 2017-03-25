#!/bin/bash

GRAY=$(tput rev)
NORMAL=$(tput sgr0)

i=0
while read line; do
    if [[ $(( i % 2 )) == 0 ]]; then
        echo ${GRAY}"${line}"${NORMAL}
    else
        echo "$line"
    fi
    ((i++))
done < describe-instances2.txt
#
