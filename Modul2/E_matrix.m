 function E = E_matrix(Korrespondenzen)
 
 % Abfrage, ob genug Korrespondenzen da sind
 if(size(Korrespondenzen,2)<8)
     disp('Error: Weniger als achte Korrespondenzen gefunden!');
     return;
 end
 

% Koordinaten auslesen und mit einsen erweitern
X1 = [ Korrespondenzen(1:2,:) ; ones(1,size(Korrespondenzen,2) ) ];
X2 = [ Korrespondenzen(3:4,:) ; ones(1,size(Korrespondenzen,2) ) ];

% Matrix D �ber Kronecker Produkte berechnen
D = zeros(size(Korrespondenzen,2),9);
for i = 1:size(Korrespondenzen,2)
   D(i,:) = (kron(X1(:,i),X2(:,i))).';
end

% Gen�herte L�sung von X*E = 0 ist der kleinste Eingenvektor von [D'*D]
[EV, EW] = eig((D')*D);
EV1 = EV(:,1);

% Essentielle Matrix in 3x3 Form bringen
E = reshape(EV1,3,3);


% Singulärwertzerlegung
[U,S,V] = svd(E);

%K umformen
%sigma1 = sigma2 = Mittelwert der beiden Singul�rwerte
%sigma3 = 0
S(1,1) = (S(1,1)+S(2,2))/2.0; 
S(2,2) = S(1,1);
S(3,3) = 0;

%  Essentielle Matrix berechnen
Puf = diag ([1 1 -1]); % Matrix mit det = -1 benutz wenn detU=-1 oder det V= -1um die bedingungen dass U und V rotationsmatrizen sind


if (det(U)==1 && det(V)==1)
     E = U*S*V'
elseif (det(U)==1 && det(V)==-1)
     E = U*S*Puf*V'
elseif (det(U)==-1 && det(V)==1)
     E = U*Puf*S*V'
else
     E = U*Puf*S*Puf*V'
   
end    
    
    
    
    
    
    
