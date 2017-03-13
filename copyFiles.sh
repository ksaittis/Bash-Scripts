#!/bin/bash

function copy_files_from_videos() {
	mkdir videos
	cp -a ~/videos .
}

function copy_files_from_downloads() {
	mkdir downloads
	cp -a ~/downloads .
}

function copy_files_from_documents() {
	mkdir documents
	cp -a ~/documents .
}

function show_menu() {
	options=( "Copy files from:" "Quit")
	select option in "${options[@]}"
	do
		case $option in
			"Copy files from:" ) show_copy_menu
				;;
			"Quit" ) break
				;;
			* ) "Unregognised option"
				;;
		esac
	done
}

function show_size_of_dir() {
	FILENAME=$1
	FILESIZE=$(stat -c%s "$FILENAME")
	#stat --printf="%s" $1
	du -sh $1 #calculates mb used by directory

	#echo "Size of $FILENAME = $FILESIZE bytes."	
}

function show_copy_menu() {
	options=( "videos" "downloads" "documents" "go back" "Quit")
	select option in "${options[@]}"
	 do
		case $option in
			"videos" ) copy_files_from_videos
				;;
			"downloads" ) copy_files_from_downloads
				;;
			"documents" ) copy_files_from_documents
				;;
			"go back" ) show_menu
				;;
			"Quit" ) break
				;;
			* ) echo "Unregognised command"
				;;
		esac
	done
}


show_size_of_dir ~/documents











