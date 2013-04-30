% funktion um auf die mitte eines 3d arrays zuzugreifen
center_ref = @(a) a(floor(size(a,1)/2),floor(size(a,2)/2),floor(size(a,3)/2));
center_ref2 = @(a) a(floor(size(a,1)/2),floor(size(a,2)/2));
normalize = @(in) (in-min(in))/(max(in)-min(in))

global store
store = @(scale,in,fn) writeim(max(0,min(255,floor(scale*squeeze(in)))),fn,'JPEG')


% berechne erstmal ein objekt
GX = 64;
g2 = newim(GX,GX,GX); % make empty 3d image

%% objects: line, rectangle arranged in two planes and a hollow
%% sphere as a 3d object
line_z=floor(size(g2,3)/2)-3;
lineseg = drawline(g2,floor([.3*GX 0 line_z]),floor([.8*GX .9*GX line_z]),1);

rect_x0 = floor(.2*GX);
rect_x1 = floor(.9*GX);
rect_y0 = floor(.2*GX);
rect_y1 = floor(.5*GX);
rect_z1 = floor(GX/2)+3;
rectangle1 = newim(g2);
rectangle1(rect_x0:rect_x1,rect_y0:rect_y1,rect_z1) = 1;

rect_x0 = floor(.6*GX);
rect_x1 = floor(.8*GX);
rect_y0 = floor(.0*GX);
rect_y1 = floor(.9*GX);
rect_z2 = floor(GX/2)+9;
rectangle2 = newim(g2);
rectangle2(rect_x0:rect_x1,rect_y0:rect_y1,rect_z2) = 1;

hollow_sphere = 0.0 + (.3<rr(g2,'freq') & rr(g2,'freq')<.4); 

S = 12 * lineseg + 4 * (rectangle1 +rectangle2) + hollow_sphere;
S_mask = S>0;
[rubbish1,S_bbox,S] = bbox(S_mask,S);

% writeim(S,'/mnt/tmp/S.ics');


%% incoherent 3d point spread function
lambda0 = 5; % vacuum wavelength of the light (in pixels)
n = 1.52; % refractive index
nu = n/lambda0;  % diameter of the ewald sphere 
NA = 1.4; % numerical aperture of the lens
alpha = asin(NA/n);  % acceptance half-angle of lens

% cut segment from sphere shell as given by numerical aperture
% FIXME this implements \ref{eq:mccutchen}
% a = nu<rr(g) & rr(g)<nu+1 & zz(g)>nu*cos(alpha);  
X = 37; % muss ungerade sein, fuer perfektes zentrum
g = newim(X,X,X);

% das beruehrt genau alle raender, (bei 'freq' ists 200 fuer z und 400
% fuer x, aber dann ist der kreis isotrop)
% a=ft(sinc(rr(g)*pi));
% ich will die haelfte
a=ft(sinc(rr(g)*pi)); 

% die kugel fuellt in z die haelfte aus. mit freq kriege ich die
% grenzen +/- .5 also muss ich mal 4 nehmen um den radius der
% ewaldkugel zu bekommen, mit cos(alpha) das entsprechende stueck
% rausschneiden
% schneide genau die kappe aus
zpos = floor(X/2) + round(.5*X*cos(alpha));
xpos1 = floor(X/2) - round(.5*X*sin(alpha));
xpos2 = floor(X/2) + round(.5*X*sin(alpha));
calotte = a(xpos1:xpos2,xpos1:xpos2,zpos:end);

% um die psf zu berechnen muss die groesse mindestens um einen faktor
% zwei erhoeht werden. ich weiss aber auch wie gross die
% fluorophorverteilung ist. 1d erklaerung: als erstes hatte ich
% calotte X breit und fuer psf 2*X breit gesetzt. wenn objekt breite
% GX hat habe ich die psf dann nochmals um GX vergroessert auf
% insgesamt 2*X+GX. das ist aber zuviel. es reicht bereits eine
% groesse von max(X+GX,2*X). fuer mehrere dimensionen koennen beide
% faelle gleichzeitig auftreten. das sollte aber kein problem sein.


otf=extract(calotte,max(size(calotte)+size(S),size(calotte)*2));
psf = ift(otf);
psf = psf*conj(psf);
otf = real(ft(psf));
otf = otf / center_ref(otf);
psf = psf / center_ref(otf); 

writeim(min(255,floor(1500*normalize(squeeze((abs(otf(:,floor(size(otf,2)/2),:))))))),'/mnt/tmp/otf.jpg','JPEG')

store(1500,abs(otf(:,floor(size(otf,2)/2),:)),'/mnt/tmp/otf.jpg');
store(4e6,abs(psf(:,floor(size(psf,2)/2),:)),'/mnt/tmp/psf.jpg');



psf2d = abs(ft(extract(calotte,size(calotte)*2)))^2;
psf2d = psf2d(:,:,floor(size(psf2d,3)/2));
otf2d = real(ft(psf2d));

double(otf2d(:,floor(size(otf2d,2)/2),0))

otf2dcorr = DampEdge(rr(otf2d,'freq')<.49,.03,2,0);
otf2dcorr = otf2dcorr/otf2d;
otf2dcorr = otf2dcorr / center_ref(otf2dcorr);
% bringe auf dieselbe groesse wie psf
otf2dcorr = squeeze(extract(otf2dcorr,[size(psf,1) size(psf,2)]));

phases = 4; % muss gerade sein, so dass pi dabei ist

% psf_z = max(calotte_z+S_z,calotte_z*2)
% zur zeit tritt erster fall ein

% vergroesser in ortsraum, so dass psfs am rand nicht uberlappen
WF = real(ift(ft(extract(S,size(psf))) * otf));


store(755,WF(:,:,line_z),'/mnt/tmp/S_line.jpg');
store(755,WF(:,:,rect_z1),'/mnt/tmp/S_rect1.jpg');
store(755,WF(:,:,rect_z2),'/mnt/tmp/S_rect2.jpg');

tic
struc = newim(size(otf,1),size(otf,2),size(S,3),phases);
for slice = 0:size(S,3)-1
    struc(:,:,slice,:) = create_structured_slice(S,otf,phases,slice);
    toc
end
toc % takes 4.7s per slice times 51 slices

% create the pictures
create_structured_slice(S,otf,phases,floor(size(S,3)/2));


% writeim(struc,'/mnt/tmp/struc_XYZ_phase.ics');

% different sectioning methods
% benedetti 1996
section_max_min = @(a) squeeze(max(a,[],4)-min(a,[],4))
% neil 1997 und ben-levy, peleg 1995
section_homodyne = @(a) squeeze(abs(a(:,:,:,0)+a(:,:,:,1)*exp(i*2*pi*1/4)+a(:,:,:,2)*exp(i*2*pi*2/4)+a(:,:,:,3)*exp(i*2*pi*3/4)))

% compare reconstructions of noisy images
tic
noise_struc=noise(struc/max(struc)*60000,'poisson');
maxmin=section_max_min(noise_struc);
homody=section_homodyne(noise_struc);
[hilo uni_noise nonuni_noise]=section_hilo(noise_struc,.13,otf2d,otf2dcorr);
toc
%diplink(1,[2 3 4])
%cat(4,noise_struc/10,maxmin,homody,hilo,WF(:,:,floor(size(otf,3)/2)-floor(size(S,3)/2)+(0:size(S,3)-1))/1000);

get_bbox = @(slice) floor(size(otf,3)/2)-floor(size(S,3)/2)+slice;

store(1/40,hilo(:,:,28),'/mnt/tmp/sec_rect1_hilo.jpg');
store(1/40,homody(:,:,28),'/mnt/tmp/sec_rect1_homo.jpg');
store(1/40,maxmin(:,:,28),'/mnt/tmp/sec_rect1_mm.jpg');


noise_wf=squeeze(mean(noise_struc,[],4));




% sampling in z richtung ist ungefaehr lambda (ich nehme 500nm licht)
dz=.5/(n*(1-cos(alpha)))
% dx=lambda0/(2*NA)

%x breite von illum bild (fuer 500nm licht)
%86*.5/(2*NA)
%z hoehe von illum bild
%63*.5/(n*(1-cos(alpha)))


zpos = dz*((0:size(hilo,3)-1)-28);
hilo_p = double(squeeze(hilo(42,39,:)));
homo_p = double(squeeze(homody(42,39,:)));
maxm_p = double(squeeze(maxmin(42,39,:)));
wide_p = double(squeeze(noise_wf(42,39,:)));
% zeige original sample hat arbitrary scale
hS = floor(size(hilo)/2)-floor(size(S)/2);
zpos_big=dz*((hS(3):size(S,3)-1)-28);
s_p = 60e3/100*double(squeeze(S(42-hS(1),39-hS(2),:)));
plot(zpos,hilo_p,zpos,homo_p,zpos,maxm_p,zpos,wide_p,zpos_big,s_p);
xlabel('z/\mum');
ylabel('intensity/photons');
legend('hilo','homodyne','maxmin','widefield','sample','Location','EastOutSide');
grid on;
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'inches');
set(gcf, 'PaperPosition', [0 0 7 3.2]);
print -depsc2 /mnt/tmp/cross-section-z.eps

[hilo_nonoise uni_nonoise nonuni_nonoise]=section_hilo(noise_struc,.13,otf2d,otf2dcorr);
% slice 22 ist die linie

store(1/1e2,abs(uni_nonoise(:,:,22)),'/mnt/tmp/hilo-method-uni.jpg');
store(1/40,abs(nonuni_nonoise(:,:,22)),'/mnt/tmp/hilo-method-nonuni.jpg');
store(.05,hilo_nonoise(:,:,22),'/mnt/tmp/hilo-method-rec.jpg');

otfline = squeeze(otf2d(:,floor(size(otf2d,2)/2),0));
otfline = otfline / otfline(floor(size(otfline)/2));
otfline_x = xx(otfline,'freq')*4;
plot(double(otfline_x),double(otfline))
grid on;
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'inches');
set(gcf, 'PaperPosition', [0 0 5 2]);
xlabel('\nu_x / (NA/\lambda_0)');
ylabel('OTF');
print /mnt/tmp/otfline.eps

%% Local Variables:
%% mode: Octave
%% End:
