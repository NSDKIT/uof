% 300秒(5分)刻みでデータ成形
N_t=60*30;
row_low=1:N_t:length(PV_Out);
p=PV_Out(row_low).*ones(length(row_low),N_t); % 300秒データ抽出
PVO_5min=reshape(p',[],1); % PV_Outの5分値
PVO_1min=PV_Out;           % PV_Outの1分値

% 残余需要(上側LFC調整力算出用)
Net_demand=Demand_real_year-PV_Out;
Net_demand_forecast=Demand_year-PV_forecast_year;
p=Net_demand(row_low).*ones(length(row_low),N_t); % 300秒データ抽出
% ND_5min=reshape(p',[],1); % PV_Outの5分値
% N_tl=60*10;
% row_low=1:N_tl:length(PV_Out);
% p=Net_demand(row_low).*ones(length(row_low),N_tl); % 300秒データ抽出
% ND_1min=reshape(p',[],1); % PV_Outの5分値
ND_1min=Net_demand;           % PV_Outの1分値

p=Net_demand(row_low).*ones(length(row_low),N_t); % 300秒データ抽出
Net_demand=reshape(p',[],1); % PV_Outの5分値

% 予測誤差(5分値)と変動量(1分値)
%%% 2023.9.20追記 %%%
%%% 残余需要が負の部分はゼロに変換 %%%
Net_demand_forecast(find(Net_demand_forecast<0))=0;
Net_demand(find(Net_demand<0))=0.1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

edc_5min=-Net_demand_forecast+Net_demand;
lfc_1min = movmean(ND_1min,60*5);
lfc_1min=ND_1min-lfc_1min;

% 288行(時刻断面)×362列(日付)にデータ成形
EDC_5min=[];LFC_5min_up=[];LFC_5min_down=[];
PV_f=[];
N_t=86400;N_t0=60*30;
for day = 1:length(edc_5min)/N_t
    data_edc=edc_5min(N_t*(day-1)+1:N_t*day);
    data_lfc=lfc_1min(N_t*(day-1)+1:N_t*day);
    e_5min=[];l_1min_up=[];l_1min_down=[];
    for t0 = 1:48
        e_5min=[e_5min;max(data_edc(N_t0*(t0-1)+1:N_t0*t0))];
        l_1min_up=[l_1min_up;max(data_lfc(N_t0*(t0-1)+1:N_t0*t0))];
        l_1min_down=[l_1min_down;min(data_lfc(N_t0*(t0-1)+1:N_t0*t0))];
    end
    EDC_5min=[EDC_5min,e_5min];
    LFC_5min_up=[LFC_5min_up,l_1min_up];
    LFC_5min_down=[LFC_5min_down,l_1min_down];
    PV_f=[PV_f,PV_forecast_year(N_t*(day-1)+1:N_t*day)];
end
EDC_5min(~isfinite(EDC_5min))=0;
LFC_5min_up(~isfinite(LFC_5min_up))=0;
LFC_5min_down(~isfinite(LFC_5min_down))=0;

%% 機械学習用
% M_E=[29,31,30,31,31,29,30,30,30,31,28,31];
% PVC_Y_r=PVC./[PV_base(4).*ones(1,86400*M_E(1)),...
%     PV_base(5).*ones(1,86400*M_E(2)),...
%     PV_base(6).*ones(1,86400*M_E(3)),...
%     PV_base(7).*ones(1,86400*M_E(4)),...
%     PV_base(8).*ones(1,86400*M_E(5)),...
%     PV_base(9).*ones(1,86400*M_E(6)),...
%     PV_base(10).*ones(1,86400*M_E(7)),...
%     PV_base(11).*ones(1,86400*M_E(8)),...
%     PV_base(12).*ones(1,86400*M_E(9)),...
%     PV_base(1).*ones(1,86400*M_E(10)),...
%     PV_base(2).*ones(1,86400*M_E(11)),...
%     PV_base(3).*ones(1,86400*M_E(12))];