% clear
p=pwd;
start_date = datetime(2019, 4, 1);end_date = datetime(2020, 3, 31);date_range = start_date:end_date;date_strings = datestr(date_range, 'yyyymmdd');
%% 北陸エリアPV出力実測値の抽出
Demand_real=csv_tieline_PV2019('北陸山元2019');
Demand_real=table2array(Demand_real(2:end,3));
Demand_real(isnan(Demand_real))=[];

for DD = 1:length(date_strings)-1
    year=str2num(date_strings(DD,1:4));
    month=str2num(date_strings(DD,5:6));
    day=str2num(date_strings(DD,7:8));

    Load_origin2019

    D_1sec(DD,:)=demand_1sec;
    D_30min(DD,:)=demand_30min';
end

save('../D_1sec.mat','D_1sec')
save('../D_30min.mat','D_30min')