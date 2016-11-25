FROM ubuntu:16.04
MAINTAINER datapunt.ois@amsterdam.nl
RUN apt-get update \
    && apt-get install -y wget postgresql-client-common postgresql-client-9.5 unzip gdal-bin python3-setuptools \
    netcat python3-requests curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && mkdir /data \
    && mkdir /app \
    && mkdir /src \
    && mkdir /dump \
    && easy_install3 pip \
    && apt-get -y remove libpq5 \
    && apt -y autoremove \
    && apt-get -y update \
    && apt-get -y install libpq-dev


COPY app /app
COPY src /src
WORKDIR /src
RUN pip3.5 install --no-cache-dir -r requirements.txt \
    && chmod -R 755 /app/*.sh

ENV PGCLIENTENCODING='UTF-8'
