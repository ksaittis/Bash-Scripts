#!/bin/bash
### CREDENTIALS ###
credentials_path="C:/Users/$USERNAME/.aws"
# credentials_path="U:/.aws"
credentials_filename=credentials

### AVAILABLE_ACCOUNTS ###
AVAILABLE_ACCOUNTS=(production nonproduction) #Modify if you have more than 2 accounts in credentials .aws dir
account_type=$1

identifyAccount()
{
	if [ $# -eq 0 ]; then #if no arg is passed switch to nonproduction credentials
		account_type="${1:-nonproduction}"
		echo Default value used: $account_type
	fi
	while getopts ":nph" option; do
		case "$option" in
		p)	account_type=production;;
		n)	account_type=nonproduction;;
		h)	display_help; exit 1;;
		*) echo $1
		esac
	done
	shift $((OPTIND-1))
}

display_help()
{
cat << EOF
Usage:  change-aws [ACCOUNT]
   Or:  change-aws [HELP]
Modifies the default aws credentials in your credentials file inside .aws dir.
You can use -p for production, -n for nonproduction of the full word (production, nonproduction)

[ACCOUNT]
  -p, production account
  -n, non production account
  production|nonproduction
[HELP]
  -h, display_help and exit
EOF
}


changeCredentials()
{
	found=0 #validate that arg passed is inside available accounts
	for i in "${AVAILABLE_ACCOUNTS[@]}"; do
	    if [ "$i" = "$account_type" ]; then
	    	found=1
	    fi
	done

	if [ "$found" -eq 1 ]; then
		replaceAWScredentials "$account_type"
		tput setaf 6; echo "AWS credentials now pointing to: $account_type"; tput sgr0
	else
		echo "Incorrect argument passed: $1"
	fi
}


replaceAWScredentials()
{
	credentials_location="$credentials_path/$credentials_filename"
	if [[ -f $credentials_location ]]; then
		aws_access_key_id=$(grep -w -A 1 $1 $credentials_location | tail -n1) #removing the -w option of grep makes the scripts more flexible since it doesn't have to match the full word
		aws_secret_access_key=$(grep -w -A 2 $1 $credentials_location | tail -n1)
		sed -i "2s#.*#$aws_access_key_id#g" $credentials_location
		sed -i "3s#.*#$aws_secret_access_key#g" $credentials_location
	else
		echo "Credentials not found at the specified path."; exit 1
	fi
}

main()
{
	identifyAccount $1
	changeCredentials $1
}

main $1
