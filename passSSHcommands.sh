#!/bin/bash
NAME_TAG=${1:-devnp}
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
NORMAL=$(tput sgr0)
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
    # SORTED_TABLE=$(aws ec2 describe-instances --filters 'Name=tag:Name,Values='"*${ACCOUNT}*" 'Name=instance-state-code,Values=16' --region eu-west-1 --query 'Reservations[].Instances[].[[Tags[?Key==`Name`].Value][0][0],PrivateIpAddress]' --output table  | sed '1d; 2d; /vtw-apollo-pdf-asg-devnp/d' | sort -n )
    SORTED_TABLE=$( cat instances.txt | sed ' 1d; 2d; /vtw-apollo-pdf-asg-devnp/d' | sort -f -k1 )
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
WAR_VERSION=$(cat $(find /usr/share/tomcat7/webapps/"$1"/ -type f -name 'pom.xml') |  grep -m1 'SNAPSHOT<version>')
# WAR_VERSION=$(cat $(ls /usr/share/tomcat7/webapps/${1//[[:space:]]/}/*.xml ) |  grep -m1 'SNAPSHOT<version>')
echo $WAR_VERSION
}

display_wars_versions()
{
    WARS=( $(ssh -o StrictHostKeyChecking=no -i $HOME/.ssh/ksaittis.pem ec2-user@${IP} 2> /dev/null "$(typeset -f); getWARS") )
    printf 'WAR VERSION ON INSTANCE %s:\n' ${instance_name}
    for i in ${!WARS[@]}; do
        WAR_VERSION=( $(ssh -o StrictHostKeyChecking=no -i $HOME/.ssh/ksaittis.pem ec2-user@${IP} 2> /dev/null "$(typeset -f); getVersion "${WARS[$i]}" ") )
        echo ${WARS[$i]} ${WAR_VERSION}
    done
}


check_tomcat_status()
{
    TOMCAT_STATUS=$(ssh -o StrictHostKeyChecking=no -i $HOME/.ssh/ksaittis.pem ec2-user@${IP} 2> /dev/null 'TOMCAT_VERSION=$(ls /etc/init.d | grep tomcat[6-9] ); TOMCAT_STATUS=$(sudo service ${TOMCAT_VERSION} status); echo $TOMCAT_STATUS')
    # TOMCAT_STATUS=$(ssh -o StrictHostKeyChecking=no -i $HOME/.ssh/ksaittis.pem vtw-dev@${IP} 2> /dev/null 'STATUS=$(sudo service ${sshcommand} status); echo $STATUS')
    # printf '%s' "${INSTANCES[$i]}"

    if [[ ! -z "${TOMCAT_STATUS}" ]]; then
        if [[ "${TOMCAT_STATUS}" == *is?running* ]]; then
            printf '%s\t: %s\n' ${INSTANCES[$i]} ${GREEN}"${TOMCAT_STATUS}"${NORMAL}
        elif [[ "${TOMCAT_STATUS}" == *stop* ]] || [[ "${TOMCAT_STATUS}" == *is?not?running* ]]; then
            printf '%s\t: %s\n' ${INSTANCES[$i]} ${RED}"${TOMCAT_STATUS}"${NORMAL}
        fi
    else
        printf '%s\n' ${YELLOW}"Tomcat is not installed on this instance"${NORMAL}
	fi
}


check_service_status()
{
    echo $sshcommand
    SERVICE_STATUS=$(ssh -o StrictHostKeyChecking=no -i $HOME/.ssh/ksaittis.pem ec2-user@${IP} 2> /dev/null 'SERVICE_STATUS=$(sudo service '"${sshcommand}"' status); echo $SERVICE_STATUS')
    # SERVICE_STATUS=$(ssh -o StrictHostKeyChecking=no -i $HOME/.ssh/ksaittis.pem vtw-dev@${IP} 2> /dev/null 'STATUS=$(sudo service ${sshcommand} status); echo $STATUS')
    printf '%s' "${INSTANCES[$i]}"

    if [[ ! -z "${SERVICE_STATUS}" ]]; then
        printf '%s\n' "$SERVICE_STATUS"
	else
        printf '%s\n' "$sshcommand is not installed on this instance"
	fi
}

execute_ssh_command()
{
    COMMAND_RESULT=$(ssh -o StrictHostKeyChecking=no -i $HOME/.ssh/ksaittis.pem ec2-user@${IP} 2> /dev/null 'RESULT=$('"${sshcommand}"'); echo "$RESULT"')
    if [[ ! -z "${COMMAND_RESULT}" ]]; then
        printf '%s\n' "${COMMAND_RESULT}"
	else
        printf '%s\n' "$COMMAND_RESULT did not returned valid output"
	fi
}

connect_to()
{
    read -e -p "        Connect to instance: " instance_number sshcommand
    IP="34.250.228.182"
    re='^[0-9]+$' #regex for numbers
    if [[ "$instance_number" =~ $re && "$instance_number" -le $((${#INSTANCES[@]} -3 )) ]] ; then
        instance_name=$( echo ${INSTANCES[$((instance_number))]} | awk -F'|' '{print $2}')
        instance_ip=$( echo ${INSTANCES[$((instance_number))]} | awk -F'|' '{print $3}')
        if [[ -z ${sshcommand} ]]; then
            echo $instance_name
            echo $instance_ip
            printf "Connecting to %s %s..." ${instance_name//[[:space:]]/} ${instance_ip//[[:space:]]/}
            # ssh -o StrictHostKeyChecking=no -i ${HOME}/.ssh/${USERNAME}.pem vtw-dev@${instance_ip//[[:space:]]/}

        else #checking number of words passed as a second argument

            #Removing double quotes from variable so it can be used as command
            sshcommand="${sshcommand%\"}"
            sshcommand="${sshcommand#\"}"

            if [[ "$sshcommand" = "war version" ]]; then #if we typed war version
            echo typed war version
                display_wars_versions
            elif [[ $(echo "$sshcommand" | wc -w ) -gt 1 ]]; then
                execute_ssh_command
            else #Only one word in sshcommand
                #first check if the word is tomcat
                if [[ $sshcommand = "tomcat" ]]; then
                    check_tomcat_status
                else #if not try to find out the status of the service
                    check_service_status
                fi

            fi
        fi

    else
        printf '        Invalid argument: %s\n' ${instance_number} >&2
    fi
}

execute()
{
    get_array_of_aws_instances
    display_instances
    connect_to
}

execute
