#!/bin/bash

#doesn't work if there are files or dirs with spaces in their name

cd ~/Desktop/New\ Folder


#reads the files of a dir and creates an array
function create_array_dirs()
{ 
	for word in $(ls -m); do
		#declare a local variable
		typeset dir_name 
		#check if the last character is a comma
		if [ "${word: -1}" == "," ]; then
			#remove the last character of the string (which is a comma)
			dir_name="${word::-1}" 
		else
			dir_name="$word"
		fi
		array+=( "$dir_name" )		
	done
}

#for debugging reasons
function display_array()
{
	array=( "$@" ) #pass all arguments (array) to a new array
	for i in ${!array[@]}; do
		printf "%s :\t %s \n" "$i" "${array[$i]}"
	done
}

function create_array_dirs_v2()
{ 
	ls -m | cat | tr ',' '\n' | sed '/^\s*$/d' | sed 's/^_//g' | sed 's/\/$//' | sed 's/^\s//' > dirs.txt
	readarray array < dirs.txt
	rm dirs.txt
}


function identify_dirs_v2()
{
	for word in ${array[@]}; do
		if [ -d "$word" ]; then
			array_dirs+=( "$word" )
		fi
	done
}




function execute_command(){
	for dir_name in ${array_dirs[@]}; do
		cd "./$dir_name" ; touch failurev3 ; cd ..
	done
}


function create_exec_array_dirs_v3()
{ 
	ls -m | cat | tr ',' '\n' | sed '/^\s*$/d' | sed 's/^_//g' | sed 's/\/$//' | sed 's/^\s//' > dirs.txt
	#cat dirs.txt
	while read line; do
		if [ -d "$line" ] ; then
			#array+=( "$line" )
			cd "./$line" ; touch failureV3 ; cd ..
		fi
	done < dirs.txt
	rm dirs.txt
}


create_exec_array_dirs_v4()
{ 
	echo `pwd`
	ls -F | grep / >./dirs.txt
	cat dirs.txt
}

one_line_command()
{
find . -maxdepth 1 -type d \( ! -name . \) -exec bash -c "cd '{}' && pwd" \;
}


# Create_file_dirs
# create_exec_array_dirs_v4
echo


unset array



