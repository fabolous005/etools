if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # The script is being executed directly
	# for function in \
	# 	_configure;
	# do
	# 	unset $function || echo "failed to unset function: $function"
	# done
	unset _configure || echo "failed to unset function: _configure"
fi


function _configure() {
	# TODO: maybe fix this
	# NOTE: setting options other than the defaults and reconfiguring works
	# switching from custom options to defaults doesn't...

	# Load config for shellcheck
	# shellcheck source=/etc/etools/etools.conf
	[ -f "/etc/etools/etools.conf" ] && . "/etc/etools/etools.conf"
	# shellcheck source=~/.config/etools.conf
	[ -f "$HOME/.config/etools.conf" ] && . "$HOME/.config/etools.conf"
	# shellcheck source=~/.config/etools/etools.conf
	[ -f "$HOME/.config/etools/etools.conf" ] && . "$HOME/.config/etools/etools.conf"


	# The find command to run
	ETOOLS_FIND_CMD=${ETOOLS_FIND_CMD:-"fd"}
	# The Argyments passed to the find command
	ETOOLS_FIND_ARGS=${ETOOLS_FIND_ARGS:-'''
	--exclude profiles --exclude scripts --exclude eclass --exclude metadata
	--exclude dev-perl --exclude dev-ml
	--exclude app-emacs --exclude dev-ruby --exclude acct-user --exclude acct-group
	--type directory --format '"\"{}\""' --max-depth 3 --case-sensitive'''}

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
	ETOOLS_REPO_PATH=${ETOOLS_REPO_PATH:-"/var/db/repos"}


	ETOOLS_COLOR_INFO=${ETOOLS_COLOR_INFO:-'\033[1;34m'}
	ETOOLS_COLOR_WARN=${ETOOLS_COLOR_WARN:-'\033[1;33m'}
	ETOOLS_COLOR_ERROR=${ETOOLS_COLOR_ERROR:-'\033[1;31m'}


	ETOOLS_GREP_CMD=${ETOOLS_GREP_CMD:-"rg"}

	ETOOLS_DEBUG=${ETOOLS_DEBUG:-true}
}
