set terminal postscript eps size 5.5,2.62 enhanced color font 'Helvetica,22'
#set output 'worm-integration-time.eps'
set output '| epstopdf --filter --outfile=worm-integration-time.pdf'
set border linewidth 2
set style line 1 linecolor rgb '#9ACD32' linetype 1 linewidth 5
set style line 2 linecolor rgb '#DAA520' linetype 1 linewidth 5
set style line 3 linecolor rgb '#9ACD32' linetype 4 linewidth 3
set style line 4 linecolor rgb '#DAA520' linetype 4 linewidth 3
set log x
unset key
set xlabel "Light dose {/Symbol W} in J/(cm^2 stack)"
set ylabel "number of cells after 2h"

set style rect fc lt -1 fs solid 0.15 noborder

# label the curves
set label "{/Symbol t}=500 ms exposure time" at .11,40 textcolor linestyle 1 left front
set label "{/Symbol t}=100 ms" at .0017,40 textcolor linestyle 2 left front
set label "exposure time" at .0017,34 textcolor linestyle 2 left front


# indicate green inflection point
set arrow from 3.65e-2,graph(0,0) to 3.65e-2,graph(1,1) nohead linestyle 3
set arrow from 4.27e-2,graph(0,0) to 4.27e-2,graph(1,1) nohead linestyle 1
set arrow from 4.88e-2,graph(0,0) to 4.88e-2,graph(1,1) nohead linestyle 3
set object rect from 3.65e-2,graph(0,0) to 4.88e-2,graph(1,1)
set label "0.043" at .053,55 textcolor linestyle 1 left front


#indicate orange inflection point
set arrow from 1.57e-2,graph(0,0) to 1.57e-2,graph(1,1) nohead linestyle 4
set arrow from 1.85e-2,graph(0,0) to 1.85e-2,graph(1,1) nohead linestyle 2
set arrow from 2.13e-2,graph(0,0) to 2.13e-2,graph(1,1) nohead linestyle 4
set object rect from 1.57e-2,graph(0,0) to 2.13e-2,graph(1,1)
set label "0.019" at .015,8 right textcolor linestyle 2 front

set xrange [9e-4:2]
plot "green.dat" u 1:2 w p linestyle 1 pointsize 1.5, "green_fit.dat" u 1:2 w l linestyle 1, "orange.dat" u 1:2 w p linestyle 2 pointsize 1.5, "orange_fit.dat" u 1:2 w l linestyle 2

