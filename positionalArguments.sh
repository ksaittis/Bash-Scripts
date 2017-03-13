#!/bin/bash
# set -x
identify_arguments_passed() #unreadable code
{ #parameters must not be passed in the correct order
    if [[ $# -eq 2 ]]; then #check number of positional parameters passed
        i=0
        for arg in $@; do
            if [[ $arg =~ ^- ]]; then #identify at which position is the positional parameter related to account
                # source ./change-aws.sh
                eval account_option='$'$((i+1))
                echo $account_option
                if [[ $((i+1)) == 1 ]]; then
                    NAME_TAG=$2
                    echo tag: $NAME_TAG
                else
                    NAME_TAG=$1
                    echo tag: $NAME_TAG
                fi
                if [[ $account_option == -p ]]; then
                    # /bin/bash change-aws prod
                    echo account: PROD
                else
                    # /bin/bash change-aws nonprod
                    echo account: NONPROD
                fi
                echo Getting Instacnes
                # get_array_of_aws_instances
            fi
            ((i++))
        done
    fi
}
identify_arguments_passed_stable_version() #unreadable code
{ #parameters must be passed in the correct order
    if [[ $# -eq 2 ]]; then #check number of positional parameters passed
        NAME_TAG="$1"
        source ./change-aws.sh
        if [[ $2 == -p ]]; then
            /bin/bash change-aws prod
        else
            /bin/bash change-aws nonprod
        fi
        get_array_of_aws_instances
    elif [[ $# -eq 1 ]]; then #if one argument was passed
        if [[ $1 =~ ^-[p|np] ]]; then #identify if the positional parameter is related to account
            source ./change-aws.sh
            if [[ $1 == -p ]]; then
                NAME_TAG=prod #providing default values for search
                /bin/bash change-aws prod
            else
                NAME_TAG=devnp  #providing default values for search
                /bin/bash change-aws nonprod
            fi
            get_array_of_aws_instances
        elif [[ $1 =~ ^--help ]]; then
            display_help_msg
        else
            NAME_TAG="${1}"
            get_array_of_aws_instances
        fi
    elif [[ $# -eq 0 ]]; then
        identify_account
        if [[ $ACCOUNT == "Non Production" ]]; then
            NAME_TAG=devnp
        else
            NAME_TAG=prod
        fi
        get_array_of_aws_instances
    else
        echo
        centerPrint ${YELLOW}"You can provide up to 2 arguments (optional)."
        centerPrint "One for name tag and one for account type."${NORMAL}
        kill -INT $$
    fi
}


identify_arguments_passed $@
