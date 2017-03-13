#!/bin/bash

set -a filenames $(ls $1)
typeset -l fname
let numcols=5

for ((count = 0; count < ${#filenames[*]} ; count++)); do
    fname=${filenames[count]}
    print -rn "$fname  "
    if (( (count+1) % numcols == 0 )); then
        print           # newline
    fi
done

if (( count % numcols != 0 )); then
    print
fi