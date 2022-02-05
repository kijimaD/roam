FROM amazonlinux:2 AS build
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
        zlib-devel \
        sqlite-devel \
        sqlite3 \
        emacs \
        python3 \
        gnuplot

RUN git clone git://github.com/rbenv/ruby-build.git /usr/local/plugins/ruby-build && \
    /usr/local/plugins/ruby-build/install.sh
RUN ruby-build 2.7.5 /usr/local/
RUN gem update --system

WORKDIR /roam

# COPY --from=ruby /usr/local /usr/local
COPY Gemfile* ./
RUN bundle install

COPY requirements.txt ./
RUN pip3 install -r requirements.txt

COPY .git/ ./.git/
COPY . /roam

CMD /bin/bash
# sudo docker-compose run roam

# development ================

FROM node:17 AS node

COPY package.json package-lock.json ./
RUN npm install

FROM build AS dev

RUN yum -y install g++
COPY --from=node /usr/local/bin/ /usr/local/bin/
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules

RUN sh dockle-installer.sh
