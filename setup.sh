# install maven
sudo wget https://repos.fedorapeople.org/repos/dchen/apache-maven/epel-apache-maven.repo -O /etc/yum.repos.d/epel-apache-maven.repo
sudo sed -i s/\$releasever/6/g /etc/yum.repos.d/epel-apache-maven.repo
sudo yum -y install -y apache-maven

# install jdk 1.8
sudo amazon-linux-extras enable corretto8
sudo yum -y install java-1.8.0-amazon-corretto-devel

# install npm
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.32.0/install.sh | bash
. ~/.nvm/nvm.sh

# install snyk cli
nvm install node

# install snyk
npm install -g snyk

# install datadog-ci
npm install --save-dev @datadog/datadog-ci

# auth snyk
snyk auth $SNYK_TOKEN

# get vuln deps
snyk test --print-deps --json > deps.json

# upload deps to datadog
node_modules/.bin/datadog-ci dependencies upload deps.json --source snyk --service javagoof --release-version .01

# download java tracer
wget -O dd-java-agent.jar https://dtdg.co/latest-java-tracer
