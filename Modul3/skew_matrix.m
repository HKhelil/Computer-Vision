function [Vhat]=skew_matrix(V)
% Schifsymmetrische Matrix erzeugen
Vhat = zeros(3,3);

Vhat(1,2) = -V(3);
Vhat(1,3) = V(2);
Vhat(2,3) = -V(1);

% Ausnutzen der Schiefsymmetrie
Vhat = Vhat - Vhat';

end