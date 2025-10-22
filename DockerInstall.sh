#!/bin/bash
sudo apt-get update -y
sudo apt-get install docker.io -y
sudo usermod -aG docker ubuntu
newgrp docker
sudo chmod 660 /var/run/docker.sock
sudo chown root:docker /var/run/docker.sock
sudo systemctl restart docker
