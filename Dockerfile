FROM ubuntu:latest
MAINTAINER John Fink <john.fink@gmail.com>
RUN apt-get update # Tue May 20 16:36:08 EDT 2014
RUN apt-get -y upgrade
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install python git
ADD ./start.sh /start.sh
RUN mkdir /article/
ADD ./c4l-docker-article.html /article/index.html
EXPOSE 8888
CMD ["/bin/bash", "/start.sh"]
