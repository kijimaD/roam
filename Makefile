.DEFAULT_GOAL := help

# build tasks ================

update-index: ## indexページを更新する
	emacs --batch -l ./publish.el --funcall kd/update-index-table
org2html: ## org projectをhtmlに一括変換する
	emacs --batch -l ./publish.el --funcall kd/publish
node-graph: ## ファイルの関係性グラフを描画する
	emacs --batch -l ./publish.el --funcall generate-org-roam-db
	pip3 install -r requirements.txt
	python3 node_graph/build_graph.py > public/js/graph.json
pmd-graph: ## ポモドーロの記録ファイルを公開ディレクトリに移す
	cp pmd.csv public/js/
file-graph: ## ファイル数の統計情報をグラフ化する
	ruby ./git-file/git-file.rb > ./git-file/git-file.dat
	gnuplot ./git-file/git-file.plot
line-graph: ## 行数の統計情報をグラフ化する
	ruby ./git-line/git-line.rb > ./git-line/git-line.dat
	gnuplot ./git-line/git-line.plot
gen-file-table: ## ファイルの情報を書き込む
	ruby ./file-count/table.rb >> ./index.org

# development ================

lint-run: ## lintを実行する
	export COMPOSE_DOCKER_CLI_BUILD=1 && docker-compose run lint make textlint
	export COMPOSE_DOCKER_CLI_BUILD=1 && docker-compose run lint make dockle
	make hadolint
textlint:
	npx textlint *.org
hadolint:
	docker run --rm -i hadolint/hadolint < Dockerfile
dockle:
	dockle ghcr.io/kijimad/roam:master

server: ## webサーバを起動する(Python2)
	cd ./public; python -m SimpleHTTPServer 8888

server3: ## webサーバを起動する(Python3)
	cd ./public; python3 -m http.server 8000

refresh: ## 不要なファイルを削除する
	git clean -xdn
	git clean -xdf
user: ## ファイルの権限をすべてユーザ権限にする
	sudo chown -R $USER:$USER .

help: ## ヘルプを表示する
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
