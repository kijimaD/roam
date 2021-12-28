server:
	cd ./public; python -m SimpleHTTPServer 8000
update-index:
	emacs --batch -l ./publish.el --funcall kd/update-index-table
build:
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
count-table:
	ruby file-count.rb >> ./index.org
lint:
	npx textlint *.org
dev:
	make build
	make roam-graph
	make lint
