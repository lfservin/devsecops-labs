sudo apt-get -y install curl nodejs npm git
npm install npm@6 -g
curl -sSL https://get.docker.com/ | sh
git clone https://github.com/we45/Cut-The-Funds-NodeJS.git
cd Cut-The-Funds-NodeJS
npm install
docker pull owasp/dependency-track
docker volume create --name dependency-track
npm install -g @cyclonedx/bom
