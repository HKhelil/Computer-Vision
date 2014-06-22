function Cake=cake(MinDist)
[X,Y]=meshgrid(-MinDist:MinDist,[-MinDist:MinDist]);
Cake=sqrt(X.^2+Y.^2)>MinDist;
