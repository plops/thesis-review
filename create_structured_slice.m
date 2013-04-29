function Struc = create_structured_slice(S,otf,phases,slice)
  % erzeuge ebene mit gitterstruktur
  clear G;
  G=newim([size(S) phases]); 
  tilt = 2*pi*xx(size(S,1),size(S,2))/64*12;
  G(:,:,slice,:) = DampEdge(.5*(1+sin(repmat(tilt,[1 1 1 phases])+ramp([size(tilt),1,phases],4)*2*pi/phases)),.18,2);

  
  % erzeuge 3d beleuchtungsverteilung im sample
  WF_z = floor(size(otf,3)/2)-floor(size(S,3)/2)+slice;
  kG = dip_fouriertransform(extract(G,size(otf)),'forward',[1 1 1 0]);
  kG = kG*repmat(otf,[1 1 1 phases]);
  Illum = real(dip_fouriertransform(kG,'inverse',[1 1 1 0]));
  
  % multipliziere mit beleuchtung
  kG = Illum *  repmat(extract(S,size(otf)),[1 1 1 phases]);
  kG = dip_fouriertransform(kG,'forward',[1 1 1 0]);
  kG = kG * repmat(otf,[1 1 1 phases]);
  kG = dip_fouriertransform(kG,'inverse',[1 1 1 0]);

  % gib 2d bilder aus der focusebene zurueck (fuer die
  % unterschiedlichen gitterphasen)
  Struc = real(kG(:,:,WF_z,:));


%% Local Variables:
%% mode: Octave
%% End:
