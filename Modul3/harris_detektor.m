function  Merkmale=harris_detektor(Bild,W,k,tau,tile_size,N,min_dist,do_plot) 
%% Überprüfung der Eingabeparameter
switch nargin
    case 1
        W=7;
        k=0.03;
        tau = 0.01;
        tile_size = [40,40];
        N = 5;
        min_dist = 10;      
        
    case 2
        k=0.03;
        tau = 0.01;
        tile_size = [40,40];
        N = 5;
        min_dist = 10;      
    case 3
        tau = 0.01;
        tile_size = [40,40];
        N = 5;
        min_dist = 10;           
    case 4
        tile_size = [40,40];
        N = 5;
        min_dist = 10;       
    case 5
        N = 5;
        min_dist = 10;       
    case 6
        min_dist = 10;        
end

%Falls Tilesize nur als Skalar, erstelle quadratisches Fenster
if numel(tile_size) == 1
    tile_size=[tile_size,tile_size];
end
%% Vorbereitung zur Feature Detektion
%Hier noch eine weitere Gradienten-Funktion angegeben, die Gradienten
%mittels Gauss Filter approximiert, siehe Skript
%[Ix,Iy ]= Bild_gradient(Bild,1);
[Ix,Iy ]= sobel_xy(Bild);

%Wir wählen hier ein Fenster mit Gauss-Gewichtung zur besseren Bestimmung der
%Position der Merkmale. Üblicherweise kann man sigma = Filterlänge/5
%wählen.
fmask1   = fspecial('gaussian',[W,1],W/5);
%Das wäre die Fensterung ohne Gewichtung
%fmask1   = ones(W,1);

%Bestimmung der Einträge der G-Matrix
%G(1,1) Summe aller Ix^2 in Fenster W 
Ixqval  = double(conv2(fmask1,fmask1,Ix.^2, 'same'));
%G(2,2) Summe aller Iy^2 in Fenster W 
Iyqval  = double(conv2(fmask1,fmask1,Iy.^2, 'same'));
%G(1,2) und G(2,1) Summe aller Ix*Iy in Fenster W 
Ixyval  = double(conv2(fmask1,fmask1,Ix.*Iy, 'same'));
 


 
%% Eigentliche Feature Detektion über Harrismessung
% Harrismessung
corner   = ((Ixqval.*Iyqval - Ixyval.^2) - k*(Ixqval + Iyqval).^2);


%Hier wäre der Code für erste Version, betrachte nur jeweils den kleineren
%Eigenwert der G-Matrizen. Die Eigenwerte einer 2x2 Matrix können ganz 
%einfach berechnet werden ohne eine spezielle Funktion. Das /2 könnte auch 
%weggelassen werden, um Rechenzeit zu sparen.
% sq=sqrt(Iyqval.^2 - 2.*Ixqval.*Iyqval + 4.*Ixyval.^2 + Ixqval.^2);
% EW1 = (-sq + Iyqval + Ixqval)/2;
% EW2 = (sq + Iyqval + Ixqval)/2;
% corner=zeros(size(EW1));

%Da man nicht weiß, welcher der berechneten Eigenwerte der kleinere ist,
%wird hier die Auswahl getroffen
% Selection = EW1<EW2;
% corner(Selection)=EW1(Selection);
% corner(~Selection)=EW2(~Selection);


test_tau = mean(corner(corner>0))*0.6;

% Da oben in Ixqval usw. wieder eine Faltung stattgefunden hat, müssen die
% Nullränder unterdrückt werden. Maske zur Unterdrückung wird in
% Funktion zeroBorder erstellt.
corner = corner.*zeroBorder(corner,ceil(W/2));

%Schwellwertbildung der Merkmale
corner(corner<=max(tau,test_tau)) = 0;

%% Einführung maximaler Anzahl an Merkmalen + minimaler Abstand 2er Merkmale

%Das AKKA ist ein Akkumulator Feld. Das Akkumulator Feld gibt
%Aufschluss darüber, wie viele Merkmale pro Kachel schon gefunden wurden.
%Somit muss der Wert des Elementes des AKKAs, welches der Kachel
%entspricht, in der ein Merkmal gefunden wurde, um 1 erhöht werden, wenn ein
%neues Merkmal detektiert wurde
AKKA = zeros(ceil(size(Bild,1)/tile_size(1)),ceil(size(Bild,2)/tile_size(2)));
 
%Die Matrix Cake beinhaltet eine "Kuchenmatrix", die eine kreisförmige
%Anordnung von Nullen beinhaltet und der Rest ist mit Einsen aufgefüllt. 
%Diese dient dazu, dass man von jedem Merkmalspunkt nicht extra die 
%Distanzen zu allen anderen Merkmalen bestimmen muss, sondern einfach die 
%Punkte unterdrückt, die diesen minimalen Abstand nicht einhalten
Cake    = cake(min_dist);
 
%Damit diese Matrix Cake immer mit der Region um den gefundenen
%Merkmalspunkt elementweise multipliziert werden kann, auch an den Rändern
%der Matrix corner, wird die Matrix corner um einen "Nullrand", der genau
%dem minimalen Abstand entspricht, erweitert
Z = zeros(size(corner,1)+2*min_dist,size(corner,2)+2*min_dist);
Z((min_dist + 1):(size(corner,1)+min_dist),(min_dist + 1):(size(corner,2)+min_dist)) = corner;
corner = Z;


%Sortierung der Merkmale der Stärke nach absteigend
[sorted_list,sorted_index] = sort(corner(:),'descend');
%Eliminiere alle Indizes deren Merkmalsstärke = 0 (durch Schwellwert)
sorted_index(sorted_list==0)=[];

%Maximale Anzahl an Iterationen, falls alle Merkmale die in der sorted list
%vorkommen und deren Stärke größer 0 ist als endgültige Merkmale detektiert
%werden
end_search      = numel(sorted_index);
size_corner     = size(corner);

% Hier werden die Merkmale gespeichert. Die maximale Anzahl an Merkmalen
% entspricht der Anzahl der Kacheln * N. Damit initialisieren wir die
% Matrix Merkmale um Geschwindigkeitsverluste durch Speicherallokation zu vermeiden.
Merkmale=zeros(2,min(numel(AKKA)*N,end_search));
feature_count=1;


for  current_point = 1:end_search
    % Nehme nächstes Element aus sortierter Liste
    pt_index = sorted_index(current_point);
    %Falls dieser Punkt aufgrund von Distanz oder erreichter maximaler
    %Anzahl an Merkmalen pro Fenster schon auf 0 gesetzt wurde, wird hier
    %gestoppt und das nächste Element untersucht
    
    if(corner(pt_index)==0)
            continue;
    else
           %Extrahiere Reihen- und Spaltenindex. ind2sub wäre die
           %entsprechende Matlabfunktion, ist allerdings deutlich
           %langsamer als die verwendete Berechnung der Indizes
           %[row,col]=ind2sub(size_corner,pt_index). Unterschied kann bei
           %sehr vielen Merkmalen im Bereich von 100ms liegen.
           col = floor(pt_index/size_corner(1));
           row = pt_index - col*size_corner(1);
           col = col + 1;
    end

    
    %Berechnung der Indizes, und damit der ID der zum gefundenen
    %Merkmalspunkt korrespondierenden Kachel Ex und Ey
    Ex = floor((row-min_dist-1)/(tile_size(1)))+1;
    Ey = floor((col-min_dist-1)/(tile_size(2)))+1;
    
    %Erhöhe entsprechenden Wert des Akkumulator-Arrays und
    AKKA(Ex,Ey)=AKKA(Ex,Ey)+1;
    %multipliziere Region um den gefundenen Merkmalspunkt elementweise
    %mit der Kuchenmaske
    corner(row-min_dist:row+min_dist,col-min_dist:col+min_dist)=corner(row-min_dist:row+min_dist,col-min_dist:col+min_dist).*Cake;
    %Teste ob entsprechende Kachel schon genügend Merkmale beinhaltet
    if AKKA(Ex,Ey)==N
        %Falls ja, setzte alle verbleibenden Merkmale innerhalb dieser Kachel
        %auf 0
        corner((((Ex-1)*tile_size(1))+1+min_dist):min(size(corner,1),Ex*tile_size(1)+min_dist),(((Ey-1)*tile_size(2))+1+min_dist):min(size(corner,2),Ey*tile_size(2)+min_dist))=0;   
    end
    
    %Speichere den Merkmalspunkt. Da wir die Matrix, die alle Merkmalspunkte
    %beinhaltet, um einen Nullrand der Breite min_dist vergrößert haben,
    %müssen wir diesen noch von den x,y-Koordinaten des gefundenen Merkmals
    %subtrahieren
    Merkmale(:,feature_count)=[col-min_dist;row-min_dist];
    feature_count = feature_count+1;
end

%Lösche alle unnötigen 0-Einträge der Vorinitialisierung
Merkmale = Merkmale(:,1:feature_count-1);

%% Darstellung der gefundenen Merkmale
if nargin==8
    figure  
    colormap('gray')
    imagesc(Bild)
    %imshow(Bild);
    hold on;
    plot(Merkmale(1,:), Merkmale(2,:), 'g+');
    axis('off');
end
end

