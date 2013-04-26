
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
sc = size(calotte);
calotte(:,floor(sc(2)/2),:)

% increase by a factor of two
c=extract(calotte,size(calotte)*2);
kc = ft(c);
psf = kc*conj(kc);

otf = ift(psf);  so=size(otf); log(otf(:,floor(so(2)/2),:))


% jetzt muss ich die psf mit dem gitter falten:

sp = size(psf);
GX = 64;
grating = newim(GX,GX,1);
grating = .5*(1+sin(xx(grating,'freq')*pi*24));

% haenge aussen einen ausreichend grossen rand von nullen dran

gratingPAD = extract(grating,sp+size(grating));
sgp = size(gratingPAD);
kgratingPAD = ft(gratingPAD);

% schaue grating im fourier raum
kgratingPAD(:,floor(sgp(2)/2),floor(sgp(3)/2))
% und verleiche mit in z projezierter otf 
% sum(squeeze(otfPAD(:,floor(sgp(2)/2),:)),[],2)


otfPAD = extract(otf,size(gratingPAD));
illum = ift(kgratingPAD * otfPAD);

%illum(:,floor(sgp(2)/2),:)

% point spread function in real space
h = abs(ft(a))^2;

%X = 129; % this should be 
%g = newim(X,X);
%a = ft(besselj(0,sqrt(xx(g,'true')^2+yy(g,'true')^2)*pi))


g2 = newim(GX,GX,GX); % make empty 3d image

%% objects: line, rectangle arranged in two planes and a hollow
%% sphere as a 3d object
line_x=floor(.3*GX);
line_y0=floor(0*GX);
line_y1=floor(1*(GX-1));
line_z=floor(GX/2)-3;
lineseg = newim(g2);
lineseg(line_x:line_x,line_y0:line_y1,line_z) = 1;

rect_x0 = floor(.2*GX);
rect_x1 = floor(.9*GX);
rect_y0 = floor(.2*GX);
rect_y1 = floor(.5*GX);
rect_z = floor(GX/2)+3;
rectangle = newim(g2);
rectangle(rect_x0:rect_x1,rect_y0:rect_y1,rect_z) = 1;

hollow_sphere = 0.0 + (.3<rr(g2,'freq') & rr(g2,'freq')<.4); 

S = 12 * lineseg + 4 * rectangle + hollow_sphere;
[rubbish,rubbish2,S] = bbox(S>0,S);
G=newim(S);
G2=G;
sizeS = size(S);
G_z = 28;
G(:,:,G_z) = .5*(1+sin((xx(sizeS(1),sizeS(2))+yy(sizeS(1),sizeS(2)))/sqrt(2)/64*12*2*pi));
G2(:,:,G_z) = .5*(1-sin((xx(sizeS(1),sizeS(2))+yy(sizeS(1),sizeS(2)))/sqrt(2)/64*12*2*pi));


tic

SPAD = extract(S,sp+size(S));
sSp = size(SPAD);
kSPAD = ft(SPAD);

GPAD = extract(G,sp+size(S));
G2PAD = extract(G2,sp+size(S));
kGPAD = ft(GPAD);

% schaue grating im fourier raum
% kSPAD(:,floor(sSp(2)/2),floor(sSp(3)/2))

otfPAD = extract(otf,size(SPAD));
WF = ift(kSPAD * otfPAD);
WF_z = floor(sp(3)/2)+G_z;
WF_slice = WF(:,:,WF_z);

Ill1 = ift(kGPAD * otfPAD);
Ill2 = ift(ft(G2PAD) * otfPAD);

Struc1 = ift(ft(Ill1*SPAD) * otfPAD);
Struc1 = Struc1(:,:,WF_z);
Struc2 = ift(ft(Ill2 * SPAD) * otfPAD);
Struc2 = Struc2(:,:,WF_z);

toc

%dipshow(sum(ft(Struc1 - Struc2),[],3),'percentile')
%dipshow(sum(ft(Struc1 + Struc2),[],3),'percentile')
% dbquit Super-S-c schliesst fenster

%EDU>> fig=dipshow(cat(3,Struc1,Struc2,WF_slice))
% dipshow(fig,'ch_globalstretch','off')
% ch_slicing

dipshow(1,'ch_mappingmode','log')
dipshow(1,'ch_mappingmode','percentile')

ft(Ill1(:,64,WF_z))   
83 von 121
mitt ist bei 60
also ist peak bei 23 relativ zur mitte

sp = 70
size(S) = 51

G hat grating so, dass es 12 perioden enthalten wuerde, wenn groesse 64 waere
ft(.5*(1-sin(xx(64)/64*12*2*pi)))
mitte 32 peak 44
32+12 = 44

d.h. bei einer groesse von 121 hat das grating

ft(.5*(1-sin(xx(121)/64*12*2*pi)))
peak bei 83
60+12/64*121 = 82.6875

ft((Struc1-Struc2))
ft((Struc1-Struc2)*exp(2*pi*i*12/64/sqrt(2)*(xx(Struc1)+yy(Struc1))))

tic
size_Struc = size(Struc1);
rad_scan = newim(size_Struc(1),size_Struc(2)*4,100);
etas = newim(100);
for rad = 1:100
  lowpass = gaussf(rr(Struc1,'freq')<(rad/500.0) ,2);
  hipass = 1 - lowpass;
  ring = bdilation(rr(Struc1,'freq')<rad/500.0)- (rr(Struc1,'freq')<rad/500.0);
  %real(ft(besselj(0,rad/100.0*2*sqrt(xx(Struc1)^2+yy(Struc1)^2)*pi)));
  foo = real(ift(lowpass * ft(SPAD(:,:,WF_z))));
  tilt = exp(2*pi*i*12/64/sqrt(2)*(xx(Struc1)+yy(Struc1)));
  nonuni = ft((Struc1-Struc2)*tilt);
  uni = ft(Struc1+Struc2);

  etauni = mean(ring*abs(uni)^2);
  etanon = mean(ring*abs(nonuni)^2);
  eta = etauni/etanon;
 etas(rad) = eta;
  bar = imag(ift(lowpass * nonuni));
  baz = real(ift(hipass * uni));
  sec = bar+baz*eta;
  rad_scan(:,:,rad-1) =cat(2,lowpass,sec/max(sec),bar/max(bar),baz/max(baz));
end
toc
rad_scan




ft(besselj(0,rad/100.0*.5*sqrt(xx(g)^2+yy(g)^2)*pi))

eta ist mittelwert ueber hochpass betrags quadrat im ring / mittelwert low pass desselben

sum(rad_scan^2,[],[1 2])
%% Local Variables:
%% mode: Octave
%% End:
