function [H]=normalizePixel(x)
varx=sqrt(var(x(1,:)));
meanx=mean(x(1,:));
vary=sqrt(var(x(2,:)));
meany=mean(x(2,:));
H = [  1/varx,0,     -meanx/varx;
       0,     1/vary,-meany/vary;
       0,          0,           1];