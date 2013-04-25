
%% incoherent 3d point spread function
lambda0 = 5; % vacuum wavelength of the light (in pixels)
n = 1.52; % refractive index
nu = n/lambda0;  % diameter of the ewald sphere 
NA = 1.4; % numerical aperture of the lens
alpha = asin(NA/n);  % acceptance half-angle of lens

delta_nux = 4*nu*sin(alpha);
delta_nuz = 2*nu*(1-cos(alpha));

% cut segment from sphere shell as given by numerical aperture
% FIXME this implements \ref{eq:mccutchen}
% a = nu<rr(g) & rr(g)<nu+1 & zz(g)>nu*cos(alpha);  
X = 77; % muss ungerade sein, fuer perfektes zentrum
Z=floor(X*delta_nuz/delta_nux);
Z =  floor(X/2)+.5*X*delta_nuz/delta_nux 
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
grating = .5*(1+sin(xx(grating,'freq')*pi*20));

% haenge aussen einen ausreichend grossen rand von nullen dran

gratingPAD = extract(grating,sp+size(grating));
sgp = size(gratingPAD);
kgratingPAD = ft(gratingPAD);

% schaue grating im fourier raum
kgratingPAD(:,floor(sgp(2)/2),floor(sgp(3)/2))
% und verleiche mit in z projezierter otf 
sum(squeeze(otfPAD(:,floor(sgp(2)/2),:)),[],2)


otfPAD = extract(otf,size(gratingPAD));
illum = ift(kgratingPAD * otfPAD);

illum(:,floor(sgp(2)/2),:)

% point spread function in real space
h = abs(ft(a))^2;

X = 129; % this should be 
g = newim(X,X);
a = ft(besselj(0,sqrt(xx(g,'true')^2+yy(g,'true')^2)*pi))

dbquit
