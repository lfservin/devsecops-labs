sudo apt-get -y install python3-pip python3-venv
virtualenv venv -p python3
source venv/bin/activate
pip install -r requirements.txt