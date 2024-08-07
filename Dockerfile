# builder ================
FROM ubuntu:24.10 AS builder

WORKDIR /roam

RUN apt -y update && \
    apt -y install \
    make \
    which \
    wget \
    gcc \
    git \
    sqlite3 \
    libsqlite3-dev \
    python3 \
    python3-pip \
    ruby \
    ruby-dev \
    gnuplot \
    emacs \
    language-pack-ja \
    fonts-ipafont # なぜかどのフォント指定しても、TakaoPGothicとして表示・エクスポートされている

RUN apt -y install \
    xvfb \
    libnss3 \
    libxss1 \
    xdg-utils \
    libsecret-1-0
RUN wget https://github.com/jgraph/drawio-desktop/releases/download/v24.7.5/drawio-amd64-24.7.5.deb && dpkg -i drawio-amd64-24.7.5.deb && rm drawio-amd64-24.7.5.deb

COPY Gemfile* ./
RUN gem install bundler && bundle install

COPY requirements.txt ./
RUN pip3 install -r requirements.txt --break-system-packages

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
FROM ubuntu:24.10 AS release

COPY --from=build /roam/public /roam/public
COPY --from=build /roam/images /roam/public/images
COPY --from=build /roam/pdfs /roam/public/pdfs

CMD /bin/sh

# Heroku(staging)
FROM ubuntu:24.10 AS staging

COPY --from=build /roam/public /roam/public

CMD cd /roam/public && python -m SimpleHTTPServer $PORT

# textlint ================
FROM node:22 AS textlint

WORKDIR /work

COPY package.json ./
COPY yarn.lock ./
RUN --mount=type=cache,target=/root/.npm \
    npm install

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
FROM ubuntu:24.10 AS pandoc
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
