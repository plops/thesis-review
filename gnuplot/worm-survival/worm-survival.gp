set terminal postscript eps size 5.5,2.62 enhanced color font 'Helvetica,22'
#set output 'worm-survival.eps'
set output '| epstopdf --filter --outfile=worm-survival.pdf'
set border linewidth 2
set style line 1 linecolor rgb '#9ACD32' linetype 1 linewidth 5
set style line 2 linecolor rgb '#1E90FF' linetype 1 linewidth 5
set style line 3 linecolor rgb '#9ACD32' linetype 4 linewidth 3
set style line 4 linecolor rgb '#1E90FF' linetype 4 linewidth 3
set log x
unset key
set xlabel "Light dose in J/(cm^2 stack)"
set ylabel "number of cells after 2h"

set style rect fc lt -1 fs solid 0.15 noborder

# label the curves
set label "wide-field microscope" at .12,40 textcolor linestyle 1 left front
set label "spinning-disk" at .0017,25 textcolor linestyle 2 left front
set label "microscope" at .0017,19 textcolor linestyle 2 left front

# indicate green inflection point
set arrow from 3.65e-2,graph(0,0) to 3.65e-2,graph(1,1) nohead linestyle 3
set arrow from 4.27e-2,graph(0,0) to 4.27e-2,graph(1,1) nohead linestyle 1
set arrow from 4.88e-2,graph(0,0) to 4.88e-2,graph(1,1) nohead linestyle 3
set object rect from 3.65e-2,graph(0,0) to 4.88e-2,graph(1,1)
set label "0.043" at .053,20 textcolor linestyle 1 left front


#indicate blue inflection point
set arrow from 8.58e-3,graph(0,0) to 8.58e-3,graph(1,1) nohead linestyle 4
set arrow from 9.58e-3,graph(0,0) to 9.58e-3,graph(1,1) nohead linestyle 2
set arrow from 1.06e-2,graph(0,0) to 1.06e-2,graph(1,1) nohead linestyle 4
set object rect from 8.58e-3,graph(0,0) to 1.06e-2,graph(1,1)
set label "0.0096" at .008,8 right textcolor linestyle 2 front

set xrange [9e-4:2]
plot "green.dat" u 1:2 w p linestyle 1 pointsize 1.5, "green_fit.dat" u 1:2 w l linestyle 1, "blue.dat" u 1:2 w p linestyle 2 pointsize 1.5, "blue_fit.dat" u 1:2 w l linestyle 2

