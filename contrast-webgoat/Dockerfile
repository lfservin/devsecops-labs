FROM anapsix/alpine-java:jdk8
ENV APP /
RUN apk update && apk add ca-certificates && update-ca-certificates && apk add openssl
RUN apk update; apk add curl
RUN wget https://github.com/WebGoat/WebGoat/releases/download/7.1/webgoat-container-7.1-exec.jar
RUN curl -X GET https://ce.contrastsecurity.com/Contrast/api/ng/4a2fcdee-e422-4381-a66a-bdc924452c7e/agents/default/JAVA -H 'Authorization: dmlzaG51LnByYXNhZEB3ZTQ1LmNvbTo5VUdKWVBVNEo5SlFTTERJ' -H 'API-Key: rOk0Xh1ulgB3ZEwgLw6y8KmT4U83c7pb' -H 'Accept: application/json' -OJ
WORKDIR $APP
EXPOSE 8080
CMD ["java","-javaagent:contrast.jar","-Dcontrast.override.appname=WebGoatDocker","-Dcontrast.server=DockerServer","-jar","webgoat-container-7.1-exec.jar"]