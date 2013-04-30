function [sec uni nonuni] = section_hilo(struc,filter_fwhm,otf2d,otf2dcorr)
uni = repmat(otf2dcorr,[1 1 size(struc,3)])*squeeze(dip_fouriertransform(struc(:,:,:,0)+struc(:,:,:,2),'forward',[1 1 0 0]));

nonuni_unshifted = repmat(otf2dcorr,[1 1 size(struc,3)])*squeeze(dip_fouriertransform(struc(:,:,:,0)-struc(:,:,:,2),'forward',[1 1 0 0]));

tiltbig = 2*pi*xx(size(uni,1),size(uni,2))/64*12;

nonuni = dip_fouriertransform(repmat(exp(-i*tiltbig),[1 1 size(struc,3)])*dip_fouriertransform(nonuni_unshifted,'inverse',[1 1 0]),'forward',[1 1 0]);

% erzeuge einen filter der im fourier raum rund ist
% beziehe ihn auf die groesse der otf2d

% wo ist fwhm fuer gauss:
% solve(exp(-x^2/sigma^2)=.5,x);
% x=sqrt(log(2))*sigma=0.8326 sigma
filter_sigma= filter_fwhm/sqrt(log(2));
lowpass = extract(DampEdge(exp(-rr(otf2d)^2/(filter_sigma*size(otf2d,1))^2),.2,2,0),[size(uni,1) size(uni,2)]);
hipass = 1-lowpass;

ring = rr(otf2d)< filter_fwhm*size(otf2d,1);
ring = extract(bdilation(ring)-ring,[size(uni,1) size(uni,2)]);


% erweitere auf 3d
ring3= repmat(ring,[1 1 size(uni,3)]);
lowpass3 = repmat(lowpass,[1 1 size(uni,3)]);
hipass3 = repmat(hipass,[1 1 size(uni,3)]);

ringhi = mean(ring3*abs(hipass3*uni)^2,[],[1 2]);
ringlo = mean(ring3*abs(lowpass3*nonuni)^2,[],[1 2]);

eta = ringhi/ringlo;

eta_median=median(eta);
      
image_lo = imag(dip_fouriertransform(lowpass3 * nonuni,'inverse',[1 1 0]));
image_hi = real(dip_fouriertransform(hipass3 * uni,'inverse',[1 1 0]));
sec = image_lo+image_hi/eta_median;

