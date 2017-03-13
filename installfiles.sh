#!/bin/bash
 array=( zero one two three four five deka ) 

yellow="\e[33m"
normal="\e[0m"
magenta="\e[35m"
greem="\e[32m"
bold="\e[1m"
red_tput=$(tput setaf 1 )
green_tput=$(tput setaf 2 )

function show_date() {
echo
a=$(date +"%d-%m-%Y %H:%M:%S")
echo -e $magenta$a
}


function show_menu_options() {
show_date
	echo -e $yellow"---------------------------"
    echo "   Main Menu   "
    echo -e "---------------------------"
options=( "Show list of software to be installed" "Add software to the list" "Remove software from the list" "Install specific software" "Install all software" "Quit")
select option in "${options[@]}"
do 
	case $option in
		"Show list of software to be installed") display_array
		;;
		"Add software to the list") display_array; add_software_to_Array; save_array_to_file; display_array
		;;
		"Remove software from the list") display_array; remove_software_from_array; refresh_array; save_array_to_file; display_array
		;;
		"Install specific software") display_array; install_specific_software;
		;;
		"Install all software") echo "Installing software..."; display_array; install_software
		;;
		Quit) break 
		;;
		*) echo "Not sure what you selected" 
		;;
	esac
	
done
}

function display_array() {
	array_length=${#array[@]}
	echo -e $normal=============================================
	echo -e $magenta"Software ready to be installed: "$normal
	echo =============================================
	echo -e $green_tput"Number of software to be installed: "$array_length
	#echo -e $green_tput${array[@]}
	echo ---------------------------------------------
	for i in ${!array[@]}; do #iterate through array indexes
		printf '%s:\t%s\n' $i ${array[$i]}
	done
}

function add_software_to_Array() {
	read -p "Specify software to be added: " software
	array+=("$software")
}

function save_array_to_file() {
	a="array=( "${array[@]}" )"
	#echo $a
	sed -i "2s/.*/ $a /g" installfiles.sh
}

function remove_software_from_array() {
read -p "Which software to remove from array. Provide Index: " index
for i in ${!array[@]}; do
	if [[ $i == $index ]]; then
		unset array[$i] #unset completely deletes the element from array
		#array[$i]='' # set the string as empty at this specific index
		#software_to_be_deleted=${array[$i]} #alternative way to delete from array
		#array=( "${array[@]/$software_to_be_deleted}" )
	fi
done
}

function refresh_array() {
	for i in ${!array[@]}; do 
		new_array+=( "${array[$i]}" )
	done
	array=( "${new_array[@]}" )
}


function install_software() {
	for i in "${!array[@]}";	do
		sudo apt-get install ${array[$i]} -y
	done
}

function install_specific_software() {
	read -p "Which software do you want to install? Please provide index: " index
	echo "Installing ... ${array[$index]}"
	for i in "${!array[@]}"; do
		if [ $i -eq $index ]; then
			sudo apt-get install ${array[$i]} -y
		fi
	done
}


#actual function executed
show_menu_options



