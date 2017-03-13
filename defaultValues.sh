#!/bin/bash



checkPositionalArguments()
{
	pos1=${1:-"no value passed"}
	echo $pos1
}


checkPositionalArguments $1