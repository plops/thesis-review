function Struc = create_structured_slice(S,otf,phases,G_z)
  WF_z = size(otf,3)-G_z-1;
  kG = dip_fouriertransform(extract(G,size(otf)),'forward',[1 1 1 0]);
  kG = kG*repmat(otf,[1 1 1 phases]);
  Ill = real(dip_fouriertransform(kG,'inverse',[1 1 1 0]));
  
  % multipliziere mit beleuchtung
  kG = Ill * repmat(extract(S,size(psf)),[1 1 1 phases]);
  kG = dip_fouriertransform(kG,'forward',[1 1 1 0]);
  kG = kG * repmat(otf,[1 1 1 phases]);
  kG = dip_fouriertransform(kG,'inverse',[1 1 1 0]);
  Struc = real(kG(:,:,WF_z,:));
  clear kG;



%% Local Variables:
%% mode: Octave
%% End:
