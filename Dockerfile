FROM ubuntu:latest
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update
RUN apt-get install git sqlite3 emacs -y

WORKDIR /roam

FROM ruby:3.1
COPY Gemfile Gemfile.lock ./
RUN bundle install

WORKDIR /roam

FROM python:3
COPY requirements.txt ./
RUN pip install -r requirements.txt

WORKDIR /roam
COPY .git/ ./.git/

CMD /bin/bash

# sudo docker-compose run roam
