#!/bin/bash
NAME=${1:-devnp}
INSTANCES=()


describe-instances()
{
aws ec2 describe-instances --filters 'Name=tag:Name,Values='"*${NAME}*" 'Name=instance-state-code,Values=16' --region eu-west-1 --query 'Reservations[].Instances[].[[Tags[?Key==`Name`].Value][0][0],PrivateIpAddress]' --output table
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
    printf "     %2s\n" "$table_line"
    for ((i = 0; i <= $((num_rows-3)); i++)); do
        if ! (( $i % 2 ))  ; then
            printf " %2d  " $i
            printf '%s\n' "${INSTANCES[$i]}"
        else
            printf " %2d  " $i
            printf '%s\n' "${INSTANCES[$i]}"
        fi
    done
    printf "     %2s\n" $table_line

}

connect_to()
{
    read -e -p "        Connect to instance: " instance_number
    re='^[0-9]+$' #regex for numbers
    if [[ "$instance_number" =~ $re ]] ; then
        instance_name=$( echo ${INSTANCES[$((instance_number))]} | awk -F'|' '{print $2}')
        echo $instance_name
        instance_ip=$( echo ${INSTANCES[$((instance_number))]} | awk -F'|' '{print $3}')
        echo $instance_ip
        printf "Connecting to %s %s..." ${instance_name//[[:space:]]/} ${instance_ip//[[:space:]]/}
        # ssh -o StrictHostKeyChecking=no -i U:/.ssh/${USERNAME}.pem vtw-dev@${instance_ip//[[:space:]]/}
    else
        printf 'Argument passed not a number: %s\n${normal}' ${instance_number} >&2
    fi
}

execute()
{
    get_array_of_aws_instances
    display
    connect_to
}

execute
