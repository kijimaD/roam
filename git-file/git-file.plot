set terminal png
set output "./public/git-file.png"
set datafile separator ","

set xdata time
set format x "%Y/%m/%d"
set timefmt "%Y/%m/%d"
set xtics rotate

plot "./git-file/git-file.dat" using 1:2 with lines linewidth 1