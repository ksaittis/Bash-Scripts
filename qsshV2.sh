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

create_arrays()
{
	describe-instances | sed '/DescribeInstances/d; /--/d; /vtw-apollo-pdf-asg-devnp/d' | sort -n > describe-instances.txt

	awk -F'|' '{print $2}' describe-instances.txt > instances
	readarray INSTANCES < instances
	awk -F'|' '{print $3}' describe-instances.txt > ips
	readarray IPs <  ips
}

create_arrays_v2()
{
	describe-instances | sed '/DescribeInstances/d; /--/d; /vtw-apollo-pdf-asg-devnp/d' | sort -n > describe-instances.txt

	INSTANCES=( `awk -F'|' '{print $2}' describe-instances.txt` )
	IPs=( `awk -F'|' '{print $3}' describe-instances.txt` )
	remove_files_v2
}

display()
{
	echo
	number_elements=$(( ${#INSTANCES[@]} - 1 ))
	printf '   %s\t\t\t\t\t%s\n' INSTANCE IP
	echo --------------------------------------------------------------
for i in $(seq 0 $number_elements); do
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
		# echo here${instance_ip//[[:space:]]/}here
        echo --------------------------------------------------------------------
		clear
		printf ${bold}${underline}${green}'Connecting to %s:\t%s'${normal} ${INSTANCES[$instance_number]} ${instance_ip}
        ssh -o StrictHostKeyChecking=no -i U:/.ssh/ksaittis.pem vtw-dev@${instance_ip//[[:space:]]/}
    else
        printf ${bold}${red}'Argument passed not a number: %s' ${instance_number} >&2
        exit 1
    fi
}

remove_files()
{
	rm describe-instances.txt
	rm instances
	rm ips
}

remove_files_v2()
{
	rm describe-instances.txt
}

execute_script()
{
create_arrays_v2
display
connect_to
}

execute_script

unset INSTANCES
unset IPs
