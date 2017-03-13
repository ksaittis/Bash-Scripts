#!/bin/bash
bold=$(tput bold)
normal=$(tput sgr0)
background=$(tput setab 0)
yellow=$(tput setaf 3)
red=$(tput setaf 1)
color1=$red
color2=$yellow

describe-instances()
{
aws ec2 describe-instances --filters 'Name=tag:Name,Values='"*${ACCOUNT}*" 'Name=instance-state-code,Values=16' --region eu-west-1 --query 'Reservations[].Instances[].[[Tags[?Key==`Name`].Value][0][0],PrivateIpAddress]' --output table
}

create_file()
{
    describe-instances > describe-instances.txt
}

display_v3(){
    j=0;
    echo $bold$color2-----------------------------------------------------------------$normal
    while read line; do
        if ! (( $j % 2 ))  ; then
            printf "$bold$color1 %2d  " $j
            printf '%s\n' $bold$color1"$line"$normal
        else
            printf "$bold$color2 %2d  " $j
            printf '%s\n' $bold${color2}"$line"$normal
        fi
        ((j++))
    done < describe-instances2.txt
    echo $bold$color1-----------------------------------------------------------------$normal
}

connect_to()
{
    read -p "Connect to instance: " instance_number
    re='^[0-9]+$' #regex for numbers
    if [[ "$instance_number" =~ $re ]] ; then
		clear
        instance_name=$(sed '40q;d' describe-instances2.txt | awk -F'|' '{print $2}')
        ip=$(sed '40q;d' describe-instances2.txt | awk -F'|' '{print $3}')
        rm describe-instances.txt
		printf "${bold}${underline}Connecting to %s %s...${normal}" ${instance_name//[[:space:]]/} ${ip//[[:space:]]/}
        # ssh -o StrictHostKeyChecking=no -i U:/.ssh/ksaittis.pem vtw-dev@${instance_ip//[[:space:]]/}
    else
        printf ${bold}${red}'Argument passed not a number: %s' ${instance_number} >&2
        exit 1
    fi
}

execute_script()
{
    create_file
    display_v3
    connect_to
}
