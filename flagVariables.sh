#!/bin/bash
# set -x

fun()
{
    if [[ $# -le 2 && $# -ge 1 ]]; then #check number of positional parameters passed
        i=0
        for arg in $@; do
            if [[ $arg =~ ^- ]]; then #identify at which position is the positional parameter related to account
            eval account_option='$'$((i+1))
                if [[ $account_option == -p ]]; then
                    echo position: $account_option $((i+1))
                else
                    echo position: $account_option $((i+1))
                fi
            fi
        ((i++))
        done
    else
        echo "Please provide less than three arguments. One for name_tag and one for account to search in (optional)."
    fi
}


identify_arguments_passed() #unreadable code
{
    if [[ $# -eq 2 ]]; then #check number of positional parameters passed
        NAME_TAG="$1"
        # source ./change-aws.sh
        if [[ $NAME_TAG =~ ^- ]]; then
            printf ${YELLOW}"Incorrect sequence of arguments.\n"${NORMAL}
            # display_help_msg
        fi
        if [[ $2 == -p ]]; then
            # /bin/bash change-aws prod
            echo Production
            echo $NAME_TAG
        else
            # /bin/bash change-aws nonprod
            echo NONPROD
            echo $NAME_TAG
        fi
        echo getting instances
        # get_array_of_aws_instances
    elif [[ $# -eq 1 ]]; then #if one argument was passed
        if [[ $1 =~ ^-[p|np] ]]; then #identify if the positional parameter is related to account
            # source ./change-aws.sh
            if [[ $1 == -p ]]; then
                NAME_TAG=prod #providing default values for search
                # /bin/bash change-aws prod
                echo $NAME_TAG
            else
                NAME_TAG=devnp  #providing default values for search
                # /bin/bash change-aws nonprod
                echo $NAME_TAG
            fi
            echo Gettiing instances

            # get_array_of_aws_instances
        elif [[ $1 =~ ^--help ]]; then
            # display_help_msg
            echo helpppppppppp
        else
            NAME_TAG="${1}"
            echo $NAME_TAG
            echo Gettiing instances
            # get_array_of_aws_instances
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




main()
{
    # fun $@
    identify_arguments_passed $@
}

main $@
