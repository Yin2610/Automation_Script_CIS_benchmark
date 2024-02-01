#!/bin/bash

# To get line(s) within sudo configuration files that control logging behavior, specifically those that set the logfile option
result=`grep -rPsi "^\h*Defaults\h+([^#]+,\h*)?logfile\h*=\h*(\"|\')?\H+(\"|\')?(,\h*\H+\h*)*\h*(#.*)?$" /etc/sudoers*`

# ------------------------------------diving into details-------------------------------------------------------
# grep -r recursive, -P perl regex, -s suppress error msgs if file unreachable, -i ignore case sensitivity
# \h horizontal whitespace, \H non-horizontal whitespace characters which also can be alphabets,slahes and dots.
# ([^#]+, \h*)? match anything that are not # (? optional), (\"|\')? double quotes or single quotes
# (,\h*\H+\h*)* matches any additional configuration options after logfile path (e.g. log_host, log_year)
# (#.*)? optionally matches a comment starting with # until end of line

non_compliance=""
details=""
if [ -z "$result" ]
then
	non_compliance="Yes"
	details="Sudo log file does not exist."
else
	non_compliance="No"
fi

echo "Audit title: Ensure sudo log file exists"
echo "Non-Compliance?: $non_compliance"
if [ -n "$details" ]
then
	echo -e "Details: $details"
fi
