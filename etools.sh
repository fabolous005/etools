#!/usr/bin/env bash



# NOTE: parse config, gets run when sourced
function etools_configure() {
	. ./config.sh
	_configure
	./config.sh
}



# NOTE: find a package just by it's name
# the function will go on to print out the most likely result with leading category
function etools_smart_find() {
	[[ "${1}" = *"/"* ]] && echo "${1}" && \
		ewarn "do not use this function with specified category" >&2 && return 0;
	[ "${1}" = "" ] && eeror "no package name provided" && return 2;
	if [ ! "${2}" = "" ]; then
		[ ! -d "${2}" ] && [ ! -d "${ETOOLS_REPO_PATH}/${2}" ] && \
			eerror "no valid repository name" && return 2;
		. ./etools-helper.sh
		if [[ "${2}" == /* ]]; then
			# shellcheck disable=SC2046
			_filter $(_formatted_find "$@")
		else
			# shellcheck disable=SC2046
			_filter $(_formatted_find "${1}" "${ETOOLS_REPO_PATH}/${2}")
		fi
	else
		. ./etools-helper.sh
		# shellcheck disable=SC2046
		_filter $(_formatted_find "${1}" "/var/db/repos")
	fi
	# unset helper functions
	./etools-helper.sh
}


# INFO: unset all variables
function etools_unset() {
	for variable in \
		ETOOLS_FIND_CMD \
		ETOOLS_FIND_ARGS \
		ETOOLS_FIND_ARGS \
		ETOOLS_FIND_COMMAND \
		ETOOLS_REPO_PATH \
		einfo \
		ewarn \
		eerror \
		etools_configure \
		etools_smart_find \
		etools_unset;
	do
		unset $variable
	done
}


# INFO: einfo function
einfo() {
    echo -e " ${ETOOLS_COLOR_INFO}*\033[0m $*"
}

# INFO: ewarn function
ewarn() {
    echo -e " ${ETOOLS_COLOR_WARN}* WARNING:\033[0m $*"
}

# INFO: eerror function
eerror() {
    echo -e " ${ETOOLS_COLOR_ERROR}* ERROR:\033[0m $*"
}


# make sure we are being sourced and not executed
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
	etools_configure
else
	ewarn "this is a library do not execute it, source it instead" >&2
	return 2;
fi
