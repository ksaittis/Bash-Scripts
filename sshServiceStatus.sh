#!/bin/bash
ACCOUNT=${1:-devnp}
TOMCAT_STATUS_ARRAY=()
red=$(tput setaf 1)
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

	INSTANCES=( `awk -F'|' '{print $2}' describe-instances.txt` )
	IPs=( `awk -F'|' '{print $3}' describe-instances.txt` )
}

display2()
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


check_tomcat_status()
{
if [ -z "$1" ]; then
	echo "No IP was provided"
fi
TOMCAT_VERSION=$(ssh -o StrictHostKeyChecking=no -i U:/.ssh/ksaittis.pem vtw-dev@${1} 2> /dev/null "sh -c 'cd /etc/init.d; ls | awk '/tomcat[6-9]/ {print $9}'; exit' ")
if [[ ! -z ${TOMCAT_VERSION} ]]; then
	TOMCAT_STATUS=$(ssh -o StrictHostKeyChecking=no -i U:/.ssh/ksaittis.pem vtw-dev@${1} 2> /dev/null "sh -c 'sudo service ${TOMCAT_VERSION} status; exit' ")
else
	TOMCAT_STATUS="Tomcat is not installed on this instance"
fi
TOMCAT_STATUS_ARRAY+=( "${TOMCAT_STATUS}" )
}

check_tomcat_status_v2()
{
	TOMCAT_STATUS=$(ssh -o StrictHostKeyChecking=no -i U:/.ssh/ksaittis.pem vtw-dev@${1} 2> /dev/null 'TOMCAT_VERSION=$(ls /etc/init.d | grep tomcat ); TOMCAT_STATUS=$(sudo service ${TOMCAT_VERSION} status); echo $TOMCAT_STATUS')
	echo $TOMCAT_STATUS
	if [[ ! -z ${TOMCAT_STATUS} ]]; then
		TOMCAT_STATUS_ARRAY+=( "${TOMCAT_STATUS}" )
	else
		TOMCAT_STATUS_ARRAY+=( "Tomcat is not installed on this instance" )
	fi
}


create_tomcat_status_array()
{
	for ip in ${IPs[@]}; do
		check_tomcat_status_v2 "$ip"
	done
}

display()
{
	printf '   %s\t\t\t\t%s\n' INSTANCE STATUS
	echo --------------------------------------------------------------
	for (( i = 0; i < ${#TOMCAT_STATUS_ARRAY[@]}; i++ )); do
		empty_space=`echo ${INSTANCES[$i]} | wc -c`
		empty_space=$(( empty_space ))

		if [[ "${TOMCAT_STATUS_ARRAY[$i]}" == *running* ]]; then
			printf '%s\t: %*s\n' ${INSTANCES[$i]} $empty_space ${green}"${TOMCAT_STATUS_ARRAY[$i]}"${normal}
		elif [[ "${TOMCAT_STATUS_ARRAY[$i]}" == *stop* ]]; then
			printf '%s\t: %*s\n' ${INSTANCES[$i]} $empty_space ${red}"${TOMCAT_STATUS_ARRAY[$i]}"${normal}
		else
			printf '%s\t: %*s\n' ${INSTANCES[$i]} $empty_space ${yellow}"${TOMCAT_STATUS_ARRAY[$i]}"${normal}
		fi
	done
}

create_arrays
create_tomcat_status_array
display






# for (( i = 0; i < ${#TOMCAT_STATUS_ARRAY[@]}; i++ )); do
# 	printf '%s \t %s' $i ${TOMCAT_STATUS_ARRAY[$i]}
# done
