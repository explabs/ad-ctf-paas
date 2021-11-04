#!/bin/bash
COMPOSE_VERSION=1.29.2

apt-get -y update
apt install -y curl

# Install docker
wget -qO- https://get.docker.com/ | sh

# Install docker-compose
curl -L https://github.com/docker/compose/releases/download/"${COMPOSE_VERSION}"/docker-compose-$(uname -s)-$(uname -m) > /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
# Install autocompletion
curl -L https://raw.githubusercontent.com/docker/compose/"${COMPOSE_VERSION}"/contrib/completion/bash/docker-compose > /etc/bash_completion.d/docker-compose
