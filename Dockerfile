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
RUN python3 -m pip install --upgrade setuptools

# Install Ansible
RUN python3 -m pip install ansible
RUN python3 -m pip install boto3
RUN python3 -m pip install botocore
RUN python3 -m pip install boto

# Others
RUN apt-get install git rsync -y

# Ansible galaxy plugins
RUN ansible-galaxy install newrelic.newrelic_java_agent

RUN mkdir /mnt/deployer
ADD . /mnt/deployer
WORKDIR /mnt/deployer

RUN bundle install --clean --force

# CMD [ "ruby", "--version"]
# CMD [ "python", "--version"]
# CMD [ "rake"]

CMD [ "ruby", "main.rb"]
