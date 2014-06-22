function [T1,R1,T2,R2]=TR_from_E(E)

% SVD von E berechnen
[U, S, V] = svd(E);

% Help-Matrices definieren
Rot1=[0 -1 0; 1 0 0;0 0 1];
Rot2=[0  1 0;-1 0 0;0 0 1];

%Translationen direkt kriegen U(:,3) == e2 == T 
T1=U(:,3); 
T2=-T1;

%Rotationen über Formel
R1=U*Rot1'*V';
R2=U*Rot2'*V';



