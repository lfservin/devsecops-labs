sudo apt-get -y install wget git python3-pip python3-venv
wget -N https://github.com/zaproxy/zaproxy/releases/download/2.7.0/ZAP_2.7.0_Linux.tar.gz
tar -zxvf ZAP_2.7.0_Linux.tar.gz
wget https://github.com/zaproxy/zap-extensions/releases/download/2.7/exportreport-alpha-5.zap -P ZAP_2.7.0/plugin
export PATH_ZAP_SH=$pwd/ZAP_2.7.0/zap.sh
export ZAP_PORT=8090
git clone https://github.com/we45/ZAP-Mini-Workshop.git
virtualenv venv -p python3
source venv/bin/activate
pip install -r requirements.txt