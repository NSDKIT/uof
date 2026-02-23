%% 年月日を選択
if year == 2018
    E_D = [31,28,31,30,31,30,31,31,30,31,30,31];
elseif year == 2019
    E_D = [31,29,31,30,31,30,31,31,30,31,30,31];
end
if day == 1
    if month == 1
        Month = 12;
        Day = 31;
    else
        Month = month-1;
        Day = E_D(month-1);
    end
else
    Month = month;
    Day = day-1;
end
if Month > 3
    Year = year;
else
    Year = year+1;
end
%% .binファイル取得
search1
%% 各エリアの水平面全天日射量取得
TDBTDB
irr_forecast=irr_forecast(2:end,:);
data = irr_forecast;
%%%%%%%%%%%% ※ 研究会用 %%%%%%%%%%%%
for j = 1:2
    AGC_kaisei          % ※
%     if j == 1           % ※
%         data=data_o;    % ※
%     elseif j == 2       % ※
%         data=data;      % ※
%     end
%% PV面日射量へ変換
MSM_change_for_agc
%% 既設PV容量
load(['../基本データ/PV_base_',num2str(Year),'.mat'])
PV_base=[PV_base(end-2:end,3)',PV_base(1:end-3,3)'];
%% システム出力係数
load(['../基本データ/PR_',num2str(Year),'.mat'])
%% MSMの倍数係数
load(['../基本データ/MSM_bai_',num2str(Year),'.mat'])
%% PV面日射強度からPV予測出力へ変換
l=size(IRR.sum);
IRR.sum = [IRR.sum;zeros(2,l(2))];
load('../PVC.mat')
load('../mode.mat')
%%%%%%%%%%%%% all change %%%%%%%%%%%%%
% if mode == 1
%     PVF_30min=IRR.sum*MSM_bai(Month)*PR(Month)*PV_base(Month)/1000;
% else
%     PVF_30min=IRR.sum(:,2)*MSM_bai(Month)*PR(Month)*PV_base(Month)/1000;
% end
% PVF_30min=PVF_30min*PVC/PV_base(Month);
%%%%%%%%%%%%% already PV capacity(1100MW) is MS, add capacity is changed %%%%%%%%%%%%%
if mode == 1
    select_num = [1,1];
else
    select_num = [1,2];
end
PVF_30min_al=IRR.sum(:,select_num(1))*MSM_bai(Month)*PR(Month)*PV_base(Month)/1000;
PVF_30min_new=IRR.sum(:,select_num(2))*MSM_bai(Month)*PR(Month)*PV_base(Month)/1000;
PV_al=1100;
PVF_30min=PVF_30min_al*PV_al/PV_base(Month)+PVF_30min_new*(PVC-PV_al)/PV_base(Month);
if mode == 3
    PVF_30min=flip(PVF_30min);
end
save PVF_30min.mat PVF_30min
if j ==1                          % ※
    PVO_30min=PVF_30min*0.9;
    save PVO_30min.mat PVO_30min; % ※
elseif j == 2                     % ※
    save PVF_30min.mat PVF_30min; % ※
end
%%%%%%%%%%%%%%%%%% Sunny %%%%%%%%%%%%%%%%%%
PVO_30min=PVF_30min;
%%%%%%%%%%%%%%%%%% Ramp-down %%%%%%%%%%%%%%%%%%
PVO_30min=[PVF_30min(1:25);PVO_30min(26:end)];
save PVO_30min.mat PVO_30min; % ※
end