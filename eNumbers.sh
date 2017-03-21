#!/bin/bash

get_list_available_eNumbers()
{
	eNumbers=( $(curl -s http://www.food-info.net/uk/e/e100-200.htm | grep -E "E[0-9]{3}" | sed -e 's/<[^>]*>//g' -e 's/ \+/ /g' -e '/[fF]ood/d') )
}

display_array()
{
	for i in ${eNumbers[@]}; do
		echo $i
	done
}

get_Upper_lower()
{
	num=$1
	len=${#num}
	zeros=00
	if [[ len -eq 3 ]]; then
		echo ${num:0:1}$zeros
		echo $(( ${num:0:1} +1 ))$zeros
	elif [[ len -eq 4 ]]; then
		echo ${num:0:1}${num:1:1}$zeros
		echo ${num:0:1}$(( ${num:1:1} +1 ))$zeros
	fi
}
get_Upper_lower_v2()
{
	num=$1
	len=${#num}
	echo len = $len
	zeros=00
	if [[ len -eq 3 ]]; then
		echo ${num: -3:1}$zeros
		echo $(( ${num: -3:1} +1 ))$zeros
	elif [[ len -gt 3 ]]; then
		echo ${num: -$((len)):$((len-3))}${num: -3:1}$zeros
		echo ${num: -$((len)):$((len-3))}$(( ${num: -3:1} +1 ))$zeros
	fi
}

get_Upper_lower_v2 $1



getUserInput()
{
	read -p "Which eNumber do you want to display: " num
}

returnInfo()
{
	result=$(curl -s http://www.food-info.net/uk/e/e${num}.htm |
	sed -ne "/>E${num}/,/center/p" | sed -e "s/<[^>]*>//g")
	if [[ -z $result ]]; then
		echo No Information was found on E$num
	else
		echo "$result"
	fi
}

# get_list_available_eNumbers
