GIT_TAG:=$(shell git rev-parse --short HEAD)
PULL_TAG:=master

BUILD_URL_BASE:=ghcr.io/kijimad/roam_build
BUILD_URL_PUSH:=$(BUILD_URL_BASE):$(GIT_TAG)
BUILD_URL_PULL:=$(BUILD_URL_BASE):$(PULL_TAG)

RELEASE_URL_BASE:=ghcr.io/kijimad/roam_release
RELEASE_URL_PUSH:=$(RELEASE_URL_BASE):$(GIT_TAG)
RELEASE_URL_PULL:=$(RELEASE_URL_BASE):$(PULL_TAG)

STAGING_URL_BASE:=ghcr.io/kijimad/roam_staging
STAGING_URL_PUSH:=$(STAGING_URL_BASE):$(GIT_TAG)
STAGING_URL_PULL:=$(STAGING_URL_BASE):$(PULL_TAG)

build:
	export DOCKER_BUILDKIT=1 && \
	export COMPOSE_DOCKER_CLI_BUILD=1 && \
	docker pull $(BUILD_URL_PULL) && \
	docker build --target build -t $(BUILD_URL_PUSH) --cache-from $(BUILD_URL_PULL) . && \
	docker push $(BUILD_URL_PUSH) && \
	docker pull $(RELEASE_URL_PULL) && \
	docker build --target build -t $(RELEASE_URL_PUSH) --cache-from $(RELEASE_URL_PULL) . && \
	docker push $(RELEASE_URL_PUSH)
release:
	docker pull $(RELEASE_URL_PUSH) && \
	docker run --detach --name release $(RELEASE_URL_PUSH) && \
	docker cp release:/roam/public ./
staging:
	docker pull $(STAGING_URL_PULL) && \
	docker build --target staging -t registry.heroku.com/roam-staging/web -t $(STAGING_URL_PUSH) --cache-from $(STAGING_URL_PULL) . && \
	docker push registry.heroku.com/roam-staging/web && \
	docker push $(STAGING_URL_PUSH) && \
	heroku container:release web
# build tasks ================

update-index:
	emacs --batch -l ./publish.el --funcall kd/update-index-table
org2html:
	emacs --batch -l ./publish.el --funcall kd/publish
node-graph:
	emacs --batch -l ./publish.el --funcall generate-org-roam-db
	pip3 install -r requirements.txt
	python3 node_graph/build_graph.py > public/js/graph.json
pmd-graph:
	cp pmd.csv public/js/
file-graph:
	ruby ./git-file/git-file.rb > ./git-file/git-file.dat
	gnuplot ./git-file/git-file.plot
line-graph:
	ruby ./git-line/git-line.rb > ./git-line/git-line.dat
	gnuplot ./git-line/git-line.plot
gen-file-table:
	ruby ./file-count/table.rb >> ./index.org

# development ================

lint-run:
	export COMPOSE_DOCKER_CLI_BUILD=1 && docker-compose run lint make textlint
	export COMPOSE_DOCKER_CLI_BUILD=1 && docker-compose run lint make dockle
	make hadolint
textlint:
	npx textlint *.org
hadolint:
	docker run --rm -i hadolint/hadolint < Dockerfile
dockle:
	dockle ghcr.io/kijimad/roam:master

server:
	cd ./public; python -m SimpleHTTPServer 8888
refresh:
	git clean -xdn
	git clean -xdf
user:
	sudo chown -R $USER:$USER .
push-image:
	sh push.sh
