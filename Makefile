.DEFAULT_GOAL := help

# example ================

greeting := holla
greetings := ciao mhoro talofa

$(greeting):
	echo "greeting"

# build tasks ================

.PHONY: update-index
update-index: ## indexページを更新する
	emacs --batch -l ./publish.el --funcall kd/update-index-table

.PHONY: update-dlinks
update-dlinks: ## denote linksページを更新する(ローカルで実行する用)
	emacs --batch -l ./publish.el --funcall kd/update-dlinks-table

.PHONY: org2html
org2html: ## org projectをhtmlに一括変換する
	emacs --batch -l ./publish.el --funcall generate-org-roam-db
	emacs --batch -l ./publish.el --funcall kd/publish
	cp -r ./images ./public/
	cp -r ./buseum ./public/

.PHONY: node-graph
node-graph: ## ファイルの関係性グラフを描画する
	emacs --batch -l ./publish.el --funcall generate-org-roam-db
	pip3 install -r requirements.txt --break-system-packages
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
	# 日本語のファイルがあると文字化けする対策
	git config --global core.quotepath false
	ruby ./file-count/table.rb >> ./index.org

.PHONY: export-pdfs-dev
export-pdfs-dev: ## drawio SVGたちをPDFにエクスポートする。ローカル用
	which drawio
	cd ./pdfs && ls | grep 'pdf.drawio.svg' | xargs -I {} drawio -f pdf -x {} --no-sandbox
	cp -r ./pdfs ./public/

# development ================

.PHONY: lint-run
lint-run: ## lintを実行する
	export COMPOSE_DOCKER_CLI_BUILD=1 && docker-compose run lint make textlint
	export COMPOSE_DOCKER_CLI_BUILD=1 && docker-compose run lint make dockle
	make hadolint

.PHONY: textlint
textlint:
	docker build . --target textlint -t roam_textlint
	docker run -v $(PWD):/work/roam -w /work --rm roam_textlint bash -c "npx textlint --fix -c ./.textlintrc ./roam/*.org"

.PHONY: fix
fix:
	docker run -v $(PWD):/work -w /work --rm ghcr.io/kijimad/roam_textlint npx textlint --fix -c ./.textlintrc *.org

.PHONY: hadolint
hadolint:
	docker run --rm -i hadolint/hadolint < Dockerfile

.PHONY: dockle
dockle:
	dockle ghcr.io/kijimad/roam:master

.PHONY: server
server: ## webサーバを起動する
	docker run -d -v "$(PWD)/public":/usr/share/nginx/html -w /usr/share/nginx/html -p 8005:80 --name roam-server --restart always docker.io/nginx:1.27

.PHONY: watch
watch: ## 自動更新する
	./scripts/watch.sh

.PHONY: prune
prune: ## 不要なファイルを消す
	./scripts/prune.sh

.PHONY: user
user: ## ファイルの権限をすべてユーザ権限にする
	sudo chown -R $USER:$USER .

.PHONY: help
help: ## ヘルプを表示する
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
