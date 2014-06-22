function [Ix,Iy]=sobel_xy(I)
%Interpolations Filter
di = [1  2 1];
%Ableitungs Filter
dd = [1 0 -1];
Ix=conv2(di,dd,I,'same');
Iy=conv2(dd,di,I,'same');
end

