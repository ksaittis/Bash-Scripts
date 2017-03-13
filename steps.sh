#!/bin/bash
num_steps=${1:-20}

COLUMNS=$(tput cols)


# for (( i=1; i <= $num_steps; i++ )); do
#     printf "%$((num_steps -i))s\n" "" | tr " " ${2:-#}
# done
#
# for (( i=1; i <= $num_steps; i++ )); do
#     printf "%$((i))s\n" "" | tr " " ${2:-#}
# done

# for (( i=1; i <= $num_steps; i++ )); do
#     # printf "%${COLUMNS}s%$(( COLUMNS - i))s\n" a b
#     printf "%$((COLUMNS))s\n" b
# done


# echo "${s// /*}"


word="hello                    World"
word2="       hello                    World        111"
echo ${word// /.}
echo ${word2// /.}
echo ${word//[[:space:]]/}


IFS='%'
echo $word | tr " " "."
unset IFS
