% -- 予測PV出力 --
    % 余剰分は除去
    Sur=(sum(UC_planning')+PVF_30min'+(sum(sum(Const_Out(:,2:end)))/(length(Const_Out)-1)))-demand_30min';
    Sur(find(Sur<=0))=0;
    PVF_30min=PVF_30min-Sur';
% -- 続き
PV_Forecast=zeros(88202,2);
PV_Forecast(2:end,1)=0:88200;
x = 0:0.5:24.5;xq_1min = 1/3600:1/3600:24.5;
v=PVF_30min;
PV_Forecast(3:end,2) = interp1(x,v,xq_1min);
% -- 予測需要 --
Load_Forecast=zeros(88202,2);
Load_Forecast(2:end,1)=0:88200;
x = 0:0.5:24.5;xq_1min = 1/3600:1/3600:24.5;
v=demand_30min;
Load_Forecast(2,2) = v(1);
Load_Forecast(3:end,2) = interp1(x,v,xq_1min);