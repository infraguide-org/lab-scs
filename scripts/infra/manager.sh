#!/usr/bin/env bash
# Source: https://github.com/infraguide-org/lab-scs
# Copyright (c) 2026 infraguide.org, MIT License

set -e

# include the script from setup-sandbox
curl -sSL --proxy http://proxy.lab.nfgd.net:3128 https://nfgd.net/raw/setup-sandbox/scripts/infra/deployment.sh | bash


# no dialogs (debconf, needrestart) and no reading from stdin: the script itself
# comes through the pipe of "curl | bash" and must not be consumed by apt
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

apt-get update

apt-get install -y \
  crudini          \
  make             \
  ovn-common       \
  skopeo           \
  </dev/null

SYS_USER_NAME=deploy

# -f: no error when the group already exists (second run)
groupadd -f dragon
# -a: add the groups, keep the existing ones (e.g. sudo)
usermod -aG docker,dragon $SYS_USER_NAME

sudo -i -u $SYS_USER_NAME bash << "AS_SYS_USER"
LAB_NAME=lab-scs

cat >> ~/.profile <<EOF

alias lab-stack='tmuxp load -y ~/$LAB_NAME/conf/tmuxp.yaml'
EOF

mkdir -p $LAB_NAME && \
curl -sSL https://github.com/infraguide-org/$LAB_NAME/archive/HEAD.tar.gz | \
tar -xz -C $LAB_NAME --strip-components=1

# deploy/openstack is the submodule $LAB_NAME-config, the tarball above
# leaves it empty
curl -sSL https://github.com/infraguide-org/$LAB_NAME-config/archive/HEAD.tar.gz | \
tar -xz -C ~/$LAB_NAME/deploy/openstack --strip-components=1

python3 -m venv $HOME/venv/openstack
source $HOME/venv/openstack/bin/activate
pip3 install -U pip
pip3 install -r ~/$LAB_NAME/deploy/openstack-cli/requirements.txt

# clouds.yaml for OS_CLOUD, -f: replace the link on a second run
mkdir -p ~/.config/openstack
ln -sf /opt/configuration/environments/openstack/clouds.yml ~/.config/openstack/clouds.yaml

cat >> ~/.profile <<"EOF"
##############################################################################
# openstack

export OPENSTACK_DIR=~/openstack

if [ -z "$VIRTUAL_ENV" -a -f ~/venv/openstack/bin/activate ]
then
  source ~/venv/openstack/bin/activate
fi

export OS_CLOUD=admin

export PS1="[\u@\h \W|\[\e[1;32m\]\$OS_USERNAME.\$OS_PROJECT_NAME\[\e[m\]]\$"
source <(openstack complete)

function o
{
  openstack $@  | cat
}
complete -F _openstack o

##############################################################################
# ovn
export OVN_SB_DB=tcp:10.20.8.32:6642,tcp:10.20.8.33:6642,tcp:10.20.8.34:6642
export OVN_NB_DB=tcp:10.20.8.32:6641,tcp:10.20.8.33:6641,tcp:10.20.8.34:6641
EOF

AS_SYS_USER
