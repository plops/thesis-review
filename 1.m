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
rect_z = floor(GX/2)+9;
rectangle2 = newim(g2);
rectangle2(rect_x0:rect_x1,rect_y0:rect_y1,rect_z) = 1;

hollow_sphere = 0.0 + (.3<rr(g2,'freq') & rr(g2,'freq')<.4); 

S = 12 * lineseg + 4 * (rectangle +rectangle2) + hollow_sphere;
[rubbish,rubbish2,S] = bbox(S>0,S);




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
% norm so dass faltung mit 2d psf die intensitaet nicht aendert
psf = psf/sum(psf(:,:,floor(size(psf,3)/2)));
otf = ft(psf);

% ich brauche drei oder vier nichtuniforme sinus beleuchtungen
% damit die ft besser aussieht benutze ich dampedge
phases = 4; % muss gerade sein, so dass pi dabei ist
G=newim([size(S) phases]); 
tilt = 2*pi*xx(size(S,1),size(S,2))/64*12;
G_z = 28;
G(:,:,G_z,:) = DampEdge(.5*(1+sin(repmat(tilt,[1 1 1 phases])+ramp([size(tilt),1,phases],4)*2*pi/phases)),.18,2);

% vergroesser in ortsraum, so dass psfs nicht uberlappen
WF = ift(ft(extract(S,size(psf))) * otf);
WF_z = floor(size(psf,3)/2)+G_z;
WF_slice = WF(:,:,WF_z);

% vergroessere G
dip_fouriertransform(extract(G,size(psf)),'forward',[1 1 1 0])

Ill = ift(ft(extract(G,size(psf)))*otf);

Ill1 = ift(kGPAD * otfPAD);
Ill2 = ift(ft(G2PAD) * otfPAD);
 
Struc1 = ift(ft(Ill1*SPAD) * otfPAD);
Struc1 = Struc1(:,:,WF_z);
Struc2 = ift(ft(Ill2 * SPAD) * otfPAD);
Struc2 = Struc2(:,:,WF_z);

%dipshow(sum(ft(Struc1 - Struc2),[],3),'percentile')
%dipshow(sum(ft(Struc1 + Struc2),[],3),'percentile')
% dbquit Super-S-c schliesst fenster

%EDU>> fig=dipshow(cat(3,Struc1,Struc2,WF_slice))
% dipshow(fig,'ch_globalstretch','off')
% ch_slicing

%    dipshow(1,'ch_mappingmode','log')
%    dipshow(1,'ch_mappingmode','percentile')


% eigentlich muesste man bei der 2d behandlung vignetting
% beruecksichtigen

otf2d = sum(real(otfPAD),[],3);
otf2d = otf2d/sum(real(ift(otf2d)));
otfcorr = (otf2d>0)/otf2d;
otfmask = (otf2d/max(otf2d))>0.001;
otfcorr(not(otfmask))=1;
otfcorr = otfcorr * gaussf(berosion(otfmask,8),3);
otfcorr = otfcorr/sum(real(ift(otfcorr)));

% otf2d und otfcorr sind so normiert, dass die intensitaet im bild nicht geandert wird


%cat(3,real(ift(otfcorr * ft(WF_slice))),WF_slice)

normalize = @(in) (in-min(in))/(max(in)-min(in))

Slice = SPAD(:,:,WF_z);
kSlice = ft(Slice);
tilt = exp(2*pi*i*12/64/sqrt(2)*(xx(Struc1)+yy(Struc1)));
uni = ft(Struc1+Struc2);
nonuni_unshifted = otfcorr*ft(Struc1-Struc2);
nonuni = ft(ift(nonuni_unshifted)*tilt);

size_Struc = size(Struc1);
rad_scan = newim(size_Struc(1),size_Struc(2)*2,60);
%for rad = 1:60
rad =3
  mask = rr(Struc1,'freq')<(rad/100.0);
  lowpass = gaussf(mask ,2);
  hipass = 1 - lowpass;
  ring = bdilation(mask)-mask;
  foo = real(ift(lowpass * kSlice));
  etauni = mean(ring*abs(uni)^2);
  etanon = mean(ring*abs(nonuni)^2);
  eta = etauni/etanon;
  bar = imag(ift(lowpass * nonuni));
  baz = real(ift(hipass * uni));
  sec = bar+baz*eta;
%  rad_scan(:,:,rad-1) =cat(2,normalize(abs(ring*1e-7+lowpass*nonuni+.1*nonuni)),normalize(sec),normalize(bar),normalize(baz));
%end
Slice_view = real(ift(otf2d*ft(Slice)));
for eta = 1:60
  v = eta/60;
  v = v^.1;
  sec = bar*v+baz*(1-v);
  rad_scan(:,:,eta-1) = cat(2,normalize(Slice_view-sec),normalize(sec));
end
toc
rad_scan


ft(besselj(0,rad/100.0*.5*sqrt(xx(g)^2+yy(g)^2)*pi))

eta ist mittelwert ueber hochpass betrags quadrat im ring / mittelwert low pass desselben

sum(rad_scan^2,[],[1 2])
%% Local Variables:
%% mode: Octave
%% End:
