%% Load.csv/PV_Out.csvの作成（自エリア）
%% 需要
Word=[0 0 0]; %[TIME 自エリア　他エリア]=[0 0 0] 配列作成
T=[1:88200]'; %24時間分の時間配列作成
load('demand_1sec.mat')
Load=[T demand_1sec(1:88200)' demand_1sec(901:89100)']; %[時間 自エリアのデータ]　配列の結合
% ??他エリア??
Load=[Word;Load]; %[時間 自エリア 他エリア]　配列の結合
writematrix(Load,'Load.csv') %Load.csvへの書き込み
%% PV
clear Word
load('PV_1sec.mat')
Word=[0 0]; %[TIME PV出力]=[0 0] 配列作成
PV_1sec(isnan(PV_1sec))=0;
PV_1sec=[PV_1sec;zeros(1798,1)];
PV=[T,PV_1sec]; %[時間 自エリアのデータ]　配列の結合
PV=[Word;PV]; %[時間 自エリア 他エリア]　配列の結合
writematrix(PV,'PV_Out.csv') %PV_Out.csvへの書き込み
clear sum