set terminal postscript eps size 5.5,2.2 enhanced color font 'Helvetica,22'
set output '| epstopdf --filter --outfile=pois.pdf'
set border linewidth 2
#set log x
#set log y
set xrange [-1:40]
#set yrange [0:.3]
unset key
#set key bottom right
set xlabel "number of detected photons k"
set ylabel "probability of detection"

set style line 1 linecolor rgb '#9ACD32' linetype 1 linewidth 22
set style line 2 linecolor rgb '#1E90FF' linetype 1 linewidth 22
set style line 3 linecolor rgb '#A04931' linetype 1 linewidth 22
set style line 4 linecolor rgb '#5009A1' linetype 1 linewidth 7
set style line 5 linecolor rgb '#E00921' linetype 1 linewidth 7


set style line 11 linecolor rgb '#9ACD32' linetype 2 linewidth 7
set style line 12 linecolor rgb '#1E90FF' linetype 2 linewidth 7
set style line 13 linecolor rgb '#A04931' linetype 2 linewidth 7
set style line 14 linecolor rgb '#5009A1' linetype 2 linewidth 7
set style line 15 linecolor rgb '#E00921' linetype 2 linewidth 7

set style line 21 linecolor rgb '#9ACD32' linetype 1 linewidth 12
set style line 22 linecolor rgb '#1E90FF' linetype 1 linewidth 12
set style line 23 linecolor rgb '#A04931' linetype 1 linewidth 12
set style line 24 linecolor rgb '#5009A1' linetype 1 linewidth 3
set style line 25 linecolor rgb '#E00921' linetype 1 linewidth 3

set grid
#f(k,l)=l**k*exp(-l)/(k!)


set label "{/Symbol l}=0.3" at 1,.6 textcolor ls 1
set label "{/Symbol l}=3" at 4,.3 textcolor ls 2
set label "{/Symbol l}=30" at 30,.2 textcolor ls 3

plot "pois.dat" u 1:2 w imp ls 1, "pois.dat" u 1:3 w imp ls 22, "pois.dat" u 1:4 w imp ls 23