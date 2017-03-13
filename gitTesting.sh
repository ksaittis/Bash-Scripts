#!/bin/bash


function create_success_bar(){
	i=0
	echo -n [
	while [ $i -lt 10 ]; do
		echo -n =
		$(( i++ ))
	done
	echo -n "]"
}

create_success_bar