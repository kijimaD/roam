FROM ubuntu:latest
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update
RUN apt-get install git sqlite3 emacs -y

WORKDIR /roam
COPY .git/ ./.git/

FROM ruby:3.1
COPY Gemfile Gemfile.lock ./
RUN bundle install

FROM python:3
COPY requirements.txt ./
RUN pip install -r requirements.txt

CMD /bin/bash

# sudo docker-compose run roam
