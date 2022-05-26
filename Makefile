GIT_TAG:=$(shell git rev-parse --short HEAD)
PULL_TAG:=master

STAGING_URL_BASE:=ghcr.io/kijimad/roam_staging
STAGING_URL_PUSH:=$(STAGING_URL_BASE):$(GIT_TAG)
STAGING_URL_PULL:=$(STAGING_URL_BASE):$(PULL_TAG)

staging:
	docker build --target staging -t registry.heroku.com/roam-staging/web -t $(STAGING_URL_PUSH) -t $(STAGING_URL_PULL) --cache-from $(STAGING_URL_PULL) --build-arg BUILDKIT_INLINE_CACHE=1 . && \
	docker push registry.heroku.com/roam-staging/web && \
	docker push $(STAGING_URL_PUSH) && \
	docker push $(STAGING_URL_PULL) && \
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
