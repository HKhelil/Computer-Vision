function [Korrespondenzen]=punkt_korrespondenzen(I1,I2,fpt1,fpt2,W,min_corr,do_plot)

Nbr_of_pts1 = size(fpt1,2);
Nbr_of_pts2 = size(fpt2,2);

%Matrix mit allen extrahierten Fenstern in Bild 1
Mat_feat_1 = zeros(W^2,Nbr_of_pts1);
%Matrix mit allen extrahierten Fenstern in Bild 2
Mat_feat_2 = zeros(Nbr_of_pts2,W^2);

Offset = floor(W/2);

%Vergrößere die Bilder um halbe Fenstergröße zur Vermeidung von if-Abfragen
Im1 = zeros(size(I1,1)+W-1,size(I1,2)+W-1);
Im2 = zeros(size(I2,1)+W-1,size(I2,2)+W-1);

Im1(Offset+1:end-Offset,Offset+1:end-Offset) = I1;
Im2(Offset+1:end-Offset,Offset+1:end-Offset) = I2;

%Es werden nun zu allen Merkmalspunkten aus I1 und I2 Fenster der
%Kantenlänge W extrahiert, die später miteinander korreliert werden sollen.
%Hierzu werden zunächst die entsprechenden Pixel (bzw. Indices) in den 
%Bildern berechnet, die um die Feature-Punkte liegen.

Win_extract = 0:W-1;

%Hier extrahieren wir alle Regionen
for index = 1:max(Nbr_of_pts1,Nbr_of_pts2)
    if index <= Nbr_of_pts1
        %Verschiebung der Indizes an korrekte Position. Durch die
        %Vergrößerung der Bilder (Nullrand) ist der Koordinatenoffset immer
        %nicht-negativ. Das Mittelpixel (Merkmalsposition) hat einen Offset
        %von W/2.
        W_x_coord = Win_extract + fpt1(1,index);
        W_y_coord = Win_extract + fpt1(2,index);
        %Fenster extrahiert;
        W_extracted = Im1(W_y_coord,W_x_coord);
        %Mittelwertsfrei
        W_extracted = W_extracted(:)-mean(W_extracted(:));
        %Normierung dies enstpicht genau sqrt(sum((I1(x)-I1m).^2)) dem
        %ersten teil unter der Wurzel des Nenners in der NCC Formel
        Mat_feat_1(:,index) = W_extracted/norm(W_extracted);
    end
    
    if index <= Nbr_of_pts2
        %Verschiebung der Indizes an korrekte position
        W_x_coord = Win_extract + fpt2(1,index);
        W_y_coord = Win_extract + fpt2(2,index);
        %Fenster extrahiert;
        W_extracted = Im2(W_y_coord,W_x_coord);
        %Mittelwertfrei
        W_extracted = W_extracted(:)-mean(W_extracted(:));
        %Normierung dies enstpicht genau sqrt(sum((I2(x)-I2m).^2)) dem 
        %zweiten teil unter der Wurzel des Nenners in der NCC formel
        Mat_feat_2(index,:) = W_extracted/norm(W_extracted);
    end    
end

%Hier wird die letztendliche NCC berechnet durch ein einfaches Matrix-Matrix
%Produkt. Im Eintrag (x,y) von NCC_matrix steht die Korrelation des Punktes
%X im zweiten Bild mit dem punkt y im ersten Bild
NCC_matrix = Mat_feat_2*Mat_feat_1;
%Setze alle Korrelationswerte auf 0 die kleiner als der Schwellwert sind
NCC_matrix(NCC_matrix<min_corr)=0;
%Initialisere Korrespondenzen-Matrix
Korrespondenzen=zeros(4,min(Nbr_of_pts1,Nbr_of_pts2));
Korr_count=1;
[sorted_list,sorted_index] = sort(NCC_matrix(:),'descend');
%Eliminiere alle Indizes deren Feature-Stärke = 0
sorted_index(sorted_list==0)=[];
%Maximale Anzahl an iterationen entspricht 
end_search      = numel(sorted_index);
size_ncc     = size(NCC_matrix);
% Falls Plotten gewünscht, stelle zuerst I1 und I2 nebeneinander dar
if nargin == 7  
    figure
    imshow(uint8([I1,I2]));
    addx = size(I1,2);
    addy = 0;%size(I1,1);
    hold on
end
for search_here = 1:end_search

    % Nehme nächstes Element aus der absteigend nach Größe sortierten Liste
    pt_index = sorted_index(search_here);
    % Kontrolle ob dieser Wert noch existiert oder bereits auf 0 gesetzt
    % wurde
    if(NCC_matrix(pt_index)==0)
        continue;
    else
        %Extrahiere Reihen- und Spaltenindex
        [Idx_fpt2,Idx_fpt1]=ind2sub(size_ncc,pt_index);
    end
    
    %Setze entsprechende Zeile bzw. Spalte = 0 zur vermeidung, dass einem
    %Featurepunkte mehrere Korrespondenzen zugewiesen werden
    NCC_matrix(Idx_fpt2,:) = 0;
    NCC_matrix(:,Idx_fpt1) = 0;
    Korrespondenzen(:,Korr_count) = [fpt1(:,Idx_fpt1);fpt2(:,Idx_fpt2)];
    Korr_count = Korr_count+1;
  if nargin == 7  
      %Zeichne Feature Punkt in Bild 1 ein
       plot(fpt1(1,Idx_fpt1),fpt1(2,Idx_fpt1),'o');
       %Zeichne Korrespondenzpunkt ind Bild 2 ein
       plot(fpt2(1,Idx_fpt2)+addx,fpt2(2,Idx_fpt2)+addy,'o');
       %Verbinde beide Punkte mit einer Linie
       line([fpt1(1,Idx_fpt1),fpt2(1,Idx_fpt2)+addx],[fpt1(2,Idx_fpt1),fpt2(2,Idx_fpt2)+addy],'Color',[0,1,0]);
  end
end
%Lösche unnötig initalisierte Elemente der Korrespondenzmatrix
Korrespondenzen = Korrespondenzen(:,1:Korr_count-1);




