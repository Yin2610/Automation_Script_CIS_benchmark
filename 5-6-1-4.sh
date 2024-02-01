#!/bin/bash
test1="non-compliant" test2="non-compliant"
inactive=$(useradd -D | grep INACTIVE | cut -d "=" -f 2) # getting the value set for INACTIVE, user inactive period of time before account got disabled
non_compliance=""
details=""
if [ $inactive -gt 0 -a $inactive -le 30 ]; then       # default inactive from 1 to 30
	test1="compliant"
else
	details="Default inactivity period is not set as 30 days or less.\n So, new user created will not have compliant inactive password lock."
fi
# [^\!\*:]* not ! or * or :
# match if 7th field has \s* zero or whitespace, -1, 31-39, 40-99, 100-999
verify_user=$(awk -F: '/^[^#:]+:[^\!\*:]*:[^:]*:[^:]*:[^:]*:[^:]*:(\s*|-1|3[1-9]|[4-9][0-9]|[1-9][0-9][0-9]+):[^:]*:[^:]*\s*$/ {print $1":"$7}' /etc/shadow)
if [ -z "$verify_user" ]; then
	test2="compliant"
else
	details="$details\nThe password inactive lock period of the following users are not compliant because it is not within the range 1 to 30.\n$verify_user"
fi
if [ $test1 == "compliant" -a $test2 == "compliant" ]; then
	non_compliance="No"
else
	non_compliance="Yes"
fi
echo "Audit title: Ensure inactive password lock is 30 days or less"
echo "Non-compliance?: $non_compliance"
if [ -n "$details" ]; then
	echo -e "Details: $details"
fi
