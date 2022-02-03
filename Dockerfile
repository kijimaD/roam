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