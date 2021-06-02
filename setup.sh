#is Amazon Linux 2 - only tested on this AMI?
continue="n"

cat /etc/system-release | grep "Amazon Linux release 2" > /dev/null

if [ "$?" -ne "0" ]
then
  echo "Only tested on Amazon Linux 2... Do you want to continue (y/n)? "
  read continue
  continue=${continue^^}

  if [ "$continue" == "N" ]
  then
    echo "OK, exiting..."
    exit 0
  fi
else
  #update vm
  sudo yum -y update
fi

#set env vars
source ./env_vars.sh

#env vars populated?
if [ "$DATADOG_APP_KEY" == "" ] || [ "$DATADOG_API_KEY" == "" ] || \
   [ "$SNYK_TOKEN" == "" ]
then
  echo "Populate SNYK_TOKEN and SNYK_TOKEN and SNYK_TOKEN to use this...."
  exit -1
fi

#install agent
DD_AGENT_MAJOR_VERSION=7 DD_API_KEY=${DATADOG_API_KEY} DD_SITE="datadoghq.com" bash -c "$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script.sh)"

# install jdk 1.8
sudo amazon-linux-extras enable corretto8
sudo yum -y install java-1.8.0-amazon-corretto-devel

# install maven
curl -O https://downloads.apache.org/maven/maven-3/3.8.1/binaries/apache-maven-3.8.1-bin.tar.gz
tar zxvpf apache-maven-3.8.1-bin.tar.gz

# download java tracer
wget -O dd-java-agent.jar https://dtdg.co/latest-java-tracer

mvn install

# install npm
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.32.0/install.sh | bash
. ~/.nvm/nvm.sh
export NVM_DIR="/home/ec2-user/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

# install snyk cli
nvm install node

# install snyk
npm install -g snyk

# install datadog-ci
npm install --save-dev @datadog/datadog-ci

# auth snyk
snyk auth $SNYK_TOKEN

# get vuln deps
snyk test --file=pom.xml --print-deps --json > deps.json

#if deps.json is empty there is an issue likely with node installv
if [ ! -s deps.json ]
then
  echo "deps.json is empty... exiting..."
  exit -1
fi

# upload deps to datadog
node_modules/.bin/datadog-ci dependencies upload deps.json --source snyk --service javagoof --release-version .01

#let's go
mvn tomcat7:run
