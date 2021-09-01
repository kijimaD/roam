build:
	emacs --batch -l ./publish1.el --funcall kd/publish
roam-graph:
	emacs --batch -l ./publish1.el --funcall org-roam-graph-save
counter-graph:
	python git-counter.py
pip:
	pip install -r requirements.txt
