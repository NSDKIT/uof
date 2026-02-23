%% PV作成
disp('シミュレーション実行のためのPV作成')
load('pv.mat')
if pv == 0
    origin_PV=zeros(86400,1);
    save('origin_PV.mat','origin_PV')
else
    if year == 2018
        PV_origin2018           %PV曲線の選択，短周期変動の外挿
    else
        PV_origin2019           %PV曲線の選択，短周期変動の外挿
%         PV_origin2019_for_agc
    end
end