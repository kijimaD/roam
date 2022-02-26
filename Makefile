BUILD_URL=ghcr.io/kijimad/roam_build:master
RELEASE_URL=ghcr.io/kijimad/roam_release:master
STAGING_URL=ghcr.io/kijimad/roam_staging:master

build:
	export DOCKER_BUILDKIT=1 && \
	export COMPOSE_DOCKER_CLI_BUILD=1 && \
	docker pull $(BUILD_URL) && \
	docker build --target build -t $(BUILD_URL) --cache-from $(BUILD_URL) . && \
	docker push $(BUILD_URL) && \
	docker pull $(RELEASE_URL) && \
	docker build --target build -t $(RELEASE_URL) --cache-from $(RELEASE_URL) . && \
	docker push $(RELEASE_URL)
release:
	docker pull $(RELEASE_URL) && \
	docker run --rm -v $(PWD):/roam $(RELEASE_URL)

staging:
	docker pull $(STAGING_URL) && \
	docker build --target staging -t registry.heroku.com/roam-staging/web -t $(STAGING_URL) --cache-from ${STAGING_URL} . && \
	docker push registry.heroku.com/roam-staging/web && \
	docker push $(STAGING_URL) && \
	heroku container:release web

build-dev:
	export DOCKER_BUILDKIT=1 && \
	export COMPOSE_DOCKER_CLI_BUILD=1 && \
	docker build --target release -t test --cache-from $(RELEASE_URL) . && \
	docker run --rm -v $(pwd):/roam test
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
