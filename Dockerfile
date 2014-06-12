FROM ubuntu:latest
MAINTAINER John Fink <john.fink@gmail.com>
RUN echo "deb http://archive.ubuntu.com/ubuntu precise universe" >> /etc/apt/sources.list
RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install python git pandoc
ADD ./start.sh /start.sh
RUN mkdir /article/
ADD ./c4l-docker-article.md /article/c4l-docker-article.md
EXPOSE 8888
CMD ["/bin/bash", "/start.sh"]
