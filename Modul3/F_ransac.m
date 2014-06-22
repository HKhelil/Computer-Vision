function [Korrespondenzen_robust]=F_ransac(Korrespondenzen,p1,p2,max_dist)
% Anzahl der Korrespondenz-Paare
n = length(Korrespondenzen);
% Für die Bestimmung von E_Matrix k=8 Punkte sind mindestens nötig
k = 8;

% Minimum Anzahl an Iterationen
s = ceil((log(1-p1))/(log(1-(1-p2)^k)));

%Definieren Matrix C als die Matrix wo die Consensus Menge gespeichert
%wird
Consensus_Menge = zeros(4,n);

% Initialisierung
Consensus_Menge(:,1) = [1 1 1 1]';
tempCorr = zeros(4,n);

% S Iterationen absolvieren
for i = 1:s
   % Counter für Korrespondenzen
   countCorr=0;
   % Willkürliche Wahl für die 8 Korrespondenz-Punkte
   r = randi(n,k,1);
   
   % Input-Set für die Schätzung von E_matrix setzen
   tempInput = zeros(4,8);
   for j = 1:k 
       tempInput(:,j) = Korrespondenzen(:,r(j));
   end
   
   % compute model parameter
   F = F_matrix(tempInput);
   
   % Berechnung der Samspon-Distanz für alle Korrespondenz-Punkte
   for j = 1:n
        d = ([Korrespondenzen(3:4,j);1]'*F*[Korrespondenzen(1:2,j);1])^2 / ...
            ( norm(skew_matrix([0 0 1])*F*[Korrespondenzen(1:2,j);1] ,2)^2 ...
            + norm([Korrespondenzen(3:4,j);1]'*F*(skew_matrix([0 0 1]))',2)^2 ) ;
        
       % speichere den jeweiligen Korrespondenz-Punkt in der Consesus-Menge, wenn die
       % Sampson-Distanz kleiner als max_dist ist
       if d < max_dist
           countCorr = countCorr + 1;
           tempCorr(:,countCorr) = Korrespondenzen(:,j);
       end
   end
   %falls Consensus Menge größer als die alte ,dann neue Menge nehmen
   if countCorr >= find(Consensus_Menge(1,:),1,'last')
       Consensus_Menge = tempCorr;
   end
   
end % end i = 1:s

Korrespondenzen_robust = Consensus_Menge(:,1:find(Consensus_Menge(1,:),1,'last'));

end
