#!/bin/bash
ACCOUNT=${1:-devnp}
INSTANCES=()
TOMCAT_STATUS_ARRAY=()

TOMCAT_STATUS_ARRAY=( "Tomcat is not installed on this instance1" "Tomcat is not installed on this instance2" "Tomcat is not installed on this instance" "Tomcat is not installed on this instance" "Tomcat is not installed on this instance" "Tomcat is not installed on this instance" "Tomcat is not installed on this instance" "Tomcat is not installed on this instance" "Tomcat is not installed on this instance" "Tomcat is not installed on this instance" "Tomcat is not installed on this instance" "Tomcat is not installed on this instance" "Tomcat is not installed on this instance" "Tomcat is not installed on this instance" "Tomcat is not installed on this instance20" )

describe-instances()
{
aws ec2 describe-instances --filters 'Name=tag:Name,Values='"*${ACCOUNT}*" 'Name=instance-state-code,Values=16' --region eu-west-1 --query 'Reservations[].Instances[].[[Tags[?Key==`Name`].Value][0][0],PrivateIpAddress]' --output table
}

check_tomcat_status_v2()
{
	TOMCAT_STATUS=$(ssh -o StrictHostKeyChecking=no -i U:/.ssh/ksaittis.pem vtw-dev@${1} 2> /dev/null 'TOMCAT_VERSION=$(ls /etc/init.d | grep tomcat[6-9] ); TOMCAT_STATUS=$(sudo service ${TOMCAT_VERSION} status); echo $TOMCAT_STATUS')
	if [[ ! -z "${TOMCAT_STATUS}" ]]; then
		TOMCAT_STATUS_ARRAY+=( "${TOMCAT_STATUS}" )
	else
		TOMCAT_STATUS_ARRAY+=( "Tomcat is not installed on this instance" )
	fi
}

create_tomcat_status_array()
{
    num_rows=${#INSTANCES[@]}
    for ((i = 0; i <= $((num_rows-3)); i++)); do
        ip=$(echo "${INSTANCES[$i]}" | awk -F'|' '{print $3}')
		check_tomcat_status_v2 "${ip//[[:space:]]/}"
	done
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
    printf "%2s\n" "$table_line"
    for ((i = 0; i <= $((num_rows-3)); i++)); do
        if ! (( $i % 2 ))  ; then
            printf '%s' "${INSTANCES[$i]}"
            printf '  %s\n' "${TOMCAT_STATUS_ARRAY[$i]}"
        else
            printf '%s' "${INSTANCES[$i]}"
            printf '  %s\n' "${TOMCAT_STATUS_ARRAY[$i]}"
        fi
    done
    printf "%2s\n" $table_line

}


execute()
{
    get_array_of_aws_instances
    # create_tomcat_status_array
    display
}
execute
