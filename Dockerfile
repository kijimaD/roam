# builder ================
FROM ubuntu:25.04 AS builder

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
    # feed作成用
    libxml2-dev

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

# この環境変数でURLや相対パスを、本番用(GitHub Pages)かローカル用かを切り替える
ENV PRODUCTION true

WORKDIR /roam

COPY publish.el ox-slimhtml.el ./
COPY .git/ ./.git/
COPY . /roam

RUN ./scripts/deploy.sh

CMD /bin/sh

# release ================
# GitHub Pages(production)
FROM gcr.io/distroless/static-debian11 AS release

COPY --from=build /roam/public /roam/public
COPY --from=build /roam/images /roam/public/images
COPY --from=build /roam/pdfs /roam/public/pdfs
COPY --from=builder /usr/bin/sleep /usr/bin/sleep

# Heroku(staging)
FROM ubuntu:25.04 AS staging

COPY --from=build /roam/public /roam/public

CMD cd /roam/public && python -m SimpleHTTPServer $PORT

# textlint ================
FROM node:24 AS textlint

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
FROM ubuntu:25.04 AS pandoc
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
