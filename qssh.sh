#!/bin/bash
ACCOUNT=${1:-devnp}
red=$(tput setaf 1)
bold=$(tput bold)
underline=$(tput smul)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
normal=$(tput sgr0)


describe-instances()
{
aws ec2 describe-instances --filters 'Name=tag:Name,Values='"*${ACCOUNT}*" 'Name=instance-state-code,Values=16' --region eu-west-1 --query 'Reservations[].Instances[].[[Tags[?Key==`Name`].Value][0][0],PrivateIpAddress]' --output table
}

# IPs=`describe-instances | sed '/DescribeInstances/d; /-+/d; /vtw-apollo-pdf-asg-devnp/d' | awk -F"|" '{print $3}' `
describe-instances | sed '/DescribeInstances/d; /-+/d; /vtw-apollo-pdf-asg-devnp/d' | sort -n | awk -F"|" '{print $3}' > ips
readarray IPs <  ips

# INSTANCES=`describe-instances | sed '/DescribeInstances/d; /-+/d; /vtw-apollo-pdf-asg-devnp/d' | awk -F"|" '{print $2}' `
describe-instances | sed '/DescribeInstances/d; /-+/d; /vtw-apollo-pdf-asg-devnp/d' | sort -n | awk -F"|" '{print $2}' > instances
readarray INSTANCES < instances

display()
{
	echo
	number_elements=$(( ${#INSTANCES[@]} -1 ))
	printf '   %s\t\t\t\t\t%s\n' INSTANCE IP
	echo --------------------------------------------------------------
for i in $(seq 1 $number_elements); do
	empty_space=`echo ${INSTANCES[$i]} | wc -c`
	empty_space=$(( 55 - empty_space ))
    printf '%s: %s %*s\n' "$i" ${INSTANCES[$i]} $empty_space ${IPs[$i]} 
done
}

connect_to()
{
    echo --------------------------------------------------------------------
    read -p "Connect to instance: " instance_number
    re='^[0-9]+$' #regex for numbers
    if [[ "$instance_number" =~ $re ]] ; then
        instance_ip=${IPs[$instance_number]}
        echo --------------------------------------------------------------------
        printf ${bold}${underline}${green}'Connecting to %s:\t%s'${normal} ${INSTANCES[$instance_number]} ${instance_ip}
        ssh -o StrictHostKeyChecking=no -i U:/.ssh/ksaittis.pem vtw-dev@${instance_ip//[[:space:]]/}
    else
        printf ${bold}${red}'Argument passed not a number: %s' ${instance_number} >&2
        exit 1
    fi
}

display
connect_to

unset INSTANCES
unset IPs