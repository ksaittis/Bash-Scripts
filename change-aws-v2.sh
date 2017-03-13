#!/bin/bash

# credentials_location="C:/Users/$USERNAME/.aws"
credentials_location="U:/.aws"
credentials_filename=credentials
AVAILABLE_ACCOUNTS=(prod nonprod)
account_type=$1


isArgumentPresent()
{
if [ $# -eq 0 ]; then
	account_type="${1:-nonprod}"
	echo Default value used: $account_type
fi
}

isValidArgument()
{
	found=0
for i in "${AVAILABLE_ACCOUNTS[@]}"; do
    if [ "$i" = "$account_type" ]; then
    	found=1
        replaceAWScredentials "$account_type"
    	tput smul; tput setaf 6; echo "Account changed to $account_type" ; tput sgr0
    fi
done

if [ "$found" -ne 1 ]; then
	echo "Incorrect argument passed"
fi
}


replaceAWScredentials()
{
	cd $credentials_location
	aws_access_key_id=$(grep -w -A 1 $1 $credentials_filename | tail -n1) #removing the -w option of grep makes the scripts more flexible since it doesn't have to match the full word
	aws_secret_access_key=$(grep -w -A 2 $1 $credentials_filename | tail -n1)
	sed -i "2s#.*#$aws_access_key_id#g" $credentials_filename
	sed -i "3s#.*#$aws_secret_access_key#g" $credentials_filename
}

isArgumentPresent $1
isValidArgument $1
