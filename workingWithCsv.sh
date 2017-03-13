#!/bin/bash

#user,job,uid,location

function identifyColumns() {
	IFS=,
	while read line; do
  	# split into an array
  	field=( $line )
		for word in "${field[@]}" 
			do echo "$word"
		done
  	done
  	}

function fixme(){
	while read user job uid location
	do
		echo -e "\e[1;33m$user \
		=======================\e[0m\n\
		Role : \t\t $job\n\
		ID : \t\t $uid\n\
		Location : \t $location\n"
	done < $1
}

identifyColumns < $1
declare -a field