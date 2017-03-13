#!/bin/bash
array=( "accounts" )
credentials_location="C:/Users/$USERNAME/.aws"
credentials_filename=credentials2

green="\e[32m"
cyan="\e[36m"
normal="\e[0m"

function replaceAWScredentials {
	cd $credentials_location
	aws_access_key_id=$(grep -w -A 1 $1 $credentials_filename | tail -n1 | sed 's/[A-z]\+ = //')
	aws_secret_access_key=$(grep -w -A 2 $1 $credentials_filename | tail -n1 | sed 's/[A-z]\+ = //')
	sed -i '2s/= .*/= '$aws_access_key_id'/' $credentials_filename
	sed -i '3s/= .*/= '$aws_secret_access_key'/' $credentials_filename
}

function show_date() {
	echo
	a=$(date +"%d-%m-%Y %H:%M:%S")
	echo -e $green$a$normal
}

function show_menu() {
	show_date
	options=( "Display available accounts" "Switch Account" "Quit")
	select option in "${options[@]}"
	do
		case $option in
			"Display available accounts" ) display_available_accounts
			;;
			"Switch Account" ) display_available_accounts; change_account
			;;
			"Quit" ) break
			;;
			* ) echo "Option not available"
			;;
		esac
	done
}

function remove_square_brackets_from_array() {
	for i in ${!array[@]}; do 
		account_no_brackets=$(echo ${array[$i]} | cut -d "[" -f2 | cut -d "]" -f1) 2> /dev/null
		new_array[$i]=$account_no_brackets
	done
	array=("${new_array[@]}")
}

function map_index_to_array() {
	for i in ${!array[@]}; do
		if [ $i -eq $1 ]; then
			account=${array[$i]} #now the account is a string
		fi
	done
}

function change_account() {
	read -p "Which account do you want to switch to: " index
	replaceAWScredentials ${array[$index]}
}

function display_array() {
	for i in ${!array[@]}; do
		if [ "${array[$i]}" = "$1" -o "${array[$i]}" = "default" ]; then
			printf '\e[36m%s:\t%s\e[0m\n' $i ${array[$i]}
		else
			printf "%s:\t%s\n" $i ${array[$i]}
		fi
	done
}

function display_available_accounts() {
	echo "Displaying available accounts: "
	cd $credentials_location
	array=($(grep "\[.*\]" $credentials_filename))
	remove_square_brackets_from_array
	active_account=$(identify_credentials)
	display_array $active_account
}

function identify_credentials() {
	cd $credentials_location
	default_credential_secret_accessKey=$(grep -A 2 "default]" $credentials_filename | tail -n1 );
	account_being_used=$(tail -n +5 "$credentials_filename" | grep -B 2 "$default_credential_secret_accessKey" | head -n1)
	account_being_used_no_brackets=$(echo $account_being_used | cut -d "[" -f2 | cut -d "]" -f1) 2> /dev/null
	echo $account_being_used_no_brackets
}

#identify_credentials
show_menu
	
	