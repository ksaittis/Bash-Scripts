#!/bin/bash
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
NORMAL=$(tput sgr0)

makeline_v2()
{
    COLUMNS=$(tput cols)
    printf "%${1:-$COLUMNS}s\n" "" | tr " " ${2:-#}
}


makeline()
{
    printf "%$(($(tput cols)))s" " " | tr " " ${1:-=}
}

centerPrint()
{
    parameters=$*
    string_length=${#parameters}
    pos=$(( ($(tput cols) + string_length ) /2 ))
    printf "%*s\n" $pos "$parameters"
}

display_unsuccessful_login_msg()
{
    makeline \#
    centerPrint ${YELLOW}"Unsuccessful login attemp to $instance_name in $ACCOUNT account."
    centerPrint "USERNAME: $USERNAME and KEY: $KEY did not work."${NORMAL}
    makeline -
    centerPrint ${BLUE}"POSSIBLE SCENARIOS"
    centerPrint "Security groups on $instance_name are not configured to allow you access."
    centerPrint "Key used is not in the .ssh/authorisedKeys on the specific instance."
    centerPrint "You are trying to connect to a windows box."${NORMAL}
    makeline \#
}

# makeline2 $1
display_unsuccessful_login_msg
