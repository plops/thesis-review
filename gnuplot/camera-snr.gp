set terminal postscript eps size 5.5,7.52 enhanced color font 'Helvetica,22'
set output '| epstopdf --filter --outfile=camera-snr.pdf'
set border linewidth 2
set xrange [.1:3000]
set log x

set yrange [0:1]
#unset key
set key bottom right
set xlabel "average photon number S of signal"
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

set style line 21 linecolor rgb '#9ACD32' linetype 1 linewidth 3
set style line 22 linecolor rgb '#1E90FF' linetype 1 linewidth 3
set style line 23 linecolor rgb '#A04931' linetype 1 linewidth 3
set style line 24 linecolor rgb '#5009A1' linetype 1 linewidth 3
set style line 25 linecolor rgb '#E00921' linetype 1 linewidth 3

snr(s,ib,qe,fn,nr,m) =  (qe*s)/sqrt(1.0*fn*fn*qe*(s+ib)+(1.0*nr/m)**2)
f(s,ib,qe,fn,nr,m)=snr(s,ib,qe,fn,nr,m)/snr(s,ib,1,1,0,1);

f1(s,ib,qe,fn,nr,m) = (f(s,ib,qe,fn,nr,m)<.95*sqrt(qe)/fn)?NaN:f(s,ib,qe,fn,nr,m)
f2(s,ib,qe,fn,nr,m) = (fn*fn*qe*(s+ib)<(nr/m)**2)?NaN:(f(s,ib,qe,fn,nr,m)>.95*sqrt(qe)/fn)?NaN:f(s,ib,qe,fn,nr,m)
f3(s,ib,qe,fn,nr,m) = (fn*fn*qe*(s+ib)<(nr/m)**2 )?f(s,ib,qe,fn,nr,m):NaN

set grid

set multiplot layout 3,1

ib = 0.3
nr_conv = 5.3
nr_em = 15
gain_em = 80
gain_em_small = 20
nr_empc = 89
gain_pc = 1000
nr_scmos_cis = 2.3
nr_scmos_hama = 1.5
nr_interline_20MHz = 6.5
nr_interline_1MHz = 2.4
fn =sqrt(2)
qe = .95
qe_interline = .62
qe_scmos_cis = .52
qe_scmos_hama = .72
qe_scmos_ideal = .95
nr_scmos_ideal = .7
set label "I_b=0.3" at .11,.845 left front
set label "M=80" at .8,.76 textcolor ls 2
set label "M=20" at .13,.48 textcolor ls 2
set label "rolling shutter" at 8,.88 textcolor ls 3
set label "global shutter" at 10.8,.5 textcolor ls 3
set label "back-thinned" at .32,.93 textcolor ls 3
set label "1MHz" at 120,.82 textcolor ls 4
set label "20MHz" at 200,.6 textcolor ls 4
unset key
plot f1(x,ib,qe,1,nr_conv,1) w l notitle ls 21, \
     f2(x,ib,qe,1,nr_conv,1) w l title "back-thinned CCD" ls 1, \
     f3(x,ib,qe,1,nr_conv,1) w l notitle  ls 11, \
     f1(x,ib,qe,fn,nr_em,gain_em) w l notitle ls 22, \
     f2(x,ib,qe,fn,nr_em,gain_em) w l title "EM-CCD" ls 2, \
     f3(x,ib,qe,fn,nr_em,gain_em) w l notitle ls 12, \
     f1(x,ib,qe,fn,nr_em,gain_em_small) w l notitle ls 22, \
     f2(x,ib,qe,fn,nr_em,gain_em_small) w l notitle ls 2, \
     f3(x,ib,qe,fn,nr_em,gain_em_small) w l notitle ls 12, \
     f1(x,ib,qe_scmos_cis,1,nr_scmos_cis,1) w l notitle ls 23, \
     f2(x,ib,qe_scmos_cis,1,nr_scmos_cis,1) w l title "sCMOS" ls 3, \
     f3(x,ib,qe_scmos_cis,1,nr_scmos_cis,1) w l notitle ls 13, \
     f1(x,ib,qe_scmos_hama,1,nr_scmos_hama,1) w l notitle ls 23, \
     f2(x,ib,qe_scmos_hama,1,nr_scmos_hama,1) w l notitle ls 3, \
     f3(x,ib,qe_scmos_hama,1,nr_scmos_hama,1) w l notitle ls 13, \
     f3(x,ib,qe_scmos_ideal,1,nr_scmos_ideal,1) w l notitle ls 13, \
     f1(x,ib,qe_scmos_ideal,1,nr_scmos_ideal,1) w l notitle ls 23, \
     f2(x,ib,qe_scmos_ideal,1,nr_scmos_ideal,1) w l notitle ls 3, \
     f1(x,ib,qe_interline,1,nr_interline_20MHz,1) w l notitle ls 24, \
     f2(x,ib,qe_interline,1,nr_interline_20MHz,1) w l title "interline CCD" ls 4, \
     f3(x,ib,qe_interline,1,nr_interline_20MHz,1) w l notitle ls 14,\
     f1(x,ib,qe_interline,1,nr_interline_1MHz,1) w l notitle ls 24, \
     f2(x,ib,qe_interline,1,nr_interline_1MHz,1) w l notitle ls 4, \
     f3(x,ib,qe_interline,1,nr_interline_1MHz,1) w l notitle ls 14, \
     (x+ib<1)?f1(x,ib,qe,1,nr_empc,gain_pc):NaN w l title "EM-CCD M=1000 photon counting" ls 25,\
     (x+ib<1)?f2(x,ib,qe,1,nr_empc,gain_pc):NaN w l notitle ls 5,\
     (x+ib<1)?f3(x,ib,qe,1,nr_empc,gain_pc):NaN w l notitle ls 15
unset label
ib = 3
set label "1MHz" at 120,.82 textcolor ls 4
set label "20MHz" at 200,.6 textcolor ls 4
set label "I_b=3" at .11,.845 left front
plot f1(x,ib,qe,1,nr_conv,1) w l notitle ls 21, \
     f2(x,ib,qe,1,nr_conv,1) w l title "back-thinned CCD" ls 1, \
     f3(x,ib,qe,1,nr_conv,1) w l notitle  ls 11, \
     f1(x,ib,qe,fn,nr_em,gain_em) w l notitle ls 22, \
     f2(x,ib,qe,fn,nr_em,gain_em) w l title "EM-CCD" ls 2, \
     f3(x,ib,qe,fn,nr_em,gain_em) w l notitle ls 12, \
     f1(x,ib,qe,fn,nr_em,gain_em_small) w l notitle ls 22, \
     f2(x,ib,qe,fn,nr_em,gain_em_small) w l notitle ls 2, \
     f3(x,ib,qe,fn,nr_em,gain_em_small) w l notitle ls 12, \
     f1(x,ib,qe_scmos_cis,1,nr_scmos_cis,1) w l notitle ls 23, \
     f2(x,ib,qe_scmos_cis,1,nr_scmos_cis,1) w l title "sCMOS" ls 3, \
     f3(x,ib,qe_scmos_cis,1,nr_scmos_cis,1) w l notitle ls 13, \
     f1(x,ib,qe_scmos_hama,1,nr_scmos_hama,1) w l notitle ls 23, \
     f2(x,ib,qe_scmos_hama,1,nr_scmos_hama,1) w l notitle ls 3, \
     f3(x,ib,qe_scmos_hama,1,nr_scmos_hama,1) w l notitle ls 13, \
     f3(x,ib,qe_scmos_ideal,1,nr_scmos_ideal,1) w l notitle ls 13, \
     f1(x,ib,qe_scmos_ideal,1,nr_scmos_ideal,1) w l notitle ls 23, \
     f2(x,ib,qe_scmos_ideal,1,nr_scmos_ideal,1) w l notitle ls 3, \
     f1(x,ib,qe_interline,1,nr_interline_20MHz,1) w l notitle ls 24, \
     f2(x,ib,qe_interline,1,nr_interline_20MHz,1) w l title "interline CCD" ls 4, \
     f3(x,ib,qe_interline,1,nr_interline_20MHz,1) w l notitle ls 14,\
     f1(x,ib,qe_interline,1,nr_interline_1MHz,1) w l notitle ls 24, \
     f2(x,ib,qe_interline,1,nr_interline_1MHz,1) w l notitle ls 4, \
     f3(x,ib,qe_interline,1,nr_interline_1MHz,1) w l notitle ls 14, \
     (x+ib<1)?f1(x,ib,qe,1,nr_empc,gain_pc):NaN w l title "EM-CCD M=1000 photon counting" ls 25,\
     (x+ib<1)?f2(x,ib,qe,1,nr_empc,gain_pc):NaN w l notitle ls 5,\
     (x+ib<1)?f3(x,ib,qe,1,nr_empc,gain_pc):NaN w l notitle ls 15
unset label
set key
ib = 30
set label "1MHz" at 120,.82 textcolor ls 4
set label "20MHz" at 200,.6 textcolor ls 4
set label "I_b=30" at .11,.845 left front
plot f1(x,ib,qe,1,nr_conv,1) w l notitle ls 21, \
     f2(x,ib,qe,1,nr_conv,1) w l title "back-thinned CCD" ls 1, \
     f3(x,ib,qe,1,nr_conv,1) w l notitle  ls 11, \
     f1(x,ib,qe,fn,nr_em,gain_em) w l notitle ls 22, \
     f2(x,ib,qe,fn,nr_em,gain_em) w l title "EM-CCD" ls 2, \
     f3(x,ib,qe,fn,nr_em,gain_em) w l notitle ls 12, \
     f1(x,ib,qe,fn,nr_em,gain_em_small) w l notitle ls 22, \
     f2(x,ib,qe,fn,nr_em,gain_em_small) w l notitle ls 2, \
     f3(x,ib,qe,fn,nr_em,gain_em_small) w l notitle ls 12, \
     f1(x,ib,qe_scmos_cis,1,nr_scmos_cis,1) w l notitle ls 23, \
     f2(x,ib,qe_scmos_cis,1,nr_scmos_cis,1) w l title "sCMOS" ls 3, \
     f3(x,ib,qe_scmos_cis,1,nr_scmos_cis,1) w l notitle ls 13, \
     f1(x,ib,qe_scmos_hama,1,nr_scmos_hama,1) w l notitle ls 23, \
     f2(x,ib,qe_scmos_hama,1,nr_scmos_hama,1) w l notitle ls 3, \
     f3(x,ib,qe_scmos_hama,1,nr_scmos_hama,1) w l notitle ls 13, \
     f3(x,ib,qe_scmos_ideal,1,nr_scmos_ideal,1) w l notitle ls 13, \
     f1(x,ib,qe_scmos_ideal,1,nr_scmos_ideal,1) w l notitle ls 23, \
     f2(x,ib,qe_scmos_ideal,1,nr_scmos_ideal,1) w l notitle ls 3, \
     f1(x,ib,qe_interline,1,nr_interline_20MHz,1) w l notitle ls 24, \
     f2(x,ib,qe_interline,1,nr_interline_20MHz,1) w l title "interline CCD" ls 4, \
     f3(x,ib,qe_interline,1,nr_interline_20MHz,1) w l notitle ls 14,\
     f1(x,ib,qe_interline,1,nr_interline_1MHz,1) w l notitle ls 24, \
     f2(x,ib,qe_interline,1,nr_interline_1MHz,1) w l notitle ls 4, \
     f3(x,ib,qe_interline,1,nr_interline_1MHz,1) w l notitle ls 14, \
     (x+ib<1)?f1(x,ib,qe,1,nr_empc,gain_pc):NaN w l title "EM-CCD M=1000 photon counting" ls 25,\
     (x+ib<1)?f2(x,ib,qe,1,nr_empc,gain_pc):NaN w l notitle ls 5,\
     (x+ib<1)?f3(x,ib,qe,1,nr_empc,gain_pc):NaN w l notitle ls 15
unset label
unset multiplot
