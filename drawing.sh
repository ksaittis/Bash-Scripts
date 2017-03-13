#!/bin/bash

function draw_shape() {
	if [[ -n $1 ]]; then
		shape=$1
	else
		shape=.
	fi
	printf "%s" $shape
}

function draw_n_times() {
	i=0
	while [ $i -lt $1 ]; do
		draw_shape $2
		i=$((i+1))
	done
}

function draw_n_lines_incrementing_by_1() {
	i=0
		while [ $i -lt $1 ]; do
			draw_n_times $i $2
			i=$((i+1))
			echo
		done
}

function draw_n_lines_decrementing_by_1() {
	i=$1
		while [ $i -gt 0 ]; do
			draw_n_times $i $2
			i=$((i-1))
			echo
		done
}

function draw_n_lines_incrementing_by_k() {
	i=0
		while [ $i -lt $1 ]; do
			draw_n_times $i
			i=$((i+$2))
			echo
		done
}

function draw_n_lines_decrementing_by_k() {
	i=$1
		while [ $i -gt 0 ]; do
			draw_n_times $i
			i=$((i-$2))
			echo
		done
}

function draw_n_spaces() {
	spaces=$1
	spaces="%0$1d"
	printf $spaces
}


function drawing_with_spaces() {
	i=$1
	a=$((i-1)) 
	echo $a
	u=$(($i-$a))
	echo $u
	while [ $i -gt 0 ]; do
		echo $i
		draw_n_spaces $i		
		draw_n_times $u a
		a=$((a-1)) 
		u=$(($i-$a))
		i=$((i-1))
		echo $i
	done
}

drawing_with_spaces 9


#draw_n_lines_incrementing_by_1 10 a
#draw_n_lines_decrementing_by_1 10 a

#draw_n_lines_incrementing_by_k 10 2
#draw_n_lines_decrementing_by_k 10 2



