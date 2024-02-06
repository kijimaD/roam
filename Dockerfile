# ruby ================

FROM amazonlinux:2 AS ruby
RUN yum -y update && \
    yum -y install \
        software-properties-common \
        yum-utils \
        epel-release \
        sudo \
        which \
        bzip2 \
        wget \
        tar \
        git \
        gcc \
        gcc-c++ \
        make \
        openssl-devel \
        openssh-server \
        readline-devel \
        zlib-devel

RUN git clone https://github.com/rbenv/ruby-build.git /usr/local/plugins/ruby-build && \
    /usr/local/plugins/ruby-build/install.sh
RUN ruby-build 2.7.5 /usr/local/
RUN gem update --system

# build ================

FROM amazonlinux:2 AS build

# MEMO: localeを日本語にしないと、日本語ファイルが含まれるときにsqlite出力が失敗する
ENV LANG ja_JP.UTF-8
ENV LC_ALL ja_JP.UTF-8
ENV TZ Asia/Tokyo

RUN yum -y update && \
    yum -y install \
        make \
        gcc \
        git \
        sqlite-devel \
        sqlite3 \
        emacs \
        python3 \
        gnuplot \
        glibc-langpack-ja

COPY --from=ghcr.io/kijimad/roam_ruby:master /usr/local /usr/local

WORKDIR /roam

COPY Gemfile* ./
RUN gem install bundler && bundle install

COPY requirements.txt ./
RUN pip3 install -r requirements.txt

COPY publish.el ox-slimhtml.el ./
RUN emacs --batch -l ./publish.el

COPY .git/ ./.git/
COPY . /roam

RUN sh deploy.sh

CMD /bin/sh

# Go builder ================
FROM golang:1.20-buster AS gobuild

WORKDIR /work/weight
COPY . /work
RUN go install github.com/kijimaD/wei@main
RUN wei build

# release ================
# GitHub Pages(production)
FROM amazonlinux:2 as release

COPY --from=build /roam/public /roam/public
COPY --from=build /roam/images /roam/public/images

CMD /bin/sh

# Heroku(staging)
FROM amazonlinux:2 as staging

COPY --from=build /roam/public /roam/public

CMD cd /roam/public && python -m SimpleHTTPServer $PORT

# textlint ================

FROM node:17 AS textlint

WORKDIR /roam

COPY package.json ./
RUN npm install

CMD /bin/bash

# ci ================

FROM build AS ci

RUN yum -y update && \
    yum -y install \
        make

COPY --from=node /usr/local/bin/ /usr/local/bin/
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=node /roam/node_modules /roam/node_modules

WORKDIR /roam

COPY dockle-installer.sh ./
RUN sh dockle-installer.sh

CMD /bin/bash

# pandoc ================

FROM ubuntu AS pandoc
ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && \
    apt install \
    -y \
    pandoc \
    texlive-lang-japanese \
    texlive-latex-extra \
    texlive-luatex \
    librsvg2-bin \
    pdftk

# MEMO: localeを日本にしないとファイルまわりで失敗する
ENV LANG ja_JP.UTF-8
ENV LC_ALL ja_JP.UTF-8
ENV TZ Asia/Tokyo
