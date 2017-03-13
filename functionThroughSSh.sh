#!/bin/bash
# set -x
WARS=()
WAR_VERSIONS=()

IP="34.250.228.182"

getWARS()
{
# EXPLODED_WARS=( $(find -maxdepth 2 -path  '*/webapps/*' -type d | xargs -n1  basename) )
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


WARS=( $(ssh -o StrictHostKeyChecking=no -i $HOME/.ssh/ksaittis.pem ec2-user@${IP} 2> /dev/null "$(typeset -f); getWARS") )
# echo ${!WARS[@]};
for i in ${!WARS[@]}; do
    WAR_VERSION=( $(ssh -o StrictHostKeyChecking=no -i $HOME/.ssh/ksaittis.pem ec2-user@${IP} 2> /dev/null "$(typeset -f); getVersion "${WARS[$i]}" ") )
    # WAR_VERSION=$( getVersion "${WARS[$i]}" )
    echo $i ${WARS[$i]} ${WAR_VERSION}
done
# echo "$SERVICE_STATUS"
