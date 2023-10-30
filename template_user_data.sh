#!/bin/bash

sudo yum update -y

# instalação docker e docker compose
sudo yum install docker -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo mv /usr/local/bin/docker-compose /usr/bin/docker-compose

# configuração do efs
sudo yum install nfs-utils -y
sudo systemctl start nfs-server
sudo systemctl enable nfs-server
sudo mkdir /mnt/efs/
sudo chmod 777 /mnt/efs/
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport fs-0e395848c30fa3067.efs.us-east-1.amazonaws.com:/ /mnt/efs
sudo chown ec2-user:ec2-user /mnt/efs
echo "fs-0e395848c30fa3067.efs.us-east-1.amazonaws.com:/ /mnt/efs nfs defaults 0 0" | sudo tee -a /etc/fstab

# configuração do wordpress com docker-compose
curl -sL "https://raw.githubusercontent.com/biancaprcbs/Atividade_Docker_PB/main/docker-compose.yaml" --output "/home/ec2-user/docker-compose.yaml"
cd /home/ec2-user
docker-compose up -d
