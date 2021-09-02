build:
	emacs --batch -l ./publish1.el --funcall kd/publish
roam-graph:
	emacs --batch -l ./publish1.el --funcall org-roam-graph-save
counter-graph:
	python git-counter.py
file-graph:
	ruby git-file.rb > git-file.dat
	gnuplot git-file.plot
line-graph:
	ruby git-line.rb > git-line.dat
	gnuplot git-line.plot
