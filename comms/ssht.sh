#!/bin/sh
# Simple wrapper around autossh that automatically:
# - adds a remote command if "#RemoteCommand" is defined in ssh_config, else -N
# - sets AUTOSSH_LOGFILE to ~/.local/share/autossh/autossh.log

get_ssh_config_opt() {
	sed -nr '/^Host\s+(.*\s+)?'"$1"'(\s+|$)/,/^\s*$/p' ~/.ssh/config | sed -nr -e 's/^'"$2"'\s+(.*)/\1/gp'
}

get_host_from_ssh_cmdline() {
	for i in "$@"; do
		case "$i" in
		[/~-]*|*[:@]*) continue;;
		*) echo "$i"; break;;
		esac
	done
}

x_autossh() {
	exec autossh -M 0 -o "ServerAliveInterval 20" "$@"
}

mkdir -p "$HOME/.local/share/autossh"
export AUTOSSH_LOGFILE="$HOME/.local/share/autossh/autossh.log"

HOST=$(get_host_from_ssh_cmdline "$@")
# TODO: detect hostname properly, inc. parse user@host:port correctly
test -n "$HOST" || { echo >&2 "could not detect Host from cmdline: $@"; exit 1; }

RCMD=$(get_ssh_config_opt "$HOST" '[#\s]+RemoteCommand')
# TODO: don't do this if $@ already contains a RCMD
if [ -z "$RCMD" ]; then
	x_autossh -N "$@"
else
	# TODO: parse quotes properly
	x_autossh "$@" $RCMD
fi
