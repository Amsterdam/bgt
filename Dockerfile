FROM python:3.5
MAINTAINER datapunt.ois@amsterdam.nl

RUN apt-get update \
    && apt-get install -y wget postgresql-client-9.4 unzip gdal-bin netcat python3-requests curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && mkdir /data \
    && mkdir /app \
    && mkdir /src \
    && mkdir /dump

ENV PGCLIENTENCODING='UTF-8'

COPY app /app
COPY src /src
WORKDIR /src
RUN pip3 install --no-cache-dir -r requirements.txt

RUN chmod -R 755 /app/*.sh
