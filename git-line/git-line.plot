set terminal pngcairo
set output "./public/git-line.png"
set datafile separator ","

set xdata time
set format x "%Y-%m-%d"
set timefmt "%Y-%m-%d"
set xtics rotate

plot "./git-line/git-line.dat" using 1:2 with impulses