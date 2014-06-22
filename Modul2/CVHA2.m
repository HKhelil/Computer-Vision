
%Hassene Khelil
%3608341
%khelil.hassen@gmail.com


%Code
close all;
warning off;
%B1 = double(imread('Bilder/HausR.png'));
%B2 = double(imread('Bilder/HausL.png'));
%B1 = double(imread('Bilder/teddyR.png'));
%B2 = double(imread('Bilder/teddyL.png'));
B1 = double(imread('Bilder/computerR.jpg'));
B2 = double(imread('Bilder/computerL.jpg'));
%B1 = double(imread('Bilder/schweinR.jpg'));
%B2 = double(imread('Bilder/schweinL.jpg'));


W=9;

B1    = rgb_to_gray(B1);
B2    = rgb_to_gray(B2);

%Hier kann nat�rlich an den Werten gedreht werden
Mpt1=harris_detektor(B1,W,0.03,0.1,[64,48],10,7,1);
Mpt2=harris_detektor(B2,W,0.03,0.1,[64,48],10,7,1);

Korrespondenzen=punkt_korrespondenzen(B1,B2,Mpt1,Mpt2,37,0.88,1);

E=E_matrix(Korrespondenzen);
