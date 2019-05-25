sudo apt-get -y install python3-pip python3-venv git
virtualenv venv -p python3
source venv/bin/activate
pip install -r requirements.txt
git clone https://github.com/we45/Vulnerable-Flask-App.git
cd Vulnerable-Flask-App