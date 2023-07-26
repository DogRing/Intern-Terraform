#!/bin/sh
sudo yum update -y
sudo yum -y install git

# docker 설치
sudo amazon-linux-extras install -y docker
sudo service docker start
sudo usermod -a -G docker ec2-user
sudo chkconfig docker on

# docker compose 설치
sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
systemctl enable docker-compose

# pinpoint 실행
sudo git clone https://github.com/naver/pinpoint-docker.git
cd pinpoint-docker
sudo git checkout tags/2.3.3
sed -i "s|smtp.gmail.com|smtp.naver.com|g" .env
sed -i "s|8079|80|g" .env
sed -i "s|25|587|g" .env
sed -i "s|=username|=changh232@naver.com|g" .env
sed -i "s|=password|=N3JLE5CKR7UG|g" .env
sed -i "s|pinpoint_operator@pinpoint.com|changh232@naver.com|g" .env
sed -i "s|AUTH=false|AUTH=true|g" .env
sed -i "s|ENABLE=false|ENABLE=true|g" .env
sudo docker-compose pull && docker-compose up -d

sudo reboot