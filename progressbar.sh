#!/bin/bash


function create_success_bar(){
	tput setaf 2;
	echo -n "["
	for (( c=1; c<=50; c++ )); do  
		tput setaf 2;
		 print_equal
	done
	for (( c=50; c<=100; c++ )); do  
		print_space
	done
	echo -n "]"
}

function print_equal(){
	echo -n "="
}

function print_space(){
	echo -n " "
}



function number_of_dirs()
{ 
	number_of_dirs=`ls | grep / | wc -l`
	echo "$number_of_dirs"
}

create_success_bar