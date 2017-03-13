#!/bin/bash

#### Colours #####
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
CYAN=$(tput setaf 6)
NORMAL=$(tput sgr0)
BOLD=$(tput bold)

#### USERNAMES KEYS ####
PRIMARY_USERNAME=vtw-dev
PRIMARY_PRIVATE_KEY_NAME=ksaittis.pem
DEFAULT_NAME_TAG_NON_PROD=devnp

BACKUP_USERNAME=ec2-user
BACKUP_KEY_NAME=bdang.pem
DEFAULT_NAME_TAG_PROD=prod

#### CLOBAL VARS ####
ACCOUNT_NO=
INSTANCES=()
WARS=()
WAR_VERSIONS=()
####################

#can be used for debugging
# set -x

makeline() #optional arg $1 changes the character used to fill the line
{
    printf "%$(( $(tput cols) ))s" " " | tr " " ${1:-=}
}

centerPrint() #prints the string prvide to the center of terminal
{
    parameters=$*
    string_length=${#parameters}
    pos=$(( ($(tput cols) + string_length ) /2 ))
    printf "%*s\n" $pos "$parameters"
}

describe-instances()  #creates a list of all instances with their ips
{
aws ec2 describe-instances --filters 'Name=tag:Name,Values='"*${NAME_TAG}*" 'Name=instance-state-code,Values=16' --region eu-west-1 --query 'Reservations[].Instances[].[[Tags[?Key==`Name`].Value][0][0],PrivateIpAddress]' --output table
}

convert_lines_to_array() #creates an array out of multiline object
{
    OLD_IFS="$IFS"
    IFS='
    '
    IFS=${IFS:0:1}
    INSTANCES=( ${1} )
    IFS="$OLD_IFS"
}

identify_account() #identifies which account we are pointing to and set correct credentials
{
	ACCOUNT_NO=$(aws sts get-caller-identity --output text --query 'Account')
	echo $ACCOUNT_NO
	if [[  $ACCOUNT_NO =~ ^46[[:digit:]]+ ]]; then
		USERNAME=$PRIMARY_USERNAME
		KEY=$PRIMARY_PRIVATE_KEY_NAME
		ACCOUNT="Non Production"
	else
		USERNAME=$BACKUP_USERNAME
		KEY=$BACKUP_KEY_NAME
		ACCOUNT="Production"
	fi
}

get_array_of_aws_instances() #calls describe-instances to get list of instances and then converts it to an array
{
    SORTED_TABLE=$( describe-instances  | sed '1d; 2d; /vtw-apollo-pdf-asg-devnp/d' | sort -n )
    convert_lines_to_array "${SORTED_TABLE}"
}

display_instances(){ #displays the array of instances
    num_rows=${#INSTANCES[@]}
    if [ $num_rows = 0 ]; then
    	printf ${YELLOW}"Your search did not return any servers: %s\n"${NORMAL} "${NAME_TAG}"
    	read -e -p "Please provide new search term: " NAME_TAG
    	__main__
    	# kill -INT $$
    fi
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

getWARS() #creating a list of the exploded wars on the instance
{
	EXPLODED_WARS=( $(ls -d /usr/share/tomcat[6-9]/webapps/*/ | xargs -n1 basename) )
	for i in ${EXPLODED_WARS[@]}; do
	    echo $i
	done
}

getVersion() #gets the war versions
{
	 WAR_VERSION=$(sudo cat $(sudo find /usr/share/tomcat[7-8]/webapps/"$1"/ -type f -name 'pom.xml') | sed -e '/<parent>/,/<\/parent>/{//!d}' -e '/<dependencies>/,/<\/project>/{//!d}' | grep -m1 '</version>')
        if [[ -z "${WAR_VERSION}"  ]]; then
            WAR_VERSION=$(sudo cat $(sudo find /usr/share/tomcat[7-8]/webapps/"$1"/ -type f -name 'pom.xml') | sed -e '/<dependencies>/,/<\/project>/{//!d}' | grep -m1 '</version>')
        fi
        echo $WAR_VERSION
}

display_wars_versions() #displays the war versions found on that intance
{
	echo
    WARS=( $(ssh -o StrictHostKeyChecking=no -i ~/.ssh/${KEY} ${USERNAME}@${instance_ip//[[:space:]]/} 2> /dev/null "$(typeset -f); getWARS") )
    printf '        WAR VERSION ON INSTANCE %s:\n' ${instance_name^^}
    makeline -
    for i in ${!WARS[@]}; do
        WAR_VERSION=( $(ssh -o StrictHostKeyChecking=no -i ~/.ssh/${KEY} ${USERNAME}@${instance_ip//[[:space:]]/} 2> /dev/null "$(typeset -f); getVersion "${WARS[$i]}" ") )
        WAR_VERSION="${WAR_VERSION#<version>}" #removing the <version> from var
        WAR_VERSION="${WAR_VERSION%<\/version>}"

        printf '        %25s:--->\t%-30s\n' ${WARS[$i]}   ${GREEN}${WAR_VERSION}${NORMAL}
    done
}


check_tomcat_status() #executes tomcats status check through ssh and returns result
{
    TOMCAT_STATUS=$(ssh -o StrictHostKeyChecking=no -i ~/.ssh/${KEY} ${USERNAME}@${instance_ip//[[:space:]]/} 2> /dev/null 'TOMCAT_VERSION=$(ls /etc/init.d | grep tomcat[6-9] ); TOMCAT_STATUS=$(sudo service ${TOMCAT_VERSION} status); echo $TOMCAT_STATUS')

    if [[ ! -z "${TOMCAT_STATUS}" ]]; then
        if [[ "${TOMCAT_STATUS}" == *is?running* ]]; then
            printf '\t\t%s\t: %s\n' $instance_name ${GREEN}"${TOMCAT_STATUS}"${NORMAL}
        elif [[ "${TOMCAT_STATUS}" == *stop* ]] || [[ "${TOMCAT_STATUS}" == *is?not?running* ]]; then
            printf '\t\%s\t: %s\n' $instance_name ${RED}"${TOMCAT_STATUS}"${NORMAL}
        fi
    else
        printf '%s\n' ${YELLOW}"Tomcat is not installed on this instance"${NORMAL}
	fi
}


check_service_status() #executes status check through ssh and returns result
{
    SERVICE_STATUS=$(ssh -o StrictHostKeyChecking=no -i ~/.ssh/${KEY} ${USERNAME}@${instance_ip//[[:space:]]/} 2> /dev/null 'SERVICE_STATUS=$(sudo service '"${sshcommand}"' status); echo $SERVICE_STATUS')
    printf '        %s:\t%s' $instance_name "$SERVICE_STATUS"

}

execute_ssh_command()
{
    COMMAND_RESULT=$(ssh -o StrictHostKeyChecking=no -i ~/.ssh/${KEY} ${USERNAME}@${instance_ip//[[:space:]]/} 2> /dev/null 'RESULT=$('"${sshcommand}"'); echo "$RESULT"')
    if [[ ! -z "${COMMAND_RESULT}" ]]; then
        printf '%s\n' "${COMMAND_RESULT}"
	else
        printf '%s\n' "$COMMAND_RESULT did not returned valid output"
	fi
}


clean_ssh_command()     #Removing double quotes from variable so it can be used as command
{
    sshcommand="${sshcommand%\"}"
    sshcommand="${sshcommand#\"}"
}

display_unsuccessful_login_msg() #display Unsuccessful login message
{
    makeline \#
    centerPrint ${YELLOW}"Unsuccessful login attemp to $instance_name in $ACCOUNT account."
    centerPrint ${BOLD}"USERNAME: ${USERNAME} and KEY: ${KEY} did not work."${NORMAL}
    makeline -
    centerPrint ${CYAN}"POSSIBLE SCENARIOS"
    centerPrint "Security groups on $instance_name do not allow access to your ip."
    centerPrint "Key used is not in the .ssh/authorisedKeys on the specific instance."
    centerPrint "You are trying to connect to a windows box."${NORMAL}
    makeline \#
}

check_ssh_command() #checking number of words passed as a second argument
{
	if [[ $(echo "$sshcommand" | wc -w ) -gt 1 ]]; then #if we typed multiple words
        execute_ssh_command
    #Only one word in sshcommand
    elif [[ "$sshcommand" = war-version ]]; then #if we typed war version
        display_wars_versions
    elif [[ $sshcommand = "tomcat" ]]; then #if we type tomcat
        check_tomcat_status
    else #if not try to find out the status of the service
        check_service_status
    fi
}


identify_arguments_passed() #identifies and handles the arguments passed to the script
{ #parameters must not be passed in the correct order
    if [[ $# -eq 2 ]]; then #check number of positional parameters passed
        i=1
        for arg in $@; do
            if [[ $arg =~ ^-[p|np] ]]; then #identify which positional parameter is related to account
                account_arg=$arg
                if [[ $i == 1 ]]; then #identify which positional parameter is related to NAME_TAG
                    NAME_TAG=$2
                else
                    NAME_TAG=$1
                fi
                if [[ $account_arg == -p ]]; then
                    . change-aws.sh prod
                else
                    . change-aws.sh nonprod
                fi
                get_array_of_aws_instances
            fi
            ((i++))
        done
    elif [[ $# -eq 1 ]]; then #if one argument was passed
        if [[ $1 =~ ^-[p|np] ]]; then #identify if the positional parameter is related to account
            # source ./change-aws.sh
            account_arg=$1
            if [[ $account_arg == -p ]]; then
                . change-aws.sh prod
                NAME_TAG=$DEFAULT_NAME_TAG_PROD
            else
                . change-aws.sh nonprod
                NAME_TAG=$DEFAULT_NAME_TAG_NON_PROD
            fi
            get_array_of_aws_instances
        elif [[ $1 =~ ^--help ]]; then #displaying help if arg is --help
            display_help_msg
        else #if only one argument passed and it's not -p or -np then it should be a name_tag
            NAME_TAG="${1}"
            get_array_of_aws_instances
        fi
    elif [[ $# -eq 0 ]]; then
        if [[ $ACCOUNT == "Non Production" ]]; then
            NAME_TAG=$DEFAULT_NAME_TAG_NON_PROD
        else
            NAME_TAG=$DEFAULT_NAME_TAG_PROD
        fi
        get_array_of_aws_instances
    else
        echo
        centerPrint ${YELLOW}"You can provide up to 2 arguments (optional)."
        centerPrint "One for name tag and one for account type."${NORMAL}
        kill -INT $$
    fi
}

connect_to()
{
    identify_account
    read -e -p "        Connect to instance: " instance_number sshcommand
    re='^[0-9]+$' #regex for numbers
    if [[ "$instance_number" =~ $re && "$instance_number" -le $((${#INSTANCES[@]} -3 )) ]]; then
        instance_name=$( echo ${INSTANCES[$((instance_number))]} | awk -F'|' '{print $2}')
        instance_ip=$( echo ${INSTANCES[$((instance_number))]} | awk -F'|' '{print $3}')

        if [[ -z ${sshcommand} ]]; then
            printf "\t\tConnecting to %s\t %s..." ${instance_name//[[:space:]]/} ${instance_ip//[[:space:]]/}
            ssh -o StrictHostKeyChecking=no -o ConnectTimeout=3 -i ~/.ssh/${KEY} ${USERNAME}@${instance_ip//[[:space:]]/}
            if [ $? = 255 ]; then
                display_unsuccessful_login_msg #if permission is denied
            fi
            kill -INT $$
        else
        	clean_ssh_command
            check_ssh_command
        fi
    else
        printf '        Incorrect or out of range argument: %s\n' ${instance_number} >&2
        connect_to
    fi
}

display_help_msg()
{
    cat << EOF
    Usage:  qssh [NAME_TAG] [ACCOUNT]
       or:  qssh [ACCOUNT] [NAME_TAG]
       or:  qssh [NAME_TAG]
       or:  qssh [HELP]
    Prints a list of servers that match the *NAME_TAG* you provided and allows
    easy access to them. You can specify the account in which the search is
    going to be by providing the argument -p for production account and
    -np for non production account. If you don\'t provide an account arg then it
    makes the search on the account that your default credentials in your .aws dir
    are pointing to.

    The options below may be used to select which server name tag to search for
    and in which account to search for.
    [NAME_TAG]
      NAME_TAG, server name tag to search for
    [ACCOUNT]
      -p, production account
      -np, non production
    [HELP]
      --help, display this help and exit
    EOF

kill -INT $$
}

main()
{
    identify_arguments_passed $@
    display_instances
    connect_to
}

main $@
