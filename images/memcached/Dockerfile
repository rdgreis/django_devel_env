# Set the base image to use to Ubuntu
FROM ubuntu:12.04

MAINTAINER Rodrigo Reis <devel@rodrigoreis.com>

RUN apt-get update
RUN apt-get install -y make gcc wget libevent-dev
RUN wget http://memcached.googlecode.com/files/memcached-1.4.15.tar.gz -O /tmp/pkg.tar.gz
RUN (cd /tmp && tar zxf pkg.tar.gz && cd memcached-* && ./configure --prefix=/usr/local && make install)
RUN apt-get remove -y gcc make
RUN rm -rf /tmp/*
EXPOSE 11211
ENTRYPOINT ["/usr/local/bin/memcached"]
CMD ["-u", "root", "-m", "64"]