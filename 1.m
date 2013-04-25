
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
X = 129; % muss ungerade sein, fuer perfektes zentrum
Z=ceil(X*delta_nuz/delta_nux);
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
b = a * (zz(g,'freq') *2  >= cos(alpha)); 
RHO = nu*((X-5.0)/X)
CX =  delta_nux*RHO*4;
CZ =  delta_nuz*RHO*4;
calotte = b(:,:,X-Z:X-1);

% increase by a factor of two
c=extract(calotte,size(calotte)*2);
kc = ft(c);

otf = ift(kc*conj(kc));  [cx,cy,cz]=size(otf); log(otf(:,floor(cy/2),:))

% point spread function in real space
h = abs(ft(a))^2;

X = 129; % this should be 
g = newim(X,X);
a = ft(besselj(0,sqrt(xx(g,'true')^2+yy(g,'true')^2)*pi))

dbquit
