#!/usr/bin/env bash

# regex to match any ebuild https://projects.gentoo.org/pms/8/pms.html
# [0-9]+(\.[0-9]+)+([a-z])?(_alpha|_beta|_pre|_rc|_p)?([a-z])?(-r([0-9]))?.ebuild

function pms_sort() {
	(( $# < 2 )) && if [[ -n "$1" ]]; then
		echo "$1"
		return 0
	else
		ewarn "No version for sorting provided" "\n"
		return 2
	fi
	local latest=""
	local args=""
	args=("${@:1}")
	for (( i = 1; i < $#; i++ )); do
		latest="$(pms_inner_sort "${args[$i]}" "${latest:-${args[$((i - 1))]}}")"
		echo "comparing: $((i - 1)) and $i" >> ./test
		echo -e "args[0] = ${args[0]} and args[1] = ${args[1]} and args[2] = ${args[2]}\n" >> ./test
	done
	echo "$latest"
}


function pms_inner_sort() {
	echo "first: $1" >> ./test
	echo "second: $2" >> ./test
	echo "$1"
}
