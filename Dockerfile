FROM ubuntu
MAINTAINER datapunt.ois@amsterdam.nl

RUN apt-get update \
    && apt-get install -y wget postgresql-client-common postgresql-client-9.5 unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && mkdir /app

ENV PGCLIENTENCODING='UTF-8'

COPY . /app
RUN chmod -R 755 /app/*.sh
