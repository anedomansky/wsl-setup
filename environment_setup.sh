#!/usr/bin/env bash

# Set up error trapping to handle errors gracefully
error_report() {
  echo "Error occurred in script at line $1. Exiting"
}

trap "error_report $LINENO" ERR

# Get Git user name and mail from args
while getopts ":n:m:" opt; do
  case $opt in
    n)
      git_name="$OPTARG"
      ;;
    m)
      git_mail="$OPTARG"
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

# Check for regular user
if [[ $EUID -eq 0 ]]; then
  echo "Please run this script as a regular user." 1>&2
  exit 2
fi

# Update system
update_system_packages() {
  sudo apt update
  sudo apt upgrade -y
}

# Install base tools
install_base_tools() {
  sudo apt install -y build-essential procps curl file git gcc
      cat <<EOF > $HOME/.gitconfig
[user]
    name = ${git_name}
    email = ${git_mail}
EOF
}

# Main script
{
  update_system_packages
  install_base_tools
} || {
  exit 1
}
