#!/usr/bin/env bash

{
	tst=""  output="" non_compliance="" details=""
	# finding directory name that has file name grubenv or grub.conf or grub.cfg in /boot
        # grep -l listing only filename of matching files
        # check if there is kernelopts= kernel boot options, linux, kernel keywords
        # \( are for grouping the -name together but escaping so that they are not interpreted part of a subshell
        # {} filename placeholder for any file found via find command
	grubdir=$(dirname "$(find /boot -type f \( -name 'grubenv' -o -name 'grub.conf' -o -name 'grub.cfg' \) -exec grep -El '^\s*(kernelopts=|linux|kernel)' {} \;)")
	if [ -f "$grubdir/user.cfg" ]; then
	# check if bootloader password in user.cfg
		tst=$(grep -P '^\h*GRUB2_PASSWORD\h*=\h*.+$' "$grubdir/user.cfg")
		if [ -n "$tst" ]; then
			output="bootloader password set in \"$grubdir/user.cfg\""
		else
			details="bootloader password is not set in \"$grubdir/user.cfg\""
		fi
	else
		details="\"$grubdir/user.cfg\" does not exist."
	fi
	[ -n "$output" ] && non_compliance="No"
	[ -z "$output" ] && non_compliance="Yes"
	echo "Audit title: Ensure bootloader password is set"
	echo "Non-compliance?: $non_compliance"
	if [ -n "$details" ]; then
		echo -e "Details: $details"
	fi
}
