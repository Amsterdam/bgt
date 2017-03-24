FROM python:3.6
MAINTAINER datapunt.ois@amsterdam.nl

ENV PYTHONUNBUFFERED 1

RUN apt-get update \
	&& apt-get install -y \
        libpq-dev \
		postgresql-client \
		netcat \
		gdal-bin \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir /data /app /src /dump

COPY app /app
COPY src /src
WORKDIR /src
RUN pip3 install --no-cache-dir -r requirements.txt \
    && chmod -R 755 /app/*.sh

ENV PGCLIENTENCODING='UTF-8'
