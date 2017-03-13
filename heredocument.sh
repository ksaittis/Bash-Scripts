#!/bin/bash

# cat << EOF > heredoc.txt
# Create new file with this
# instructions which are
# multiple lines
# EOF

display_help_msg()
{
cat << EOF
Usage: qssh [ACCOUNT] [NAME_TAG]
  or:  qssh [NAME_TAG] [ACCOUNT]
  or:  qssh [HELP]
Prints a list of servers that match the *NAME_TAG* you provide and allows
easy access to them. You can specify the account in which the search is
going to be by providing the argument -p for production account and
-np for non production account. If you don't provide an account arg then it
makes the search on the account that your default credentials in your .aws dir
are pointing to.

The options below may be used to select which server name tag to search for
and in which account to search for.
[NAME_TAG]
  NAME_TAG, server name tag to search for
[ACCOUNT]
  -p, production account
  -np, non production
[HELP]
  --help, display this help and exit
EOF
}

display_help_msg
