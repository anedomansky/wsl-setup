#!/usr/bin/env bash

# Set up error trapping to handle errors gracefully
error_report() {
  echo "Error occurred in script at line $1. Exiting"
}

trap "error_report $LINENO" ERR

# Get local user name and Git user name from args
while getopts ":u:" opt; do
  case $opt in
    u)
      localusername="$OPTARG"
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

install_homebrew() {
  NONINTERACTIVE=1 CI=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

setup_homebrew() {
  echo >> /home/anedomansky/.bashrc
  echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"' >> /home/anedomansky/.bashrc
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"

  # Load brew into current session
  if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  elif [ -x "$HOME/.linuxbrew/bin/brew" ]; then
    eval "$("$HOME/.linuxbrew/bin/brew" shellenv)"
  fi
}


{
  install_homebrew
  setup_homebrew
} || {
  exit 1
}