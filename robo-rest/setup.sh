sudo apt-get -y install curl python3-pip python3-venv
curl -sSL https://get.docker.com/ | sh
virtualenv venv -p python3
source venv/bin/activate
pip install -r requirements.txt