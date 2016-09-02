FROM ubuntu
MAINTAINER datapunt.ois@amsterdam.nl

RUN apt-get update \
    && apt-get install -y wget postgresql-client-common postgresql-client-9.5 unzip gdal-bin netcat \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && mkdir /data \
    && mkdir /app \
    && mkdir /dump

ENV PGCLIENTENCODING='UTF-8'

COPY dump /dump
COPY data /data
COPY app /app
RUN chmod -R 755 /app/*.sh
