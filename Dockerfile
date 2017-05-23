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

COPY ./ /bgt
WORKDIR /bgt
RUN pip3 install -e . \
    && chmod -R 755 app/*.sh

ENV PGCLIENTENCODING='UTF-8'
