FROM amazonlinux:2 AS ruby
RUN yum -y update && \
    yum -y install \
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

RUN git clone git://github.com/rbenv/ruby-build.git /usr/local/plugins/ruby-build && \
    /usr/local/plugins/ruby-build/install.sh
RUN ruby-build 2.7.5 /usr/local/
RUN gem update --system

FROM amazonlinux:2 AS build

RUN yum -y update && \
    yum -y install \
        make \
        gcc \
        sqlite-devel \
        sqlite3 \
        emacs \
        python3 \
        gnuplot

COPY --from=ruby /usr/local /usr/local

WORKDIR /roam

COPY Gemfile* ./
RUN gem install bundler && bundle install

COPY requirements.txt ./
RUN pip3 install -r requirements.txt

COPY .git/ ./.git/
COPY . /roam

CMD /bin/bash

# development ================

FROM node:17 AS node

COPY package.json package-lock.json ./
RUN npm install

CMD /bin/bash

FROM build AS dev

COPY --from=node /usr/local/bin/ /usr/local/bin/
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules

RUN sh dockle-installer.sh

CMD /bin/bash