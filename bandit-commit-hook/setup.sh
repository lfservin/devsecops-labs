sudo apt-get -y install python3-pip python3-venv git
virtualenv venv
source venv/bin/activate
git clone https://github.com/we45/Vulnerable-Flask-App.git
cd Vulnerable-Flask-App
cp bandit-commit-hook.sh .git/hooks/post-commit
chmod +x .git/hooks/post-commit