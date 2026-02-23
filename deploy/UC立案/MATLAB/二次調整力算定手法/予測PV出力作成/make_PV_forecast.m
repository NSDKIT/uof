load(['PVF_mode',num2str(mode),'.mat'])
% 欠損日(20,21日)のデータを除去
t_target = datetime(2018,10,20);day_num = day(t_target,'dayofyear');
s_d=day_num*48-48+1;
PV_forecast_year(s_d:s_d+48*2-1)=[];

% 1秒値を算出するための線形補間
x = 1/1800:1:length(PV_forecast_year); 
v = PV_forecast_year;
xq = 1/1800:1/1800:length(PV_forecast_year);
PV_forecast_year_line = interp1(x,v,xq);
PV_forecast_year_line =PV_forecast_year_line';
% 5分値を算出するための一定値
PV_forecast_year=reshape((PV_forecast_year.*...
    ones(length(PV_forecast_year),1800))',[length(PV_forecast_year)*1800,1]);