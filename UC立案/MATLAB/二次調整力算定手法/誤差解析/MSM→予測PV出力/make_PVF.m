%%%%%%%%% データの読み込み %%%%%%%%%
load(['PVF_mode',num2str(set),'.mat'])

%%%%%%%%% PV300では欠損日が10月20,21日であるため
%%%%%%%%% 二つの日のデータを除去
t_target = datetime(2018,10,20);day_num = day(t_target,'dayofyear');
s_d=day_num*48-48+1;
PV_forecast_year(s_d:s_d+48*2-1)=[];

%%%%%%%%% PV300は1秒値であるため，30分値を1秒値へ変換 %%%%%%%%%
inter_line_86400(PV_forecast_year)
PV_forecast_year=data';