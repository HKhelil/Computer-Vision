%PUNKT_KORRESPONDENZEN
function [Korrespondenzen]=punkt_korrespondenzen(B1,B2,Mpt1,Mpt2,W,min_corr,do_plot)
% check the input parameters
switch nargin
    case 4
        W=7;
        min_corr= 0.9;
        do_plot = 1;
    case 5
        min_corr = 0.9;
        do_plot = 1;
    case 6
        do_plot = 1;
    case 7 ;
    otherwise
        disp('Error: Mindestens 4 und maximal 7 Parameter!');
end

tic % start time measurement

W1 = floor(W/2);
number_points=size(Mpt1,2);

%allocate the result matrice
NCC_final = [Mpt1; zeros(3,number_points) ]; 

for ii = 1:number_points
    
    %solve the edge problem in  picture 1

    % if the point is near to the left side
    if (Mpt1(2,ii)-W1) <= 0
       left_size_Y = Mpt1(2,ii) - 1; 
    else
        left_size_Y = W1;
    end
    % if the point is near to the right side
    if (Mpt1(2,ii)+W1) > size(B1,1)
        right_size_Y = size(B1,1) - Mpt1(2,ii); % if the 
    else
        right_size_Y = W1;
    end
    % if the point is near to the top 
    if (Mpt1(1,ii)-W1) <= 0
        up_size_X = Mpt1(1,ii) - 1;
    else
        up_size_X = W1;
    end
    % if the point is near to the bottom
    if (Mpt1(1,ii)+W1) > size(B1,2)
        down_size_X = size(B1,2) - Mpt1(1,ii);
    else
        down_size_X = W1;
    end
    
    %cut the window in the picture 1
    % if the point is near to the left side we start our window from 1 
    %if the point is near t the right side we end in the size of the picture
    Window1T = B1( Mpt1(2,ii)-left_size_Y:Mpt1(2,ii)+right_size_Y , Mpt1(1,ii)-up_size_X:Mpt1(1,ii)+down_size_X );
    
	%calculate mean value 
    MW1T = mean(Window1T(:));
    
    %allocate the result matrice
    NCC = zeros(1,number_points);
    
    %save dimensions of window in picture 1
    left_size_YM = left_size_Y; right_size_YP = right_size_Y; up_size_XM = up_size_X; down_size_XP = down_size_X; 
    
    for jj=1:size(Mpt2,2)
        
        %take the dimensions of picture 1
        left_size_Y = left_size_YM; right_size_Y = right_size_YP; up_size_X = up_size_XM; down_size_X = down_size_XP;
        sizechanged = 0;

        %solve the edge problem in picture 2
        % if the point is near to the left side
        if (Mpt2(2,jj)-left_size_Y) <= 0
            left_size_Y = Mpt2(2,jj) - 1;
            sizechanged = 1;
        end
        % if the point is near to the right side
        if (Mpt2(2,jj)+right_size_Y) > size(B2,1)
            right_size_Y = size(B2,1) - Mpt2(2,jj);
            sizechanged = 1;
        end
        % if the point is near to the bottom
        if (Mpt2(1,jj)-up_size_X) <= 0
            up_size_X = Mpt2(1,jj) - 1;
            sizechanged = 1;
        end
        % if the point is near to the bottom
        if (Mpt2(1,jj)+down_size_X) > size(B2,2)
            down_size_X = size(B2,2) - Mpt2(1,jj);
            sizechanged = 1;
        end
        
        %check if the size of the 
        if (sizechanged)
            
            %calculate the window of picture 1 again
            % Fenster 1 ausschneiden
            Window1 = B1( Mpt1(2,ii)-left_size_Y:Mpt1(2,ii)+right_size_Y , Mpt1(1,ii)-up_size_X:Mpt1(1,ii)+down_size_X );

            % calculate the mean value
            MW1 = mean(Window1(:));
            
        else
            %alte valuee nehmen
            Window1 = Window1T;
            MW1 = MW1T;
        end
        
        %Fenster aus Bild2 ausschneiden
        Window2 = B2( Mpt2(2,jj)-left_size_Y : Mpt2(2,jj)+right_size_Y , Mpt2(1,jj)-up_size_X : Mpt2(1,jj)+down_size_X );
        
		% Mittelvalue des Fensters berechnen
        MW2 = mean(Window2(:));
		
		% NCC-value zwichen Pixel j von Bild 2 und Pixel i von Bild 1
        NCC(jj) = sum(sum( (Window1-MW1).*(Window2-MW2) )) / ...
            sqrt( sum(sum( (Window1-MW1).^2 )) * sum(sum( (Window2-MW2).^2 )) );
        
    end
    
	% take the best corespondes in picture 2 to the point ii
	% save
    [value, index] = max(NCC);
    NCC_final(3:4,ii) = Mpt2(1:2, index);
    NCC_final(5,ii) = value;
    
end

% elimnate NCC which are smaller than min_corr
Korrespondenzen = NCC_final(:,NCC_final(5,:)>min_corr);

toc % calculation time
fprintf('Anzahl der Korrezpondezen: %i \n',size(Korrespondenzen,2));
%% Display the correpondences found
if nargin==7
temp = length(Korrespondenzen);
%line drawing for matched pairs
Q= [B1 B2];
figure
imshow(uint8(Q))
hold on;

for i = 1:temp
text( Korrespondenzen(1,i),Korrespondenzen(2,i), num2str(i), 'Color',...
'g','VerticalAlignment','bottom','HorizontalAlignment','left');
text( Korrespondenzen(1,i),Korrespondenzen(2,i), '\bullet', 'Color', 'g','Linewidth',2);


text( Korrespondenzen(3,i)+size(B1,2),Korrespondenzen(4,i), num2str(i), 'Color',...
'r','VerticalAlignment','bottom','HorizontalAlignment','left');
text( Korrespondenzen(3,i)+size(B1,2),Korrespondenzen(4,i), '\bullet', 'Color', 'r','Linewidth',2);

%for drwing the line joining the features
a= [Korrespondenzen(1,i),Korrespondenzen(3,i)+size(B1,2) ];
b= [Korrespondenzen(2,i),Korrespondenzen(4,i)];


line (a, b, 'color', 'b')
end

axis('off');

end