#!/bin/bash


function encrypt_message() {
echo <<EOZ Welcome, I am ready to encrypt a file/folder for you
currently I have a limitation, Place me to the same folder, where a file to be 
encrypted is present.
EOZ
echo

encrypt_file $file
echo "I have encrypted the file successfully..."
echo "I will now be removing the original file"
#rm_file $file
}

function encrypt_file() {
	gpg -c $1
}

function rm_file()  {
	rm -rf $1
}

function display_array() {
	array=$1

	for i in ${!array[@]}; do
		printf '%s: \t %s\n' "$i" ${array[$i]} 
	done
}

function create_array_files_from_dir() {
	number_of_files=($(ls -U | wc -l))
	i=1
	while [ $i -le $number_of_files ]; do
		line_number=$i'p'
		array[$i]=$(ls -U | sed -n $line_number)
		i=$((i+1))
	done
	display_array $array
}

function display_available_files() {	
	#array=($(ls | cat)) issue when file contains empty spaces
	echo "Enter the index of the File you want to encrypt:" 
	display_array $array
	read index
	for i in ${!array[@]}; do
		if [ "$i" -eq "$index" ]; then
			encrypt ${array[$index]}
		fi
	done
}

function display_array_alt() {
		echo
		declare -a files=$(ls -U)
		i=0
		for word in ${files[@]}; do
			printf "%s:\t%s\n" $i "$word"
			((i++))
		done
}

function display_array_alt2() {
		tput clear
		#translate commas into new lines and then sed removes the lines that are empty by searching for a line that starts with whitespace aanynumber of time and finishes with white space.
		ls -m | cat | tr ',' '\n' | sed '/^\s*$/d' | sed 's/\s/_/g' | sed 's/^_//g' > file.csv
		readarray a < file.csv
		i=0
		tputlines=$(($(tput lines)/3))
		tpucols=$(($(tput cols)/3))
		for word in ${a[@]}; do
			tput cup $tputlines $(( $tpucols ))

			printf "%s:\t%s\n" $i "${word^}"
			((i++))
			tputlines=$((tputlines + 1))
		done 
}

display_array_alt2


# tr '[:lower:]' '[:upper:]'


# To lowercase

# $ string="A FEW WORDS"
# $ echo "${string,}"
# a FEW WORDS
# $ echo "${string,,}"
# a few words
# $ echo "${string,,[AEIUO]}"
# a FeW WoRDS

# $ string="A Few Words"
# $ declare -l string
# $ string=$string; echo "$string"
# a few words
# To uppercase

# $ string="a few words"
# $ echo "${string^}"
# A few words
# $ echo "${string^^}"
# A FEW WORDS
# $ echo "${string^^[aeiou]}"
# A fEw wOrds

# $ string="A Few Words"
# $ declare -u string
# $ string=$string; echo "$string"
# A FEW WORDS
# Toggle (undocumented)

# $ string="A Few Words"
# $ echo "${string~~}"
# a fEW wORDS
# $ string="A FEW WORDS"
# $ echo "${string~}"
# a fEW wORDS
# $ string="a few words"
# $ echo "${string~}"
# A Few Words
# Capitalize (undocumented)

# $ string="a few words"
# $ declare -c string
# $ string=$string
# $ echo "$string"
# A few words
# Title case:

# $ string="a few words"
# $ string=($string)
# $ string="${string[@]^}"
# $ echo "$string"
# A Few Words

# $ declare -c string
# $ string=(a few words)
# $ echo "${string[@]}"
# A Few Words
# To turn off a declare attribute, use +. For example, declare +c string. This affects subsequent assignments and not the current value.

# Edit:

# Added "toggle first character by word" (${var~}) as suggested by ghostdog74.










