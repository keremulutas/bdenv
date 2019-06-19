FROM redis:4.0.2-alpine

COPY redis-trib.rb /usr/local/bin
COPY docker /usr/local/bin
COPY clusterize.sh /usr/local/bin

RUN apk update

RUN apk add ruby ruby-irb ruby-rdoc bash

RUN gem install redis

VOLUME /var/run/docker.sock

# CMD [ "/bin/sh" ]
