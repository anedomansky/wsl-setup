#!/bin/bash

# Set up error trapping to handle errors gracefully
error_report() {
  echo "Error occurred in script at line $1. Exiting"
}

trap "error_report $LINENO" ERR

# Check for root user
if [[ $EUID -ne 0 ]]; then
  echo "Please run this script as root user or use 'sudo ./initial_setup.sh'." 1>&2
  exit 100
fi

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

# Configure WSL settings
configure_wsl() {
    cat <<EOF > /etc/wsl.conf
[user]
default=${localusername}
[boot]
systemd=true
EOF
}

# Create a local user if it doesn't exist
create_local_user() {
  if ! grep -q ${localusername} /etc/passwd; then
    useradd ${localusername} -c "created by WSL initial setup" \
    -m -s /bin/bash -U
    echo "User ${localusername} created. Please set a password for this user."
    passwd "${localusername}"
  fi
}

add_user_to_sudoers() {
  echo "${localusername} ALL=(ALL) ALL" > /etc/sudoers.d/${localusername}
  chmod 0440 /etc/sudoers.d/${localusername}
}

{
  configure_wsl
  create_local_user
  add_user_to_sudoers
} || {
exit 1
}
