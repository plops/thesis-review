% berechne erstmal ein objekt
GX = 64;
g2 = newim(GX,GX,GX); % make empty 3d image

%% objects: line, rectangle arranged in two planes and a hollow
%% sphere as a 3d object
line_z=floor(GX/2)-3;
lineseg = drawline(g2,floor([.3*GX 0 line_z]),floor([.8*GX .9*GX line_z]),1)

rect_x0 = floor(.2*GX);
rect_x1 = floor(.9*GX);
rect_y0 = floor(.2*GX);
rect_y1 = floor(.5*GX);
rect_z = floor(GX/2)+3;
rectangle = newim(g2);
rectangle(rect_x0:rect_x1,rect_y0:rect_y1,rect_z) = 1;

rect_x0 = floor(.6*GX);
rect_x1 = floor(.8*GX);
rect_y0 = floor(.0*GX);
rect_y1 = floor(.9*GX);
rect_z2 = floor(GX/2)+9;
rectangle2 = newim(g2);
rectangle2(rect_x0:rect_x1,rect_y0:rect_y1,rect_z2) = 1;

hollow_sphere = 0.0 + (.3<rr(g2,'freq') & rr(g2,'freq')<.4); 

S = 12 * lineseg + 4 * (rectangle +rectangle2) + hollow_sphere;
S_mask = S>0;
[rubbish1,S_bbox,S] = bbox(S_mask,S);

% prepare single plane with same size
%S(:,:,:)=0;
%[rubbish2,rubbish3,S]=bbox(S_mask,rectangle);



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

% funktion um auf die mitte eines 3d arrays zuzugreifen
center_ref = @(a) a(floor(size(a,1)/2),floor(size(a,2)/2),floor(size(a,3)/2));
center_ref2 = @(a) a(floor(size(a,1)/2),floor(size(a,2)/2));

otf=extract(calotte,max(size(calotte)+size(S),size(calotte)*2));
psf = ift(otf);
psf = psf*conj(psf);
otf = real(ft(psf));
otf = otf / center_ref(otf);
psf = psf / center_ref(otf); 


psf2d = abs(ft(extract(calotte,size(calotte)*2)))^2;
psf2d = psf2d(:,:,floor(size(psf2d,3)/2));
otf2d = real(ft(psf2d));
% maxima code fuer den analytischen ausdruck (aus stokseth 1969)
% s ist reduzierte ortsfrequenz s=(lambda/n sin(alpha)) f
% ich glaube die klammern wurden falsch gesetzt in dem paper
% ausserdem gilt das glaube ich nur fuer kleine NA
% f(s):=(2*acos(s/2)-sin(2*acos(s/2)))/%pi ist 1 fuer s=0
% integrate(s^2*f(s),s,0,2); = 64/(45*pi)
otf2dcorr = DampEdge(rr(otf2d,'freq')<.47,.13,2,0);
otf2dcorr = otf2dcorr/otf2d;
otf2dcorr = otf2dcorr / center_ref(otf2dcorr);
% bringe auf dieselbe groesse wie psf
otf2dcorr = squeeze(extract(otf2dcorr,[size(psf,1) size(psf,2)]));

% ich brauche vier nichtuniforme sinus beleuchtungen
% damit die ft besser aussieht benutze ich dampedge
phases = 4; % muss gerade sein, so dass pi dabei ist
G=newim([size(S) phases]); 
tilt = 2*pi*xx(size(S,1),size(S,2))/64*12;
G_z = 28;
G(:,:,G_z,:) = DampEdge(.5*(1+sin(repmat(tilt,[1 1 1 phases])+ramp([size(tilt),1,phases],4)*2*pi/phases)),.18,2);

% G_z 28 -> 34 in WF

% psf_z = max(calotte_z+S_z,calotte_z*2)
% zur zeit tritt erster fall ein

% vergroesser in ortsraum, so dass psfs nicht uberlappen
WF = real(ift(ft(extract(S,size(psf))) * otf));
WF_z = size(psf,3)-G_z-1;
WF_slice = WF(:,:,WF_z);

%S_blownup = extract(S,size(psf));
%plot(799.8*double(squeeze(WF(47,40,:))));hold on;
%plot(double(squeeze(S_blownup(47,40,:)));hold off

%psf_blownup = extract(psf2d,[size(psf,1) size(psf,2)]);
%otf_blownup = ft(psf_blownup);
%real(ift(ft(psf_blownup)*ft(S_blownup(:,:,WF_z))))/otf_blownup(floor(size(otf_blownup,1)/2),floor(size(otf_blownup,2)/2),0)

% vergroessere G

kG = dip_fouriertransform(extract(G,size(psf)),'forward',[1 1 1 0]);
kG = kG*repmat(otf,[1 1 1 phases]);
Ill = real(dip_fouriertransform(kG,'inverse',[1 1 1 0]));

% multipliziere mit beleuchtung
kG = Ill * repmat(extract(S,size(psf)),[1 1 1 phases]);
kG = dip_fouriertransform(kG,'forward',[1 1 1 0]);
kG = kG * repmat(otf,[1 1 1 phases]);
kG = dip_fouriertransform(kG,'inverse',[1 1 1 0]);
Struc = real(kG(:,:,WF_z,:));
clear kG;

% dbquit Super-S-c schliesst fenster
%    dipshow(1,'ch_globalstretch','off')
%    dipshow(1,'ch_slicing','xz')
%    dipshow(1,'ch_mappingmode','log')
%    dipshow(1,'ch_mappingmode','percentile')

tic
struc = newim(size(otf,1),size(otf,2),size(S,3),phases);
for slice = 0:size(S,3)-1
    struc(:,:,slice,:) = create_structured_slice(S,otf,phases,slice);
    toc
end
toc % takes 4.7s per slice times 51 slices

% writeim(struc,'/mnt/tmp/struc_XYZ_phase.ics');

normalize = @(in) (in-min(in))/(max(in)-min(in))

S_slice = S(:,:,WF_z);




% different sectioning methods
% benedetti 1996
section_max_min = @(a) squeeze(max(a,[],4)-min(a,[],4))
% neil 1997 und ben-levy, peleg 1995
section_homodyne = @(a) squeeze(abs(a(:,:,:,0)+a(:,:,:,1)*exp(i*2*pi*1/4)+a(:,:,:,2)*exp(i*2*pi*2/4)+a(:,:,:,3)*exp(i*2*pi*3/4)))

% compare reconstructions of noisy images
tic
noise_struc=struc; %noise(struc/max(struc)*6000,'poisson');
maxmin=section_max_min(noise_struc)
homody=section_homodyne(noise_struc);
hilo=section_hilo(noise_struc,.13,otf2d,otf2dcorr)
toc
diplink(1,[2 3])

plot(double(squeeze(hilo(42,39,:))/100),'b');
hold on
plot(double(squeeze(homody(42,39,:))),'g');
hold on
plot(double(squeeze(maxmin(42,39,:))),'r');
hold on
plot(double(squeeze(WF(42,39,floor(size(otf,3)/2)-floor(size(S,3)/2)+(0:size(S,3)-1))))/1000,'c');
hold off



%% Local Variables:
%% mode: Octave
%% End:
