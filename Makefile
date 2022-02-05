build:
	export COMPOSE_DOCKER_CLI_BUILD=1
	docker-compose pull build && docker-compose run build sh deploy.sh
build-dev:
	export COMPOSE_DOCKER_CLI_BUILD=1
	docker-compose build dev && docker-compose run dev sh deploy.sh

# build tasks ================

update-index:
	emacs --batch -l ./publish.el --funcall kd/update-index-table
org2html:
	emacs --batch -l ./publish.el --funcall kd/publish
node-graph:
	emacs --batch -l ./publish.el --funcall generate-org-roam-db
	pip3 install -r requirements.txt
	python3 node_graph/build_graph.py > public/js/graph.json
file-graph:
	ruby ./git-file/git-file.rb > ./git-file/git-file.dat
	gnuplot ./git-file/git-file.plot
line-graph:
	ruby ./git-line/git-line.rb > ./git-line/git-line.dat
	gnuplot ./git-line/git-line.plot
gen-file-table:
	ruby ./file-count/table.rb >> ./index.org

# development ================

lint:
	npx textlint *.org
server:
	cd ./public; python -m SimpleHTTPServer 8888
refresh:
	git clean -xdn
	git clean -xdf
user:
	sudo chown -R $USER:$USER .
push-image:
	sh push.sh
