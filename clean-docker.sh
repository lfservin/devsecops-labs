echo  "Stopping all the containers"
docker stop $(docker ps -a -q) > /dev/null 2>&1
echo  "Removing all the containers"
docker rm $(docker ps -a -q) > /dev/null 2>&1
echo  "Removing stale images"
docker rmi $(docker images -f dangling=true -q) > /dev/null 2>&1