#!/usr/bin/env bash

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # The script is being executed directly
	for function in \
		_formatted_find \
		_set_weights \
		_get_highest \
		_get_high \
		_default_sort \
		_etools_print_assoc_array \
		_debug_time \
		_most_probable \
		_matches_live \
		_matches_testing \
		_get_latest \
		_extract_version \
		_filter;
	do
		unset $function || echo "failed to unset function: $function"
	done
fi

function _formatted_find() {
	if [ -z "${ETOOLS_FIND_COMMAND}" ]; then
		if [ "${ETOOLS_FIND_CMD}" = "fd" ]; then
			# use wordsplitting
			# shellcheck disable=SC2086
			fd $ETOOLS_FIND_ARGS "${1}" "${2}"
			[ "$ETOOLS_DEBUG" = "true" ] && einfo fd "${1}" "${2}" "$ETOOLS_FIND_ARGS" "\n" >&2
		else
			# shellcheck disable=SC2086
			"$ETOOLS_FIND_CMD" "${2}" $ETOOLS_FIND_ARGS "${1}"
			[ "$ETOOLS_DEBUG" = "true" ] && einfo "${ETOOLS_FIND_CMD}" "${2}" "$ETOOLS_FIND_ARGS" "${1}" "\n" >&2
		fi
	else
		# TODO: do this with bash variable expansion only
		eval '$(echo "${ETOOLS_FIND_COMMAND//\{repo\}/${2}}" | sed -e "s/{package}/${1}/g")'
	fi
}

function _set_weights() {
	for package in "${!_etools_packages[@]}"; do
		# allow reference to sourced value
		# shellcheck disable=SC2154
		for regex in "${!package_weights[@]}"; do
			if [[ $package =~ ${regex} ]]; then
				_etools_packages[$package]=${package_weights[$regex]}
			fi
		done
	done
}

function _get_highest() {
	local max_key=""
    local max_value=-100000

    for key in "${!_etools_packages[@]}"; do
        if (( _etools_packages["$key"] > max_value )); then
            max_value=${_etools_packages["$key"]}
            max_key=${key//\"/}
        fi
    done
	echo "$max_key"
}

function _get_high() {
	local packages=()
    local max_value=-100000

    for key in "${!_etools_packages[@]}"; do
        if (( _etools_packages["$key"] > max_value )); then
            packages=("\"$key\"")
            max_value=${_etools_packages[$key]}
		elif (( _etools_packages[$key] == max_value )); then
            packages+=("\"$key\"")
        fi
    done
	echo "${packages[@]}"
}

function _most_probable() {
	(( $# == 2 )) && echo "${2//\"/}" && return 0;

	# check for exact name match
	for package in "${@:2}"; do
		package=${package//\"/}
		if [[ ${package#*/} == "$1" ]]; then
			echo "$package" && return 0;
		fi
	done

	# check for trailing name match
	for package in "${@:2}"; do
		package=${package//\"/}
		if [[ $package == *"$1" ]]; then
			echo "$package" && return 0;
		fi
	done

	# check for leading name match
	for package in "${@:2}"; do
		package=${package//\"/}
		if [[ $package == "$1"* ]]; then
			echo "$package" && return 0;
		fi
	done

	# TODO: maybe introduce another user function-call hook

	# INFO: at this point we're lucky guessing
	echo "${2//\"/}"
}

function _default_sort() {
	for package in "${!_etools_packages[@]}"; do
		case $package in
			*selinux*)
				_etools_packages["$package"]=$((_etools_packages["$package"] - 30))
				;;
		esac
	done
}

function _etools_print_assoc_array() {
    for key in "${!_etools_packages[@]}"; do
        echo "$key: ${_etools_packages[$key]}"
    done
}

function _debug_time() {
	local end_time=
	end_time=$(date +%s%3N)
	echo $((end_time - $1))
}

function _filter() {
	# local start_time=$(date +%s%3N) && echo 0
	# _debug_time "$start_time"
	(( $# <= 0 )) && ewarn "No packages found, review config options" && return 1;
	declare -Ag _etools_packages
	for package in "$@"; do
		package=${package//\"/}
		base_name="${package##*/}"
		parent_name="${package%/*}"
		parent_name="${parent_name##*/}"
		_etools_packages["$parent_name/$base_name"]=0
	done
	local functions=
	functions="$(declare -F | "${ETOOLS_GREP_CMD}" 'etools_find_sort_' | awk '{print $3}')"
	# HACK: iterating over possibly fragile output of splitted functions
	# leave warning untils this is stable/fixed
	for function in \
		_set_weights \
		_default_sort \
		${functions[@]};
	do
		$function
	done
	# _etools_print_assoc_array
	_get_high
}


function _matches_live() {
	[ ! -f /etc/portage/package.accept_keywords ] && \
		[ ! -d /etc/portage/package.accept_keywords ] && \
		return 1;
	"$ETOOLS_GREP_CMD" "^=$1-9999" /etc/portage/package.accept_keywords >>/dev/null
}

function _matches_testing() {
	[[ "$ACCEPT_KEYWORDS" == *"~amd64"* ]] && return 0;
	[ ! -f /etc/portage/package.accept_keywords ] && \
		[ ! -d /etc/portage/package.accept_keywords ] && \
		return 1;

	"$ETOOLS_GREP_CMD" \
		"$([ "$ETOOLS_GREP_CMD" == "grep" ] && echo "-E")" \
		"^$1-[0-9r-]+ *((~|\*)\*|$2)" /etc/portage/package.accept_keywords
}

function _get_latest() {
	local offset=$2
	local latest=:
	# shopt -s globstar nullglob
	# use ls for simplicity
	# shellcheck disable=SC2045
	for ebuild in $(ls -1vr /var/db/repos/*/"$1"/*.ebuild); do
		if [[ ! "$ebuild" == *"9999"* ]]; then
			# we can't specify the source for this
			# shellcheck disable=SC1090
			. "$ebuild" >>/dev/null 2>/dev/null
			if [[ "$KEYWORDS" == *"$3"* ]]; then 
				latest="$ebuild"
				offset=$((offset - 1))
				if (( offset < 0 )); then
					break;
				fi
			fi
		fi
	done
	[ -z "$latest" ] && (( offset < 0 )) && ewarn "Unused offset of: $(( offset + 1 )), from specified offset of: $2" "\n"
	echo "$latest"
}

function _extract_version() {
    local ebuild="$1"
    local revision=
	[[ $ebuild =~ (-r[0-9])\.ebuild$ ]] && revision="${BASH_REMATCH[1]}"
    ebuild=${ebuild%.ebuild}
    ebuild=${ebuild/-r[[:digit:]]}
    ebuild=${ebuild##*-}
    echo "$ebuild$revision"
}

