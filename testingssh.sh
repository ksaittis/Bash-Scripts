#!/bin/bash
# set -x
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
normal=$(tput sgr0)
#
# IP="34.250.201.197"
# TOMCAT_STATUS_ARRAY=()
#
# TOMCAT_VERSION=$(ssh -o StrictHostKeyChecking=no -i C:/Users/kwnstantinos/.ssh/MyFirstEC2keyPair.pem ec2-user@${IP} 2> /dev/null "sh -c 'cd /etc/init.d; ls | awk '/tomcat[6-9]/ {print $9}'; exit' ")
# #[[ ! -z "$var" ]] && echo "Not empty" || echo "Empty"
#
# if [[ ! -z ${TOMCAT_VERSION} ]]; then
#     TOMCAT_STATUS=$(ssh -o StrictHostKeyChecking=no -i C:/Users/kwnstantinos/.ssh/MyFirstEC2keyPair.pem ec2-user@${IP} 2> /dev/null "sh -c 'sudo service $TOMCAT_VERSION status; exit' ")
# else
#     TOMCAT_STATUS="Tomcat Not Installed on this box"
# fi
#
# echo $TOMCAT_STATUS
# TOMCAT_STATUS_ARRAY+=( "${TOMCAT_STATUS}" )
#
#
# echo TOMCAT_VERSION= $TOMCAT_VERSION
# echo ${TOMCAT_STATUS_ARRAY[0]}

TOMCAT_STATUS_ARRAY=( "tomcat is stopped" "tomcat8 (pid 24089) is running...  " "Tomcat is not installed on this instance" )
INSTANCES_NAMES=( "10.183.210.1" "10.183.210.1" "10.183.210.1" )

display_information()
{
	i=0
	for status in ${TOMCAT_STATUS_ARRAY[@]}; do
		if [[ "${status}" == *running* ]]; then
			printf 'EC2: %s\tSTATUS: %s' "${INSTANCES_NAMES[$i]}" ${green}"${status}"${normal}
		elif [[ "${status}" == *stop* ]]; then
			printf 'EC2: %s\tSTATUS: %s' "${INSTANCES_NAMES[$i]}" ${red}"${status}"${normal}
		else
			printf 'EC2: %s\tSTATUS: %s' "${INSTANCES_NAMES[$i]}" ${yellow}"${status}"${normal}
		fi
		((i++))
	done
}

display_information2()
{
	j=0
	for (( i = 0; i < ${#TOMCAT_STATUS_ARRAY[@]}; i++ )); do
		if [[ "${TOMCAT_STATUS_ARRAY[$i]}" == *running* ]]; then
			printf 'Instance: %s\tSTATUS: %s\n' "${INSTANCES_NAMES[$j]}" ${green}"${TOMCAT_STATUS_ARRAY[$i]}"${normal}
		elif [[ "${TOMCAT_STATUS_ARRAY[$i]}" == *stop* ]]; then
			printf 'Instance: %s\tSTATUS: %s\n' "${INSTANCES_NAMES[$j]}" ${red}"${TOMCAT_STATUS_ARRAY[$i]}"${normal}
		else
			printf 'Instance: %s\tSTATUS: %s\n' "${INSTANCES_NAMES[$j]}" ${yellow}"${TOMCAT_STATUS_ARRAY[$i]}"${normal}
		fi
		((j++))
	done
}


display_information2
