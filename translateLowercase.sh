#!/bin/bash

for i in `ls -A`; do
	newName=`echo $i | tr A-Z a-z`
	mv $i $newName
done
