set terminal postscript eps size 5.5,7.52 enhanced color font 'Helvetica,22'
set output '| epstopdf --filter --outfile=camera-snr.pdf'
set border linewidth 2
set xrange [.1:3000]
set log x

set yrange [0:1]
#unset key
set key bottom right
set xlabel "signal photon number"
set ylabel "relative SNR"

set style line 1 linecolor rgb '#9ACD32' linetype 1 linewidth 7
set style line 2 linecolor rgb '#1E90FF' linetype 1 linewidth 7
set style line 3 linecolor rgb '#A04931' linetype 1 linewidth 7
set style line 4 linecolor rgb '#5009A1' linetype 1 linewidth 7
set style line 5 linecolor rgb '#E00921' linetype 1 linewidth 7


set style line 11 linecolor rgb '#9ACD32' linetype 2 linewidth 7
set style line 12 linecolor rgb '#1E90FF' linetype 2 linewidth 7
set style line 13 linecolor rgb '#A04931' linetype 2 linewidth 7
set style line 14 linecolor rgb '#5009A1' linetype 2 linewidth 7
set style line 15 linecolor rgb '#E00921' linetype 2 linewidth 7

set style line 21 linecolor rgb '#9ACD32' linetype 0 linewidth 7
set style line 22 linecolor rgb '#1E90FF' linetype 0 linewidth 7
set style line 23 linecolor rgb '#A04931' linetype 0 linewidth 7
set style line 24 linecolor rgb '#5009A1' linetype 0 linewidth 7
set style line 25 linecolor rgb '#E00921' linetype 0 linewidth 7

snr(s,ib,qe,fn,nr,m) =  (qe*s)/sqrt(fn*fn*qe*(s+ib)+(nr/m)**2)
f(s,ib,qe,fn,nr,m)=snr(s,ib,qe,fn,nr,m)/snr(s,ib,1,1,0,1);


set grid

set multiplot layout 3,1

ib = 0.3
nr = 9
nr_scmos_global = 1.3*1.41
nr_scmos_rolling = 1.3
nr_interline_20MHz = 6.5
nr_interline_1MHz = 2.4
fn =sqrt(2)
qe = .95
qe_interline = .65
qe_scmos = .7
set label "I_b=0.3" at .11,.845 left front
set label "M=20" at .8,.76 textcolor ls 2
set label "M=5" at .2,.45 textcolor ls 2
set label "global shutter" at 8,.88 textcolor ls 3
set label "rolling shutter" at 3.4,.5 textcolor ls 3
set label "1MHz" at 100,.9 textcolor ls 4
set label "20MHz" at 200,.6 textcolor ls 4

plot f(x,ib,qe,1,nr,1) w l title "back-thinned CCD" ls 1, f(x,ib,qe,fn,nr,20) w l title "EM-CCD" ls 2, f(x,ib,qe,fn,nr,5) w l notitle ls 2, (f(x,ib,qe_scmos,1,nr_scmos_global,1)<.95*sqrt(qe_scmos))?NaN:f(x,ib,qe_scmos,1,nr_scmos_global,1) w l notitle ls 23, (qe_scmos*(x+ib)<nr_scmos_global)?NaN:(f(x,ib,qe_scmos,1,nr_scmos_global,1)>.95*sqrt(qe_scmos))?NaN:f(x,ib,qe_scmos,1,nr_scmos_global,1) w l title "sCMOS" ls 3, (qe_scmos*(x+ib)<nr_scmos_global )?f(x,ib,qe_scmos,1,nr_scmos_global,1):NaN w l notitle ls 13, f(x,ib,qe_scmos,1,nr_scmos_rolling,1) w l notitle ls 3, f(x,ib,qe_interline,1,nr_interline_20MHz,1) w l title "interline CCD" ls 4, f(x,ib,qe_interline,1,nr_interline_1MHz,1) w l notitle ls 4, (x+ib<1)?f(x,ib,qe,1,nr,50):NaN w l title "EM-CCD gain=50 single photon" ls 5
unset label
ib = 3
set label "1MHz" at 100,.9 textcolor ls 4
set label "20MHz" at 200,.6 textcolor ls 4
set label "I_b=3" at .11,.845 left front
plot f(x,ib,qe,1,nr,1) w l title "back-thinned CCD" ls 1, f(x,ib,qe,fn,nr,20) w l title "EM-CCD" ls 2, f(x,ib,qe,fn,nr,5) w l notitle ls 2, f(x,ib,qe_scmos,1,nr_scmos_global,1) w l title "sCMOS" ls 3, f(x,ib,qe_scmos,1,nr_scmos_rolling,1) w l notitle ls 3, f(x,ib,qe_interline,1,nr_interline_20MHz,1) w l title "interline CCD" ls 4, f(x,ib,qe_interline,1,nr_interline_1MHz,1) w l notitle ls 4
unset label
ib = 30
set label "1MHz" at 100,.9 textcolor ls 4
set label "20MHz" at 200,.6 textcolor ls 4
set label "I_b=30" at .11,.845 left front
plot f(x,ib,qe,1,nr,1) w l title "back-thinned CCD" ls 1, f(x,ib,qe,fn,nr,20) w l title "EM-CCD" ls 2, f(x,ib,qe,fn,nr,5) w l notitle ls 2, f(x,ib,qe_scmos,1,nr_scmos_global,1) w l title "sCMOS" ls 3, f(x,ib,qe_scmos,1,nr_scmos_rolling,1) w l notitle ls 3, f(x,ib,qe_interline,1,nr_interline_20MHz,1) w l title "interline CCD" ls 4, f(x,ib,qe_interline,1,nr_interline_1MHz,1) w l notitle ls 4
unset label
unset multiplot
