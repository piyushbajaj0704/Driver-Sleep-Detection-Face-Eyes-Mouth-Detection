function segment = skin_seg2(I1)
% Convert image to double precision
I=double(I1);
[hue,s,v]=rgb2hsv(I);
%  Ycbcr = rgb2ycbcr(I);
% % cb=Ycbcr(:,:,2)+128;
% % cr=Ycbcr(:,:,3)+128;
cb =  0.148* I(:,:,1) - 0.291* I(:,:,2) + 0.439 * I(:,:,3) + 128;
cr =  0.439 * I(:,:,1) - 0.368 * I(:,:,2) -0.071 * I(:,:,3) + 128;
[w h]=size(I(:,:,1));

segment = 140<=cr & cr<=165 & 140<=cb & cb<=195 & 0.01<=hue & hue<=0.1;

segment=imfill(segment,'holes');
segment=bwmorph(segment,'dilate');
segment=bwmorph(segment,'majority');
