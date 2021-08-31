build:
	emacs --batch -l ./publish1.el --funcall kd/publish
graph:
	emacs --batch -l ./publish1.el --funcall org-roam-graph-save
