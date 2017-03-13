#!/bin/bash

ssh_function()
{
	TOMCAT_VERSION=$(ls /etc/init.d | grep tomcat )
	if [[ -n "${TOMCAT_VERSION}" ]]; then
		TOMCAT_STATUS=$(sudo service ${TOMCAT_VERSION} status)
	else
		TOMCAT_STATUS="Tomcat is not installed on this instance"
	fi
	exit
}

create_arrays_v2()
{
	# TOMCAT_STATUS=$(typeset -f | ssh -o StrictHostKeyChecking=no -i C:/Users/kwnstantinos/.ssh/ksaittis.pem ec2-user@${1} 2> /dev/null '$(cat);ssh_function')
	# TOMCAT_STATUS=$(ssh -o StrictHostKeyChecking=no -i C:/Users/kwnstantinos/.ssh/ksaittis.pem ec2-user@${1} 2> /dev/null "sh -c 'TOMCAT_VERSION=$(ls /etc/init.d | awk '/tomcat[6-9]/ {print $1}'); echo $TOMCAT_VERSION' ")
	TOMCAT_STATUS=$(ssh -o StrictHostKeyChecking=no -i C:/Users/kwnstantinos/.ssh/ksaittis.pem ec2-user@${1} 2> /dev/null 'TOMCAT_VERSION=$(ls /etc/init.d | grep tomcat ); TOMCAT_STATUS=$(sudo service ${TOMCAT_VERSION} status); echo $TOMCAT_STATUS')
	echo $TOMCAT_STATUS
	if [[ ! -z ${TOMCAT_STATUS} ]]; then
		TOMCAT_STATUS_ARRAY+=( "${TOMCAT_STATUS}" )
	else
		TOMCAT_STATUS_ARRAY+=( "Tomcat is not installed on this instance" )
	fi
}

create_arrays_v2 "34.250.202.204"
for (( i = 0; i < ${#TOMCAT_STATUS_ARRAY[@]}; i++ )); do
	echo "${TOMCAT_STATUS_ARRAY[$i]}"
done


connect()
{
	ssh -o StrictHostKeyChecking=no -i C:/Users/kwnstantinos/.ssh/ksaittis.pem ec2-user@${1}
}

# connect 34.250.202.204
# TOMCAT_STATUS_ARRAY=( "tomcat is running" "tomcat stopped" "TOMCAT Not Installed" "tomcat is running" "tomcat stopped" "TOMCAT Not Installed" "tomcat is running" "tomcat stopped" "TOMCAT Not Installed" )
