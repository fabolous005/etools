#!/usr/bin/env bash


# NOTE: parse config, gets run when sourced
function etools_configure() {
	# Load config for shellcheck
	# shellcheck source=/etc/etools/etools.conf
	[ -f "/etc/etools/etools.conf" ] && . "/etc/etools/etools.conf"
	# shellcheck source=~/.config/etools.conf
	[ -f "$HOME/.config/etools.conf" ] && . "$HOME/.config/etools.conf"
	# shellcheck source=~/.config/etools/etools.conf
	[ -f "$HOME/.config/etools/etools.conf" ] && . "$HOME/.config/etools/etools.conf"


	# The find command to run
	[ -z "${ETOOLS_FIND_CMD}" ] && ETOOLS_FIND_CMD="fd"
	# The Argyments passed to the find command
	[ -z "${ETOOLS_FIND_ARGS}" ] && ETOOLS_FIND_ARGS="
	--exclude profile --exclude scripts --exclude eclass --exclude metadata \
	--exclude app-emacs --exclude dev-ruby --exclude acct-user --exclude acct-group \
	--type d"

	# [ -z "${ETOOLS_FIND_CMD}" ] && ETOOLS_FIND_CMD="find"
	# [ -z "${ETOOLS_FIND_ARGS}" ] && \
	# 	ETOOLS_FIND_ARGS="\
	# ! -path './profile*' ! -path './scripts*' -path './eclass*' ! -path './metadata*' \
 #    ! -path './app-emacs*' ! -path './dev-ruby*' ! -path './acct-user*' ! -path './acct-group*' \
 #    -type d -name"

	# A full command that may be specified if FIND_CMD and FIND_ARGS cannot fulfill the needed job
	# 	use {package} as a wildcart for the package that should be search for
	#	use {repo} as a wildcart for the repo to search
	#	use any other variable from ETOOLS inside it
	# [ -z "${ETOOLS_FIND_COMMAND}" ] && ETOOLS_FIND_COMMAND="fd ${ETOOLS_FIND_ARGS} {package} {repo}"

	# The default path in which to look for the repos
	[ -z "${ETOOLS_REPO_PATH}" ] && ETOOLS_REPO_PATH="/var/db/repos"


	[ -z "${COLOR_INFO}" ] && COLOR_INFO='\033[1;34m'
	[ -z "${COLOR_WARN}" ] && COLOR_WARN='\033[1;33m'
	[ -z "${COLOR_ERROR}" ] && COLOR_ERROR='\033[1;31m'


	[ -z "${ETOOLS_DEBUG}" ] && ETOOLS_DEBUG=:
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
			_filer "$(_formatted_find "$@")"
		else
			_filter "$(_formatted_find "${1}" "${ETOOLS_REPO_PATH}/${2}")"
		fi

	else
		. ./etools-helper.sh
		_filter "$(_formatted_find "${1}" "/var/db/repos/")"
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
		etools_configure \
		etools_smart_find \
		etools_unset;
	do
		unset $variable
	done
}


# INFO: einfo function
einfo() {
    echo -e " ${COLOR_INFO}*\033[0m $*"
}

# INFO: ewarn function
ewarn() {
    echo -e " ${COLOR_WARN}* WARNING:\033[0m $*"
}

# INFO: eerror function
eerror() {
    echo -e " ${COLOR_ERROR}* ERROR:\033[0m $*"
}


# make sure we are being sourced and not executed
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
	etools_configure
else
	ewarn "this is a library do not execute it, source it instead" >&2
fi
