.DEFAULT_GOAL := help

# build tasks ================

greeting := holla
greetings := ciao mhoro talofa

$(greeting):
	echo "greeting"

.PHONY: update-index
update-index: ## indexページを更新する
	emacs --batch -l ./publish.el --funcall kd/update-index-table

.PHONY: org2html
org2html: ## org projectをhtmlに一括変換する
	emacs --batch -l ./publish.el --funcall kd/publish

.PHONY: node-graph
node-graph: ## ファイルの関係性グラフを描画する
	emacs --batch -l ./publish.el --funcall generate-org-roam-db
	pip3 install -r requirements.txt
	python3 node_graph/build_graph.py > public/js/graph.json

.PHONY: pmd-graph
pmd-graph: ## ポモドーロの記録ファイルを公開ディレクトリに移す
	cp pmd.csv public/js/

.PHONY: file-graph
file-graph: ## ファイル数の統計情報をグラフ化する
	ruby ./git-file/git-file.rb > ./git-file/git-file.dat
	gnuplot ./git-file/git-file.plot

.PHONY: line-graph
line-graph: ## 行数の統計情報をグラフ化する
	ruby ./git-line/git-line.rb > ./git-line/git-line.dat
	gnuplot ./git-line/git-line.plot

.PHONY: gen-file-table
gen-file-table: ## ファイルの情報を書き込む
	ruby ./file-count/table.rb >> ./index.org

# development ================

.PHONY: lint-run
lint-run: ## lintを実行する
	export COMPOSE_DOCKER_CLI_BUILD=1 && docker-compose run lint make textlint
	export COMPOSE_DOCKER_CLI_BUILD=1 && docker-compose run lint make dockle
	make hadolint

.PHONY: textlint
textlint:
	docker run -v $(PWD):/work -w /work --rm ghcr.io/kijimad/roam_textlint textlint -c ./.textlintrc *.org

.PHONY: hadolint
hadolint:
	docker run --rm -i hadolint/hadolint < Dockerfile

.PHONY: dockle
dockle:
	dockle ghcr.io/kijimad/roam:master

.PHONY: server
server: ## webサーバを起動する(Python2)
	cd ./public; python -m SimpleHTTPServer 8888

.PHONY: server3
server3: ## webサーバを起動する(Python3)
	cd ./public; python3 -m http.server 8000

.PHONY: prune
prune: ## 不要なファイルを消す
	sh ./tasks/prune.sh

.PHONY: user
user: ## ファイルの権限をすべてユーザ権限にする
	sudo chown -R $USER:$USER .

.PHONY: help
help: ## ヘルプを表示する
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
