#!/bin/bash
non_compliance="" details=""
result=$(awk -F: '($3 == 0) { print $1 }' /etc/passwd)     # get line with UID 0
nameuid=$(awk -F: '($3 == 0) { print $1, $3 }' /etc/passwd)
if [ "$result" == "root" ]; then
	non_compliance="No"
else
	non_compliance="Yes"
	details="It is not compliant. The following account(s) also have UID 0."
	details="$details\n$(echo -e "$nameuid" | grep -v root)"       # removing root and display the other accounts with UID 0
fi
echo "Audit title: Ensure root is the only UID 0 account"
echo "Non-compliance?: $non_compliance"
if [ -n "$details" ]; then
	echo -e "Details: $details"
fi
