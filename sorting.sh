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


# Original python code for portage can be found here:
# /usr/lib/python3.12/site-packages/portage/versions.py:121
function pms_inner_sort() {
	local _unknown_repo="__unknown__"

	# \w is [a-zA-Z0-9_]

	# PMS 3.1.3: A slot name may contain any of the characters [A-Za-z0-9+_.-].
	# It must not begin with a hyphen or a dot.
	local _slot="([\w+][\w+.-]*)"

	# 2.1.1 A category name may contain any of the characters [A-Za-z0-9+_.-].
	# It must not begin with a hyphen or a dot.
	local _cat="[\w+][\w+.-]*"

	# 2.1.2 A package name may contain any of the characters [A-Za-z0-9+_-].
	# It must not begin with a hyphen,
	# and must not end in a hyphen followed by one or more digits.
	local _pkg="[\w+][\w+-]*?"

	local _v="([0-9]+)((\.[0-9]+)*)([a-z]?)((_(pre|p|beta|alpha|rc)[0-9]*)*)"
	local _rev="[0-9]+"
	local _vr="$_v"
	_vr+="?(-r("
	_vr+="$_rev"
	_vr+="))?"

	local _cp="("
	_cp+="$_cat"
	_cp+="/"
	_cp+="$_pkg"
	_cp+="(-"
	_cp+="$_vr"
	_cp+=")?)"

	local _cpv="("
	_cpv+="$_cp"
	_cpv+="-"
	_cpv+="$_vr"
	_cpv+=")"

	local _pv="(?P<pn>"
	_pv+="$_pkg"
	_pv+="(?P<pn_inval>-"
	_pv+="$_vr"
	_pv+=")?)"
	_pv+="-(?P<ver>"
	_pv+="$_v"
	_pv+=")(-r(?P<rev>"
	_pv+="$_rev"
	_pv+="))?"

	# local ver_regexp=
	local ver_regexp="^"
	ver_regexp+="$_vr"
	ver_regexp+="$"

	declare -a match1=()
	declare -a match2=()

	if [[ $1 =~ $ver_regexp ]]; then
		for (( i=1; i<${#BASH_REMATCH[@]}; i++ )); do
			match1+=("${BASH_REMATCH[$i]}")
		done
	else
		# TODO: replace these with eerrors and ETOOLS_DEBUG checks
		echo "ERROR: syntax error in version: $1" && return 2;
	fi
	if [[ $2 =~ $ver_regexp ]]; then
		for (( i=1; i<${#BASH_REMATCH[@]}; i++ )); do
			match2+=("${BASH_REMATCH[$i]}")
		done
	else
		# TODO: replace these with eerrors and ETOOLS_DEBUG checks
		echo "ERROR: syntax error in version: $2" && return 2;
	fi

	echo "$ver_regexp"
	echo "${match1[@]}"
	echo "${match2[@]}"

	if (( match1[0] < match2[0] )); then
		echo "$2"
		return 0
	elif (( match1[0] > match2[0] )); then
		echo "$1"
		return 0
	fi

	declare -a list1=()
	declare -a list2=()

	IFS='.' read -r -a vlist1 <<< "${match1[1]:1}"
	IFS='.' read -r -a vlist2 <<< "${match2[1]:1}"
	for (( i=0; i<( ${#vlist1[@]} > ${#vlist2[@]} ? ${#vlist1[@]} : ${#vlist2[@]} ); i++ )); do
		if (( ${#vlist1[@]} <= i || ${#vlist1[$i]} == 0 )); then
			# echo -e "length: ${#vlist1[@]}\tvalue: ${vlist1[$i]}\tvalue length: ${#vlist1[$i]}"
			list1+=("-1")
			list2+=("${vlist2[$i]}")
		elif (( ${#vlist2[@]} <= i || ${#vlist2[$i]} == 0 )); then
			list1+=("${vlist1[$i]}")
			list2+=("-1")
		elif [[ ${vlist1[$i]} != 0* && ${vlist2[$i]} != 0* ]]; then
			list1+=("${vlist1[$i]}")
			list2+=("${vlist2[$i]}")
		else
			local max_len=$(( ${#vlist1[$i]} > ${#vlist2[$i]} ? ${#vlist1[$i]} : ${#vlist2[$i]} ))
			list1+=("$(printf "%-s" "${vlist1[$i]}$(printf "%${max_len}s" | tr ' ' "0")")")
			list2+=("$(printf "%-s" "${vlist2[$i]}$(printf "%${max_len}s" | tr ' ' "0")")")
		fi
	done

	[[ -n ${match1[3]} ]] && list1+=("$(printf "%d" "'${match1[3]}")")
	[[ -n ${match2[3]} ]] && list2+=("$(printf "%d" "'${match2[3]}")")

	echo "${list1[@]}"
	echo "${list2[@]}"

	echo "$1"
}
