FROM ubuntu:16.04
MAINTAINER datapunt.ois@amsterdam.nl

RUN apt-get update -qy
RUN apt-get install -y python3.5 python3.5-dev python3-pip python-dev python3-dev \
    postgresql libpq-dev postgresql-client postgresql-client-common sudo netcat

RUN mkdir /data /app /src /dump

COPY app /app
COPY src /src
WORKDIR /src
RUN pip3 install --no-cache-dir -r requirements.txt \
    && chmod -R 755 /app/*.sh

ENV PGCLIENTENCODING='UTF-8'

