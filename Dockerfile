FROM node:17 AS node

COPY package.json package-lock.json ./
RUN npm install

FROM ruby:3.1 AS build
RUN apt-get update && \
    apt-get install -y \
    git \
    make \
    sqlite3 \
    emacs \
    python3 \
    python3-pip \
    gnuplot

# COPY --from=ruby /usr/local /usr/local

WORKDIR /roam

COPY Gemfile* ./
RUN bundle install

COPY requirements.txt ./
RUN pip3 install -r requirements.txt

COPY .git/ ./.git/
COPY . /roam

CMD /bin/bash
