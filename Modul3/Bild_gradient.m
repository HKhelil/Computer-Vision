function [Ix,Iy]=Bild_gradient(I,sigma,w)
    if nargin == 1
        sigma = 1;
    end
    
    if nargin == 2
        %Berechne Filterlänge wobei gilt Filterlänge = 5*sigma 
        w = 5*sigma;
    end
    [di,dd]=gaussKernel(sigma,w);
    Ix=conv2(di,dd,I,'same');
    Iy=conv2(dd,di,I,'same');
end

%Erzeugt Gauss-Interpolationsfilter di und Gauss-Ableitungsfilter dd
function [di,dd]=gaussKernel(sigma,w)
    w=floor(w/2);
    %X Werte des Gauss gehen dann von -halbe Filterlänge bis +halbe
    %Filterlänge
    x=-w:w;
    
    %Berechne Gauss
    di=1/(sqrt(2*pi)*sigma)*exp(-x.^2/(2*sigma^2));
    
    %Berechne Ableitungs Kernel 
    dd=-x/sigma^2.*di;
end