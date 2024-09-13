#!/usr/bin/env bash

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # The script is being executed directly
	for function in \
		_formatted_find \
		_set_weights \
		_get_heighest \
		_etools_print_assoc_array \
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
			[ "${ETOOLS_DEBUG}" ] && einfo fd "${1}" "${2}" "$ETOOLS_FIND_ARGS" >&2
		else
			# shellcheck disable=SC2086
			"$ETOOLS_FIND_CMD" "${2}" $ETOOLS_FIND_ARGS "${1}"
			[ "${ETOOLS_DEBUG}" ] && einfo "${ETOOLS_FIND_CMD}" "${2}" "$ETOOLS_FIND_ARGS" "${1}" >&2
		fi
	else
		eval '$(echo "${ETOOLS_FIND_COMMAND//\{repo\}/${2}}" | sed -e "s/{package}/${1}/g")'
	fi
}

function _set_weights() {
	for package in "${!_etools_packages[@]}"; do
		for regex in ${!package_weights[@]}; do
			if [[ ${package//\"/} =~ ^*${regex}*$ ]]; then
				_etools_packages[${package//\"/}]=${package_weights[$regex]}
			fi
		done
	done
}

function _get_heighest() {
	# declare -n _etools_packages=$1
	local max_key=""
    local max_value=-100

    for key in "${!_etools_packages[@]}"; do
        if (( _etools_packages["$key"] > max_value )); then
            max_value=${_etools_packages["$key"]}
            max_key=${key//\"/}
        fi
    done
	echo "$max_key"
}

function _etools_print_assoc_array {
    for key in "${!_etools_packages[@]}"; do
        echo "$key: ${_etools_packages[$key]}"
    done
}

function _filter() {
	(( $# <= 1 )) && ewarn "No packages found, review config options" && return 1;
	declare -Ag _etools_packages
	for package in "$@"; do
		# allow indirect reference
		# shellcheck disable=SC2034
		_etools_packages[$(echo "$package" | tr -d '"' | awk -F'/' '{print $(NF-1)"/"$NF}')]=0
	done
	local functions=
	functions="$(declare -F | "${ETOOLS_GREP_CMD}" 'etools_find_sort_' | awk '{print $3}')"
	# HACK: iterating over possibly fragile output of splitted functions
	# leave warning untils this is stable/fixed
	for function in \
		_set_weights \
		${functions[@]};
	do
		$function
	done
	_etools_print_assoc_array
	_get_heighest 
}
