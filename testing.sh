account=( [default] [production] [nonproduction] )

function remove_square_brackets_from_string() {
	for i in ${!account[@]}; do 
		fixed_account=$(echo ${account[$i]} | cut -d "[" -f2 | cut -d "]" -f1) 2> /dev/null
		new_array[$i]=$fixed_account
	done
	echo ${new_array[@]}
}

remove_square_brackets_from_string


:'	
if [[ $1 == prod ]]; then
	account=production
	replaceAWScredentials $account
	
	echo "Now the default account is prod"
elif [[ $1 == nonprod ]]; then
	account=nonproduction
	replaceAWScredentials $account
	
	echo "Now the default account is nonprod"
else
	echo "There is no such account. Select between prod and nonprod."
fi 
'