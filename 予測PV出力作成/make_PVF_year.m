%% 蟷ｴ譛域律繧帝∈謚�
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
%% .bin繝輔ぃ繧､繝ｫ蜿門ｾ�
search1
%% 蜷�繧ｨ繝ｪ繧｢縺ｮ豌ｴ蟷ｳ髱｢蜈ｨ螟ｩ譌･蟆�驥丞叙蠕�
TDBTDB
irr_forecast=irr_forecast(2:end,:);
data = irr_forecast;
%% PV髱｢譌･蟆�驥上∈螟画鋤
MSM_change
% MSM_change_for_agc
%% 譌｢險ｭPV螳ｹ驥�
load(['../蝓ｺ譛ｬ繝�繝ｼ繧ｿ/PV_base_',num2str(Year),'.mat'])
PV_base=[PV_base(end-2:end,3)',PV_base(1:end-3,3)'];
%% 繧ｷ繧ｹ繝�繝�蜃ｺ蜉帑ｿよ焚
load(['../蝓ｺ譛ｬ繝�繝ｼ繧ｿ/PR_',num2str(Year),'.mat'])
%% MSM縺ｮ蛟肴焚菫よ焚
load(['../蝓ｺ譛ｬ繝�繝ｼ繧ｿ/MSM_bai_',num2str(Year),'.mat'])
%% PV髱｢譌･蟆�蠑ｷ蠎ｦ縺九ｉPV莠域ｸｬ蜃ｺ蜉帙∈螟画鋤
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
    n_l=[1,1];
else
    n_l=[1,2];
end

PVF_30min_al=IRR.sum(:,n_l(1))*MSM_bai(Month)*PR(Month)*PV_base(Month)/1000;
PVF_30min_new=IRR.sum(:,n_l(2))*MSM_bai(Month)*PR(Month)*PV_base(Month)/1000;
PV_al=1100;
PVF_30min=PVF_30min_al*PV_al/PV_base(Month)+PVF_30min_new*(PVC-PV_al)/PV_base(Month);
save PVF_30min.mat PVF_30min