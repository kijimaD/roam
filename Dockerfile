FROM ubuntu:latest
FROM ruby:3.1

RUN apt-get update
RUN apt-get install git sqlite3 emacs -y

WORKDIR /roam

COPY Gemfile Gemfile.lock ./
COPY .git/ ./.git/
RUN bundle install

CMD /bin/bash

# sudo docker-compose run roam
# ruby file-count/ls.rb
