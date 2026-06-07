#!/usr/bin/env bash

# Set up error trapping to handle errors gracefully
error_report() {
  echo "Error occurred in script at line $1. Exiting"
}

trap "error_report $LINENO" ERR

# Get local user name and Git user name from args
while getopts ":u:n:" opt; do
  case $opt in
    u)
      localusername="$OPTARG"
      ;;
    n)
      git_name="$OPTARG"
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

# Install Zsh
install_zsh() {
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"
  cd $HOME
  brew install zsh
}

setup_homebrew() {
  echo >> /home/anedomansky/.zshrc
  echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"' >> /home/anedomansky/.zshrc
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"
}

# Install OhMyZsh and plugins
install_ohmyzsh() {
  cd $HOME
  brew install oh-my-posh
}

# Clone private Dotfiles repo
clone_dotfiles_repo() {
  cd $HOME
  git clone --bare https://github.com/${git_name}/dotfiles.git
  git --git-dir=$HOME/dotfiles.git --work-tree=$HOME reset --mixed HEAD
  git --git-dir=$HOME/dotfiles.git --work-tree=$HOME restore .
}

install_ohmyzsh_plugins() {
  cd $HOME
  brew install zsh-syntax-highlighting
  brew install zsh-autosuggestions
  git clone https://github.com/jirutka/zsh-shift-select.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-shift-select
  brew install zsh-navigation-tools
}

# Install FNM
install_fnm() {
  cd $HOME
  brew install fnm
  cat <<EOF > .zshrc
eval "$(fnm env --use-on-cd --resolve-engines --version-file-strategy=recursive --shell zsh)"
EOF
  eval "$(fnm env --use-on-cd --resolve-engines --version-file-strategy=recursive --shell zsh)"
}

# Install Node LTS
install_node() {
  echo "Installing Node.js LTS version..."
  fnm completions --shell zsh
  fnm install --lts --use
}

# Install Docker
install_docker() {
  cd $HOME
  echo "Installing Docker..."
  brew install docker
}

# Add user to docker group
configure_docker() {
  echo "Configuring Docker permissions..."
  sudo groupadd docker
  sudo usermod -aG docker ${localusername}
}

# Create workspace
create_workspace() {
  mkdir $HOME/workspace
}

# Activate ZSH
activate_zsh() {
  echo "Changing default shell to Zsh..."
  sudo chsh -s $(which zsh) $USER
}

# Main script
{
  install_zsh
  setup_homebrew
  install_ohmyzsh
  clone_dotfiles_repo
  install_ohmyzsh_plugins
  install_fnm
  install_node
  install_docker
  configure_docker
  create_workspace
  activate_zsh
} || {
  exit 1
}
