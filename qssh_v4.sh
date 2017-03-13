#!/bin/bash
ACCOUNT=${1:-devnp}
bold=$(tput bold)
normal=$(tput sgr0)
background=$(tput setab 0)
yellow=$(tput setaf 3)
red=$(tput setaf 1)
color1=$red
color2=$yellow
INSTANCES=()


describe-instances()
{
aws ec2 describe-instances --filters 'Name=tag:Name,Values='"*${ACCOUNT}*" 'Name=instance-state-code,Values=16' --region eu-west-1 --query 'Reservations[].Instances[].[[Tags[?Key==`Name`].Value][0][0],PrivateIpAddress]' --output table
}

convert_lines_to_array()
{
    OLD_IFS="$IFS"
    IFS='
    '
    IFS=${IFS:0:1}
    INSTANCES=( ${1} )
    IFS="$OLD_IFS"
}

get_array_of_aws_instances()
{
    # SORTED_TABLE=$(aws ec2 describe-instances --filters 'Name=tag:Name,Values='"*${ACCOUNT}*" 'Name=instance-state-code,Values=16' --region eu-west-1 --query 'Reservations[].Instances[].[[Tags[?Key==`Name`].Value][0][0],PrivateIpAddress]' --output table  | sed '1d; 2d; /vtw-apollo-pdf-asg-devnp/d' | sort -n )
    SORTED_TABLE=$( cat instances.txt | sed ' 1d; 2d; /vtw-apollo-pdf-asg-devnp/d' | sort -f -k1 )
    convert_lines_to_array "${SORTED_TABLE}"
}

display(){
    num_rows=${#INSTANCES[@]}
    table_line="${INSTANCES[$((num_rows-1))]}"
    printf "$bold$color1     %2s\n" $table_line
    for ((i = 0; i <= $((num_rows-3)); i++)); do
        if ! (( $i % 2 ))  ; then
            printf "$bold$color1 %2d  " $i
            printf '%s\n' $bold$color1"${INSTANCES[$i]}"$normal
        else
            printf "$bold$color2 %2d  " $i
            printf '%s\n' $bold${color2}"${INSTANCES[$i]}"$normal
        fi
    done
    printf "$bold$color1     %2s\n" $table_line

}

connect_to()
{
    read -e -p "${bold}        Connect to instance: " instance_number
    re='^[0-9]+$' #regex for numbers
    if [[ "$instance_number" =~ $re ]] ; then
        instance_name=$( echo ${INSTANCES[$((instance_number))]} | awk -F'|' '{print $2}')
        echo $instance_name
        instance_ip=$( echo ${INSTANCES[$((instance_number))]} | awk -F'|' '{print $3}')
        echo $instance_ip
        printf "${bold}${underline}Connecting to %s %s...${normal}" ${instance_name//[[:space:]]/} ${instance_ip//[[:space:]]/}
        # ssh -o StrictHostKeyChecking=no -i U:/.ssh/${USERNAME}.pem vtw-dev@${instance_ip//[[:space:]]/}
    else
        printf ${bold}${red}'Argument passed not a number: %s\n${normal}' ${instance_number} >&2
    fi
}

execute()
{
    get_array_of_aws_instances
    display
    connect_to
}
execute
