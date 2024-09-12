#!/usr/bin/env bash

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # The script is being executed directly
	for function in \
		_formatted_find \
		_sort_weights \
		_get_heighest \
		_sort_table \
		_filter;
	do
		unset $function || echo "failed to unset function: $function"
	done
fi

function _formatted_find() {
	if [ -z "${ETOOLS_FIND_COMMAND}" ]; then
		# Prevent wordsplitting
		if [ "${ETOOLS_FIND_CMD}" = "fd" ]; then
			# shellcheck disable=SC2086
			fd $ETOOLS_FIND_ARGS "${1}" "${2}"
			[ "${ETOOLS_DEBUG}" ] && einfo fd "${1}" "${2}" "$ETOOLS_FIND_ARGS" >&2
		else
			# shellcheck disable=SC2086
			"$ETOOLS_FIND_CMD" "${2}" $ETOOLS_FIND_ARGS "${1}"
			[ "${ETOOLS_DEBUG}" ] && einfo "${ETOOLS_FIND_CMD}" "${2}" "$ETOOLS_FIND_ARGS" "${1}" >&2
		fi
	else
		echo called fd 3
		eval '$(echo "${ETOOLS_FIND_COMMAND//\{repo\}/${2}}" | sed -e "s/{package}/${1}/g")'
	fi
}

function _sort_weights() {
	declare -n arr=$1
}

function _get_heighest() {
	echo
}

function _sort_table() {
	echo
}

function _filter() {
	(( $# <= 1 )) && ewarn "No packages found, review config options" && return 1;
	echo "$@"
	declare -A packages
	for package in "$@"; do
		packages[$(echo "$package" | awk -F'/' '{print $(NF-1)"/"$NF}')]=0
	done
	for function in \
		_sort_table \
		$(declare -F | "${ETOOLS_GREP_CMD}" 'etools_find_sort_') \
		_get_heighest;
	do
		$function packages
	done
}
