FROM ubuntu:18.04

RUN apt-get clean all
RUN apt-get update

# Install Ruby
RUN apt-get install ruby-full -y
RUN gem install bundler -v 1.17.3

# Install Python
RUN apt-get install -y python3-pip python3-dev \
  && cd /usr/local/bin \
  && ln -s /usr/bin/python3 python \
  && pip3 install --upgrade pip

# Others
RUN apt-get update
RUN apt-get install git -y
RUN apt-get install rsync -y

# Install Terraform (used in newrelic instrumentations for alerts)
RUN apt-get update
RUN apt-get install software-properties-common curl -y
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
RUN apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com bionic main"
RUN apt-get update && apt-get install terraform -y

RUN mkdir /mnt/deployer
WORKDIR /mnt/deployer

COPY Gemfile Gemfile.lock /mnt/deployer/

RUN bundle install --clean --force

# Install Python dependencies
RUN python3 -m pip install setuptools
# Ansible
RUN python3 -m pip install ansible==2.9.9
# AWS
RUN python3 -m pip install boto3
RUN python3 -m pip install botocore
RUN python3 -m pip install boto
# Azure
RUN python3 -m pip install ansible[azure]
RUN python3 -m pip install packaging
RUN python3 -m pip install msrestazure
# GCP
RUN python3 -m pip install google-auth
# Windows
RUN python3 -m pip install pywinrm


# Install Ansible dependencies
RUN ansible-galaxy role install newrelic.newrelic-infra
RUN ansible-galaxy role install newrelic.newrelic_java_agent

RUN ansible-galaxy collection install community.aws
RUN ansible-galaxy collection install google.cloud
RUN ansible-galaxy collection install ansible.windows
RUN ansible-galaxy collection install community.mysql

COPY . /mnt/deployer/
# CMD [ "ruby", "--version"]
# CMD [ "python", "--version"]
# CMD [ "rake"]

ENTRYPOINT [ "ruby", "main.rb" ]
