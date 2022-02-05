# production ================

FROM ruby:3.1 AS build
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
      git \
      make \
      sqlite3 \
      emacs \
      python3 \
      python3-pip \
      gnuplot

WORKDIR /roam

COPY Gemfile* ./
RUN bundle install

COPY requirements.txt ./
RUN pip3 install -r requirements.txt

COPY .git/ ./.git/
COPY . /roam

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

CMD /bin/bash

# development ================

FROM node:17 AS node

COPY package.json package-lock.json ./
RUN npm install

FROM build AS dev

RUN apt-get install -y --no-install-recommends g++
COPY --from=node /usr/local/bin/ /usr/local/bin/
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
