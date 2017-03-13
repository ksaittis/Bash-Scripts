#!/bin/bash
# setupapachevhost.sh - Apache webhosting automation demo script
file=~/Desktop/Bash\ Scripts/domains.txt

# set the Internal Field Separator to |
IFS='|'
while read -r domain ip webroot ftpusername
do
	printf "Domain:\t%s\nIp:\t%s\nWebroot:\t%s\nUser:\t%s" $domain $ip $webroot $ftpusername
done < "$file"


