load('irr_fore_data.mat')
irr_fore_data=irr_fore_data(1:7992,1);
data1 = reshape(irr_fore_data,24,[]);  % 予測値データ
data1(:,end)=[];

load('irr_mea_data.mat')
irr_mea_data_1sec=irr_mea_data;
irr_mea_data=irr_mea_data(1:3600:end,1);
irr_mea_data(isnan(irr_mea_data))=0;
irr_mea_data=irr_mea_data(1:7992);
data2 = reshape(irr_mea_data,24,[]);  % 実測値データ
data2(:,1)=[];

load('D_30min.mat') % 2020/2/14-2020/2/19までは欠損日
data3=D_30min(1:333,1:2:48)';
data3(:,1)=[];
[line,row]=find((data3<1)+(isnan(data3)));

data1(:,unique(row))=[];
data2(:,unique(row))=[];
data3(:,unique(row))=[];

% 予測誤差を計算して新しい変数を作成
error = (data1 - data2);
error = sum(error,'omitnan');

% シーズンごとにデータを分割
T=24;
%% spring
Start = '2019-04-02';
t_target = datetime(Start);
d_s = day(t_target,'dayofyear')-90;
End = '2019-06-30';
t_target = datetime(End);
d_e = day(t_target,'dayofyear')-90;

spring = error((d_s-1)+1:d_e);
spring_f = data1(:,(d_s-1)+1:d_e);
spring_m = data2(:,(d_s-1)+1:d_e);
spring_dem = data3(:,(d_s-1)+1:d_e);
d_e_spring=d_e;
%% summer
Start = '2019-07-01';
t_target = datetime(Start);
d_s = day(t_target,'dayofyear')-90;
End = '2019-09-30';
t_target = datetime(End);
d_e = day(t_target,'dayofyear')-90;

summer = error((d_s-1)+1:d_e);
summer_f = data1(:,(d_s-1)+1:d_e);
summer_m = data2(:,(d_s-1)+1:d_e);
summer_dem = data3(:,(d_s-1)+1:d_e);
%% fall
Start = '2019-10-01';
t_target = datetime(Start);
d_s = day(t_target,'dayofyear')-90;
End = '2019-12-31';
t_target = datetime(End);
d_e = day(t_target,'dayofyear')-90;

fall = error((d_s-1)+1:d_e);
fall_f = data1(:,(d_s-1)+1:d_e);
fall_m = data2(:,(d_s-1)+1:d_e);
fall_dem = data3(:,(d_s-1)+1:d_e);
%% winter
Start = '2020-01-01';
t_target = datetime(Start);
d_s = day(t_target,'dayofyear')+275;
End = '2020-02-26';
t_target = datetime(End)-6; % 欠損日分(6日間を除算)
d_e = day(t_target,'dayofyear')+275;

winter = error((d_s-1)+1:d_e);
winter_f = data1(:,(d_s-1)+1:d_e);
winter_m = data2(:,(d_s-1)+1:d_e);
winter_dem = data3(:,(d_s-1)+1:d_e);

spring_fall = horzcat(spring,fall);
spring_fall_f = horzcat(spring_f,fall_f);
spring_fall_m = horzcat(spring_m,fall_m);
spring_fall_dem = horzcat(spring_dem,fall_dem);

% 各シーズンで最も大きい、最も小さい、中ぐらいの予測誤差を抽出
PVF_season=[];
PVO_season=[];
DEM_season=[];
%% spring&fall
max_error_spring_fall = find(max(spring_fall)==spring_fall);
PVF_season=[PVF_season,spring_fall_f(:,max_error_spring_fall)];
PVO_season=[PVO_season,spring_fall_m(:,max_error_spring_fall)];
DEM_season=[DEM_season,spring_fall_dem(:,max_error_spring_fall)];
if max_error_spring_fall > d_e_spring
    % 開始日の指定
    start_date = '2019-10-01';
    max_error_spring_fall=max_error_spring_fall-d_e_spring;
else
    % 開始日の指定
    start_date = '2019-04-02';
end
% 加算して目標の日付を算出
spfa_max = datetime(start_date, 'InputFormat', 'yyyy-MM-dd') + days(max_error_spring_fall);

% median_error_spring_fall = find(median(spring_fall,'omitnan')==spring_fall);
median_error_spring_fall = find(abs(spring_fall) == min(abs(spring_fall)));

PVF_season=[PVF_season,spring_fall_f(:,median_error_spring_fall)];
PVO_season=[PVO_season,spring_fall_m(:,median_error_spring_fall)];
DEM_season=[DEM_season,spring_fall_dem(:,median_error_spring_fall)];
if median_error_spring_fall > d_e_spring
    % 開始日の指定
    start_date = '2019-10-01';
    median_error_spring_fall=median_error_spring_fall-d_e_spring+1;
else
    % 開始日の指定
    start_date = '2019-04-02';
end
% 加算して目標の日付を算出
spfa_med = datetime(start_date, 'InputFormat', 'yyyy-MM-dd') + days(median_error_spring_fall);

spring_fall([48])=nan;
min_error_spring_fall = find(min(spring_fall)==spring_fall);
PVF_season=[PVF_season,spring_fall_f(:,min_error_spring_fall)];
PVO_season=[PVO_season,spring_fall_m(:,min_error_spring_fall)];
DEM_season=[DEM_season,spring_fall_dem(:,min_error_spring_fall)];
if min_error_spring_fall > d_e_spring
    % 開始日の指定
    start_date = '2019-10-01';
    min_error_spring_fall=min_error_spring_fall-d_e_spring+1;
else
    % 開始日の指定
    start_date = '2019-04-02';
end
% 加算して目標の日付を算出
spfa_min = datetime(start_date, 'InputFormat', 'yyyy-MM-dd') + days(min_error_spring_fall);

%% summer
% 開始日の指定
start_date = '2019-07-01';

summer(14)=nan;
max_error_summer = find(max(summer)==summer);
PVF_season=[PVF_season,summer_f(:,max_error_summer)];
PVO_season=[PVO_season,summer_m(:,max_error_summer)];
DEM_season=[DEM_season,summer_dem(:,max_error_summer)];
% 加算して目標の日付を算出
su_max = datetime(start_date, 'InputFormat', 'yyyy-MM-dd') + days(max_error_summer);

% summer=[0,summer];
% median_error_summer = find(median(summer,'omitnan')==summer);
median_error_summer = find(abs(summer) == min(abs(summer)));
PVF_season=[PVF_season,summer_f(:,median_error_summer)];
PVO_season=[PVO_season,summer_m(:,median_error_summer)];
DEM_season=[DEM_season,summer_dem(:,median_error_summer)];
start_date = '2019-07-01';
% 加算して目標の日付を算出
su_med = datetime(start_date, 'InputFormat', 'yyyy-MM-dd') + days(median_error_summer);

% summer(1)=[];
summer(28)=nan; % 本来は，28番目が最も上振れしている日だが，重負荷で最適化できないため，二番目に上振れしている日を選択するために，28番目をnanにしている
min_error_summer = find(min(summer)==summer);
PVF_season=[PVF_season,summer_f(:,min_error_summer)];
PVO_season=[PVO_season,summer_m(:,min_error_summer)];
DEM_season=[DEM_season,summer_dem(:,min_error_summer)];
% 加算して目標の日付を算出
su_min = datetime(start_date, 'InputFormat', 'yyyy-MM-dd') + days(min_error_summer);

%% winter
% 開始日の指定
start_date = '2020-01-01';

max_error_winter = find(max(winter)==winter);
PVF_season=[PVF_season,winter_f(:,max_error_winter)];
PVO_season=[PVO_season,winter_m(:,max_error_winter)];
DEM_season=[DEM_season,winter_dem(:,max_error_winter)];
% 加算して目標の日付を算出
wi_max = datetime(start_date, 'InputFormat', 'yyyy-MM-dd') + days(max_error_winter);

% winter=[0,winter];
% median_error_winter = find(median(winter,'omitnan')==winter);
median_error_winter = find(abs(winter) == min(abs(winter)));
PVF_season=[PVF_season,winter_f(:,median_error_winter)];
PVO_season=[PVO_season,winter_m(:,median_error_winter)];
DEM_season=[DEM_season,winter_dem(:,median_error_winter)];
% 加算して目標の日付を算出
wi_med = datetime(start_date, 'InputFormat', 'yyyy-MM-dd') + days(median_error_winter);

winter([8:9,32,34,16])=nan;
min_error_winter = find(min(winter)==winter);
PVF_season=[PVF_season,winter_f(:,min_error_winter)];
PVO_season=[PVO_season,winter_m(:,min_error_winter)];
DEM_season=[DEM_season,winter_dem(:,min_error_winter)];
% 加算して目標の日付を算出
wi_min = datetime(start_date, 'InputFormat', 'yyyy-MM-dd') + days(min_error_winter);

spfa=horzcat(spfa_max,spfa_med,spfa_min);
su=horzcat(su_max,su_med,su_min);
wi=horzcat(wi_max,wi_med,wi_min);

target=horzcat(spfa,su,wi);

% subplotの設定
figure;

% 各列をplot
% 数字から日本語の曜日に変換
japaneseDayOfWeek = {'日', '月', '火', '水', '木', '金', '土'};
for i = 1:9
    subplot(3, 3, i);
    hold on
    plot(PVF_season(:, i),'LineWidth',2);
    plot(PVO_season(:, i),'LineWidth',2);
    % plot(DEM_season(:, i),'LineWidth',2);
    sec_time_1hour

    % 曜日の取得
    dayOfWeekNumber = day(target(i), 'dayofweek');
    dayOfWeekString = japaneseDayOfWeek{dayOfWeekNumber};
    title(strjoin([string(target(i)),' (',dayOfWeekString,')']))
    ylim([0,1000])
end