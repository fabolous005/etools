#!/usr/bin/env bash

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # The script is being executed directly
	for function in \
		_formatted_find \
		_filter;
	do
		unset $function
	done
fi

function _formatted_find() {
	if [ -z "${ETOOLS_FIND_COMMAND}" ]; then
		# Prevent wordsplitting
		if [ "${ETOOLS_FIND_CMD}" = "fd" ]; then
			# shellcheck disable=SC2086
			fd $ETOOLS_FIND_ARGS "${1}" "${2}" && [ "${ETOOLS_DEBUG}" ] && \
				einfo fd $ETOOLS_FIND_ARGS "${1}" "${2}" >&2
		else
			# shellcheck disable=SC2086
			"$ETOOLS_FIND_CMD" "${2}" $ETOOLS_FIND_ARGS "${1}" && [ "${ETOOLS_DEBUG}" ] && \
				einfo "$ETOOLS_FIND_CMD" "${2}" $ETOOLS_FIND_ARGS "${1}" >&2
		fi
	else
		echo called fd 3
		eval '$(echo "${ETOOLS_FIND_COMMAND//\{repo\}/${2}}" | sed -e "s/{package}/${1}/g")'
	fi
}

function _filter() {
	# TODO: continue here
	echo "$@"
}
