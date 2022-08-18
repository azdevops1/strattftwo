#!/bin/bash -x
# Lets start with OS updates

cd /var
sudo su
sudo apt-get update > /var/log/gitlab_aws_install.log
if [ $? -ne 0 ];
then
  echo "OS updates failed"
  exit 1
fi
# Lets install gitlab support tools

sudo apt-get install -y curl openssh-server ca-certificates tzdata perl >> /var/log/gitlab_aws_install.log
if [ $? -ne 0 ];
then
  echo "gitlab support tool install failed"
  exit 1
fi
sudo debconf-set-selections <<< "postfix postfix/mailname string gitlab.aws.shidevops.com" >> /var/log/gitlab_aws_install.log
sudo debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'" >> /var/log/gitlab_aws_install.log
if [ $? -ne 0 ];
then
  echo "postfix preconfig setup failed"
  exit 1
fi
sudo apt-get install --assume-yes postfix >> /var/log/gitlab_aws_install.log
if [ $? -ne 0 ];
then
  echo "postfix install failed"
  exit 1
fi
# Lets pull the gitlab release

curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh|sudo bash >> /var/log/gitlab_aws_install.log
if [ $? -ne 0 ];
then
  echo "gitlab release download failed"
  exit 1
fi
# Lets install gitlab
EXTERNAL_URL="https://gitlab.aws.shidevops.com" sudo apt-get install -y gitlab-ce >> /var/log/gitlab_aws_install.log
if [ $? -ne 0 ];
then
  echo "gitlab install failed"
  exit 1
fi

sudo gitlab-ctl start
