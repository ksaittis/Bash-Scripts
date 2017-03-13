#!/bin/bash

normal='\e[39m'

function foreground_colour_creation() {
	colour='\e[38;5;'$1'm'
	echo -e $colour$2$normal
}

function background_colour_creation() {
	colour='\e[48;5;'$1'm'
	echo -en $colour$2$normal
}

function all_foreground_colours() {
	for i in {1..256}; do
		colour=$(foreground_colour_creation $i $1)
		printf '%s:\t%s\n' $i $colour
	done
}

function all_background_colours() {
	for i in {1..256}; do
		colour=$(background_colour_creation $i $1)
		printf '%s:\t%s\n' $i $colour
	done
}

#all_foreground_colours Hello_World
all_background_colours Hello_World


