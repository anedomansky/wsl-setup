#!/usr/bin/env bash

# Set up error trapping to handle errors gracefully
error_report() {
  echo "Error occurred in script at line $1. Exiting"
}

trap "error_report $LINENO" ERR

# Update system
update_system_packages() {
  sudo apt update
  sudo apt upgrade -y
}

# Install Git
install_git() {
  sudo apt install -y git
}

# Install Zsh
install_zsh() {
  sudo apt install -y zsh
  sudo chsh -s $(which zsh)
}

# Main script
{
  update_system_packages
  install_git
  install_zsh
} || {
  exit 1
}
