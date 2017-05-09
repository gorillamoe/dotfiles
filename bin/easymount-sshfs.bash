#!/bin/bash

# Checks if user can run sudo
has_sudo() {
	if ! sudo -v
		then echo 0
	else
		echo 1
	fi
}

has_sshfs() {
	if hash sshfs 2>/dev/null; then
		echo 1
	else
		echo 0
	fi
}

main() {
	# Check if user has `sudo` support
	if [[ $(has_sudo) == 0 ]]; then
		echo "sudo does not work."
		exit 1
	fi
	if [[ $(has_sshfs) == 0 ]]; then
		echo "sshfs is required, but not (yet) installed."
		exit 2
	fi
	local tmp_in=""
	local private_key_path="/home/marco/.ssh/id_rsa"
	local ssh_user="mkellershoff"
	local ssh_port=22
	local remote_host="backend.onmeda.de.local"
	local remote_path="/www/backend.onmeda.de"
	local local_path="/www/backend.onmeda.de"

	echo -n "Private Key Path (Default: $private_key_path): "
	read -re tmp_in
	if [[ ! -z $tmp_in ]]; then private_key_path=$tmp_in;
	else echo "Using Default: $private_key_path"; fi
	echo

	echo -n "SSH Username (Default: $ssh_user): "
	read -r tmp_in
	if [[ ! -z $tmp_in ]]; then ssh_user=$tmp_in;
	else echo "Using Default: $ssh_user"; fi
	echo

	echo -n "SSH Port (Default: $ssh_port): "
	read -r tmp_in
	if [[ ! -z $tmp_in ]]; then ssh_port=$tmp_in;
	else echo "Using Default: $ssh_port"; fi
	echo

	echo -n "Remote Host (Default: $remote_host): "
	read -r tmp_in
	if [[ ! -z $tmp_in ]]; then remote_host=$tmp_in;
	else echo "Using Default: $remote_host"; fi
	echo

	echo -n "Remote Path (Default: $remote_path): "
	read -re tmp_in
	if [[ ! -z $tmp_in ]]; then remote_path=$tmp_in;
	else echo "Using Default: $remote_path"; fi
	echo

	echo -n "Local Path (Default: $local_path): "
	read -re tmp_in
	if [[ ! -z $tmp_in ]]; then local_path=$tmp_in;
	else echo "Using Default: $local_path"; fi
	echo

	sudo sshfs -p "$ssh_port" -o allow_other,IdentityFile="$private_key_path" "$ssh_user"@"$remote_host":"$remote_path" "$local_path"
}

# Only execute when called directly and not sourced
if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
	main
fi
