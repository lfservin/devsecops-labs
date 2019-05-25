sudo apt-get install -y openjdk-8-jdk maven wget unzip git
git clone https://github.com/hamhc/WebGoat-7.1.git
cd WebGoat-7.1/webgoat-container/
mvn install -Dmaven.test.skip=true
wget https://dl.bintray.com/jeremy-long/owasp/dependency-check-4.0.2-release.zip
unzip dependency-check-4.0.2-release.zip