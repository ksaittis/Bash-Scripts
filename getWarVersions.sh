#!/bin/bash
NAME_TAG=${1:-devnp}
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
NORMAL=$(tput sgr0)
USERNAME_EC2=vtw-dev
PEM_KEY_NAME=${USERNAME}
INSTANCES=()
WARS=()
WAR_VERSIONS=()

describe-instances()
{
aws ec2 describe-instances --filters 'Name=tag:Name,Values='"*${NAME_TAG}*" 'Name=instance-state-code,Values=16' --region eu-west-1 --query 'Reservations[].Instances[].[[Tags[?Key==`Name`].Value][0][0],PrivateIpAddress]' --output table
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
    SORTED_TABLE=$( describe-instances  | sed '1d; 2d; /vtw-apollo-pdf-asg-devnp/d' | sort -n )
    convert_lines_to_array "${SORTED_TABLE}"
}

display_instances(){
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

getWARS()
{
	EXPLODED_WARS=( $(ls -d /usr/share/tomcat[6-9]/webapps/*/ | xargs -n1 basename) )
	for i in ${EXPLODED_WARS[@]}; do
	    echo $i
	done
}


getVersion()
{
    WAR_VERSION=$(sudo cat $(sudo find /usr/share/tomcat[7-8]/webapps/"$1"/ -type f -name 'pom.xml') | sed -e '/<parent>/,/<\/parent>/{//!d}' -e '/<dependencies>/,/<\/project>/{//!d}' | grep -m1 '</version>')
        if [[ -z "${WAR_VERSION}"  ]]; then
            WAR_VERSION=$(sudo cat $(sudo find /usr/share/tomcat[7-8]/webapps/"$1"/ -type f -name 'pom.xml') | sed -e '/<dependencies>/,/<\/project>/{//!d}' | grep -m1 '</version>')
        fi
        echo $WAR_VERSION
}

makeline()
{
    COLUMNS=$(tput cols)
    printf "%${COLUMNS}s"  " " | tr " " ${1:-#}
}

display_wars_versions()
{
	echo
    #UAT doesnt have snapshot inside the version

    WARS=( $(ssh -o StrictHostKeyChecking=no -o ConnectTimeout=3 -i $HOME/.ssh/${PEM_KEY_NAME}.pem ${USERNAME_EC2}@${instance_ip//[[:space:]]/} 2> /dev/null "$(typeset -f); getWARS") )
    if [ ${#WARS[@]} -ne 0 ]; then
        echo
        echo
        makeline -
        printf '        WAR VERSION ON INSTANCE %s:\n' ${instance_name}
        makeline =
        for index in ${!WARS[@]}; do
            echo timeoutdd
            WAR_VERSION=( $(ssh -o StrictHostKeyChecking=no -o ConnectTimeout=3 -i $HOME/.ssh/${PEM_KEY_NAME}.pem ${USERNAME_EC2}@${instance_ip//[[:space:]]/} 2> /dev/null "$(typeset -f); getVersion "${WARS[$index]}" ") )
            WAR_VERSION="${WAR_VERSION#<version>}" #removing the <version> from var
            WAR_VERSION="${WAR_VERSION%<\/version>}"

            printf '        %20s:---->\t%-20s\n' ${WARS[$index]}   ${WAR_VERSION}
        done
        makeline =
    else
        echo No wars were found on ${instance_name}
    fi
}

iterate_EC2()
{
    num_rows=${#INSTANCES[@]}
    printf "     %2s\n" "$table_line"
    for ((i = 0; i <= $((num_rows-3)); i++)); do
        instance_name=$( echo ${INSTANCES[$i]} | awk -F'|' '{print $2}')
        instance_ip=$( echo ${INSTANCES[$i]} | awk -F'|' '{print $3}')

        display_wars_versions
    done
}


execute()
{
    get_array_of_aws_instances
    iterate_EC2
}

execute
