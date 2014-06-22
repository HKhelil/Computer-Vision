
function[KalibKorr] = calibrate_correspondences(Korrespondenzen)

%  Matrix K uploaden
op = fopen('Matrizen/K','r+');
% read and change to double
K = fscanf(op,'%f %f %f',[3 inf]);
%re-transpose
K = K';
fclose(op);

Kinv = inv(K);

% Output Matrix
KalibKorr = zeros(4,length(Korrespondenzen));

for i = 1:length(Korrespondenzen)
   xkalib1 = Kinv*[Korrespondenzen(1,i), Korrespondenzen(2,i), 1]';
   xkalib2 = Kinv*[Korrespondenzen(3,i), Korrespondenzen(4,i), 1]';
   KalibKorr(1:2,i) = xkalib1(1:2);
   KalibKorr(3:4,i) = xkalib2(1:2);
end

end