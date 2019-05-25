wget http://downloads.sourceforge.net/project/jython/jython/2.5.1/jython_installer-2.5.1.jar
JYTHON_HOME=/root/jython/
java -jar jython_installer-2.5.1.jar -s -d $JYTHON_HOME
# echo 'export JYTHON_HOME=/root/jython/bin' > ~/.bashrc
export JYTHON_HOME=/root/jython/
export PATH=$JYTHON_HOME/bin:$PATH
# Install python scripting addon
virtualenv venv
source venv/bin/activate
pip install -r requirements.txt