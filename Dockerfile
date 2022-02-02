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
        zlib-devel \
        sqlite-devel \
        sqlite3 \
        emacs

RUN git clone git://github.com/rbenv/ruby-build.git /usr/local/plugins/ruby-build && \
    /usr/local/plugins/ruby-build/install.sh
RUN ruby-build 2.7.5 /usr/local/

WORKDIR /roam

COPY Gemfile Gemfile.lock ./
COPY .git/ ./.git/

# COPY --from=ruby /usr/local /usr/local
RUN bundle install

CMD /bin/bash

# sudo docker-compose run roam
