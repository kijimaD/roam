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

# builder ================

FROM amazonlinux:2 AS builder

RUN yum -y update && \
    yum -y install \
        make \
        which \
        gcc \
        git \
        sqlite-devel \
        sqlite3 \
        emacs \
        python3 \
        gnuplot \
        glibc-langpack-ja \
        https://github.com/jgraph/drawio-desktop/releases/download/v24.1.0/drawio-x86_64-24.1.0.rpm \
        xorg-x11-server-Xvfb \
        ipa-pgothic-fonts # なぜかどのフォント指定しても、TakaoPGothicとして表示・エクスポートされている

COPY --from=ghcr.io/kijimad/roam_ruby:master /usr/local /usr/local

WORKDIR /roam

COPY Gemfile* ./
RUN gem install bundler && bundle install

COPY requirements.txt ./
RUN pip3 install -r requirements.txt

CMD /bin/sh

# build ================
FROM builder AS build

# MEMO: localeを日本にしないと、日本語ファイルが含まれるときにsqlite出力が失敗する
ENV LANG ja_JP.UTF-8
ENV LC_ALL ja_JP.UTF-8
ENV TZ Asia/Tokyo

WORKDIR /roam

COPY publish.el ox-slimhtml.el ./
COPY .git/ ./.git/
COPY . /roam

RUN ./scripts/deploy.sh

CMD /bin/sh

# release ================
# GitHub Pages(production)
FROM amazonlinux:2 as release

COPY --from=build /roam/public /roam/public
COPY --from=build /roam/images /roam/public/images
COPY --from=build /roam/pdfs /roam/public/pdfs

CMD /bin/sh

# Heroku(staging)
FROM amazonlinux:2 as staging

COPY --from=build /roam/public /roam/public

CMD cd /roam/public && python -m SimpleHTTPServer $PORT

# textlint ================

FROM node:22 AS textlint

WORKDIR /work

COPY package.json ./
COPY yarn.lock ./
RUN npm install

COPY .textlintrc ./
COPY prh.yml ./

# ci ================

FROM build AS ci

RUN yum -y update && \
    yum -y install \
        make

COPY --from=node /usr/local/bin/ /usr/local/bin/
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=node /roam/node_modules /roam/node_modules

WORKDIR /roam

COPY ./scripts/dockle-installer.sh ./dockle-installer.sh
RUN sh dockle-installer.sh

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
    pdftk \
    language-pack-ja
