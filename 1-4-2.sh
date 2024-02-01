#!/usr/bin/env bash

{
	output="" output2="" output3="" output4="" non_compliace="" details=""
	# finding directory name that has file name grubenv or grub.conf or grub.cfg in /boot
	# grep -l listing only filename of matching files
	# check if there is kernelopts= kernel boot options, linux, kernel keywords
	# \; is for escaping semi-colon, \( are for grouping the -name together but escaping so that they are not interpreted part of a subshell
	# {} filename placeholder for any file found via find command
	grubdir=$(dirname "$(find /boot -type f \( -name 'grubenv' -o -name 'grub.conf' -o -name 'grub.cfg' \) -exec grep -Pl '^\h*(kernelopts=|linux|kernel)' {} \;)")
	for grubfile in $grubdir/user.cfg $grubdir/grubenv $grubdir/grub.cfg; do
		if [ -f "$grubfile" ]; then
			# retrieve file permission in %a for octal format, the output is matched if group and others don't have any permission
			if stat -c "%a" "$grubfile" | grep -Pq '\h*[0-7]00$'; then
				output="$output\npermissions on \"$grubfile\" are \"$(stat -c "%a" "$grubfile")\""
			else
				output3="$output3\npermissions on \"$grubfile\" are \"$(stat -c "%a" "$grubfile")\""
			fi
			# gather ownership information and match if root user and group ownership
			if stat -c "%u:%g" "$grubfile" | grep -Pq '^\h*0:0$'; then
				output2="$output2\n\"$grubfile\" is owned by \"$(stat -c "%U" "$grubfile")\" and belongs to group \"$(stat -c "%G" "$grubfile")\""
			else
				output4="$output4\n\"$grubfile\" is owned by \"$(stat -c "%U" "$grubfile")\" and belongs to group \"$(stat -c "%G" "$grubfile")\""
			fi
		fi
	done
	echo "Audit title: Ensure permissions on bootloader configuration files are configured"
	if [[ -n "$output" && -n "$output2" && -z "$output3" && -z "$output4" ]]; then
		non_compliance="No"
	else
		non_compliance="Yes"
		details="Grub files need to have permissions of read and write for root only and should belong to root user and group only.\nThe following permissions are not configured correctly."
		[ -n "$output3" ] && details="$details\n$output3"
		[ -n "$output4" ] && details="$details\n$output4"
	fi
	echo "Non-compliance?: $non_compliance"
	if [ -n "$details" ]; then
		echo -e "Details: $details"
	fi
}
