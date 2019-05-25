sudo apt-get -y install python-pip python-venv git
virtualenv venv
source venv/bin/activate
pip install -r requirements.txt
git clone https://github.com/we45/CTF2.git