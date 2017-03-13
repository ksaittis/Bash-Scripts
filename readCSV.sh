#!/bin/bash

OLDIFS=$IFS
IFS=","

while read user job uid location

do
	echo -e "\e[1;33m$user \
	=======================\e[0m\n\
	Role : \t\t $job\n\
	ID : \t\t $uid\n\
	Location : \t $location\n"
done < $1

IFS=$OLDIFS