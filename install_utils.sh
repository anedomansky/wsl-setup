#!/usr/bin/env bash

# Set up error trapping to handle errors gracefully
error_report() {
  echo "Error occurred in script at line $1. Exiting"
}

trap "error_report $LINENO" ERR

# Get local user name from args
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

# Install OhMyZsh and plugins
install_ohmyzsh() {
  cd $HOME
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
}

# Clone private Dotfiles repo
clone_dotfiles_repo() {
  cd $HOME
  git clone --bare https://gitlab.com/anedomansky/dotfiles.git
  git --git-dir=$HOME/dotfiles.git --work-tree=$HOME reset --mixed HEAD
  git --git-dir=$HOME/dotfiles.git --work-tree=$HOME restore .
}

install_ohmyzsh_plugins() {
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
  git clone https://github.com/jirutka/zsh-shift-select.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-shift-select
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/z-shell/zsh-navigation-tools/main/doc/install.sh)"
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
}

# Install NVM
install_nvm() {
  cd $HOME
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash
}

# Install Node LTS
install_node() {
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
  nvm install --lts
  nvm use --lts
}

# Install Docker
install_docker() {
  # Add Docker's official GPG key:
  sudo apt install -y ca-certificates curl
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc

  # Add the repository to Apt sources:
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt update
  sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}

# Add user to docker group
configure_docker() {
  sudo groupadd docker
  sudo usermod -aG docker ${localusername}
}

# Activate ZSH
activate_zsh() {
  sudo chsh -s $(which zsh) $USER
}

# Main script
{
  install_ohmyzsh
  clone_dotfiles_repo
  install_ohmyzsh_plugins
  install_nvm
  install_node
  install_docker
  configure_docker
  activate_zsh
} || {
  exit 1
}
