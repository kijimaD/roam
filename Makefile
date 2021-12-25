server:
	cd ./public; python -m SimpleHTTPServer 8000
update-index:
	emacs --batch -l ./publish1.el --funcall kd/update-index-table
build:
	emacs --batch -l ./publish1.el --funcall kd/publish
roam-graph:
	emacs --batch -l ./publish1.el --funcall org-roam-graph-save
node-graph:
	pip3 install -r requirements.txt
	python3 node_graph/build_graph.py > public/js/graph.json
file-graph:
	ruby git-file.rb > git-file.dat
	gnuplot git-file.plot
line-graph:
	ruby git-line.rb > git-line.dat
	gnuplot git-line.plot
count-table:
	ruby file-count.rb >> ./index.org
lint:
	npx textlint *.org
dev:
	make build
	make roam-graph
	make lint
