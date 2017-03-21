#!/bin/bash

readarray INSTANCES < ./describe-instances2.txt

display_array()
{
    for i in ${!INSTANCES[@]}; do
        echo -n Index: $i '->' "${INSTANCES[$i]}"
    done
}

getSpecificIp()
{
    echo ${INSTANCES[$1]} | awk -F'|' '{print $3}'
}


restartTomcatSSH()
{
    TOMCAT_VERSION=$(ls /etc/init.d | grep tomcat[6-9] )
    if [[ -n $TOMCAT_VERSION ]]; then
        TOMCAT_STOP=$(sudo service ${TOMCAT_VERSION} stop)
        TOMCAT_START=$(sudo service ${TOMCAT_VERSION} start)
        TOMCAT_STATUS=$(sudo service ${TOMCAT_VERSION} status)
        echo $TOMCAT_STATUS
    else
        echo "Tomcat is not installed on this box"
    fi
}

restartBox()
{
    TOMCAT_STATUS=$(ssh -o StrictHostKeyChecking=no -i ~/.ssh/${KEY} ${USERNAME}@${instance_ip//[[:space:]]/} 2> /dev/null "$(typeset -f); restartTomcatSSH")
    echo $instance_ip '->' $TOMCAT_STATUS
}

# test=$(ssh -o StrictHostKeyChecking=no -i ~/.ssh/ksaittis.pem ec2-user@34.252.103.143 2> /dev/null "$(typeset -f); restartTomcatSSH")
echo $test



loop_arguments()
{
    j=0
    for i in $@; do
        instance_ip=$(getSpecificIp $i)
        echo Arg $j: $instance_ip
        ((j++))
    done
}

# display_array
loop_arguments $@
