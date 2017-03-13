#!/bin/bash
YELLOW=$(tput setaf 3)

centerPrint()
{
    parameters=$*
    string_length=${#parameters}
    pos=$(( ($(tput cols) + string_length ) /2 ))
    printf "%*s" $pos "$parameters"
}

# centerPrint $@

instance_name=server1
account=Production
centerPrint $YELLOW"You were not able to login to: $instance_name Account: $account"
