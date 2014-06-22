%Hassene Khelil
%3608341
%khelil.hassen@gmail.com

%Code

close all;
warning off;

B1rgb = double(imread('Bilder/I1.bmp'));
B2rgb = double(imread('Bilder/I4.bmp'));

W=9;

B1    = rgb_to_gray(B1rgb);
B2    = rgb_to_gray(B2rgb);

%Hier kann nat�rlich an den Werten gedreht werden
Mpt1=harris_detektor(B1,W,0.03,0.1,[40,40],50,5);
Mpt2=harris_detektor(B2,W,0.03,0.1,[40,40],50,5);

W=9;
Korrespondenzen = punkt_korrespondenzen(B1,B2,Mpt1,Mpt2,W,0.95,1);

tic
[Korrespondenzen_robust]=F_ransac(Korrespondenzen,0.95,0.5,5e-310);
t = toc

% If you want to viisualize the correspondences print 
addx=size(B1,2);
%Verbinde beide Punkte mit einer Linie
line([Korrespondenzen_robust(1,:);Korrespondenzen_robust(3,:)+addx],[Korrespondenzen_robust(2,:);Korrespondenzen_robust(4,:)],'Color',[1,0,0]);

% T+R mit unrobusten Korrespondenzen
[T1unrob,R1unrob,T2unrob,R2unrob] = TR_from_E(E_matrix(calibrate_correspondences(Korrespondenzen)))


% T+R mit robusten Korrespondenzen
[T1rob,R1rob,T2rob,R2rob]=TR_from_E(E_matrix(calibrate_correspondences(Korrespondenzen_robust)))


