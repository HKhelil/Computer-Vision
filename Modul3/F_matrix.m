%Funktion zur Berechnung der Fundamentalen Matrix aus den übergebenen
%Korrespondenzen. Anzahl der Korrespondenzen, wie bei der Essentiellen
%Matrix, ist 8
function [F]=F_matrix(Korrespondenzen)
if size(Korrespondenzen,1) == 4
    PtC1 = [Korrespondenzen(1:2,:);ones(1,size(Korrespondenzen,2))];
    PtC2 = [Korrespondenzen(3:4,:);ones(1,size(Korrespondenzen,2))];
end

H1=normalizePixel(PtC1);
H2=normalizePixel(PtC2);
x1n=H1*PtC1;
x2n=H2*PtC2;
Xi = (kron(x1n,ones(3,1)).*kron(ones(3,1),x2n))';

% Singulärwertzerlegung der Matrix Chi bzw Xi um F_s zu berechnen
% (Singulärwerte werden automatisch der Größe nach sortiert)
[U,S,V] = svd(Xi);

% Fundamentale Matrix, F
F = reshape(V(:,end),3,3);
% Anpassen der Singulärwerte für Fundamentale Matrix F
[U, S, V] = svd(F);
S(3,3)=0;
F = U *S * V';
F=H2'*F*H1;
F = F / norm(F,2);
