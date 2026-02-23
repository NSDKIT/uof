load('irr_fore_data.mat')
irr_fore_data = irr_fore_data(1:7992, 1);
data1 = reshape(irr_fore_data, 24, []);  % 予測値データ
data1(:,end)=[];

load('irr_mea_data.mat')
irr_mea_data = irr_mea_data(1:3600:end, 1);
irr_mea_data(isnan(irr_mea_data)) = 0;
irr_mea_data = irr_mea_data(1:7992);
data2 = reshape(irr_mea_data, 24, []); % 実測値データ
data2(:,1)=[];

load('D_30min.mat') % 2020/2/14-2020/2/19までは欠損日
data3 = D_30min(1:333, 1:2:48)';
data3(:,1)=[];
[line, row] = find((data3 < 1) + (isnan(data3)));

data1(:, unique(row)) = [];
data2(:, unique(row)) = [];
data3(:, unique(row)) = [];

% 予測誤差を計算して新しい変数を作成
error = (data1 - data2) ./ data3 * 100;
error = sum(error, 'omitnan');

% シーズンごとにデータを分割
T = 24;

% Define a function to check if a date is a weekday (Monday to Friday)
isWeekday = @(date) ~ismember(day(date, 'dayofweek'), [1, 7]); % Sunday=1, Saturday=7
isWeekend = @(date) ismember(day(date, 'dayofweek'), [1, 7]); % Sunday=1, Saturday=7

% Spring
Start = '2019-04-02';
End = '2019-06-30';
spring_dates = datetime(Start):datetime(End);
spring_dates = spring_dates(isWeekday(spring_dates));

% d_spring = day(datetime(Start), 'dayofyear');
% d_end_spring = day(datetime(End), 'dayofyear');
spring_indices = day(spring_dates, 'dayofyear')-90;
d_e_spring = 91;

spring = error(spring_indices);
spring_f = data1(:, spring_indices);
spring_m = data2(:, spring_indices);
spring_dem = data3(:, spring_indices);

% Summer
Start = '2019-07-01';
End = '2019-09-30';
summer_dates = datetime(Start):datetime(End);
summer_dates = summer_dates(isWeekday(summer_dates));

% d_summer = day(datetime(Start), 'dayofyear');
% d_end_summer = day(datetime(End), 'dayofyear');
% summer_indices = d_summer:d_end_summer;
summer_indices = day(summer_dates, 'dayofyear')-90;

summer = error(summer_indices);
summer_f = data1(:, summer_indices);
summer_m = data2(:, summer_indices);
summer_dem = data3(:, summer_indices);

% Fall
Start = '2019-10-01';
End = '2019-12-31';
fall_dates = datetime(Start):datetime(End);
fall_dates = fall_dates(isWeekday(fall_dates));

% d_fall = day(datetime(Start), 'dayofyear');
% d_end_fall = day(datetime(End), 'dayofyear');
% fall_indices = d_fall:d_end_fall;
fall_indices = day(fall_dates, 'dayofyear')-90;

fall = error(fall_indices);
fall_f = data1(:, fall_indices);
fall_m = data2(:, fall_indices);
fall_dem = data3(:, fall_indices);

% Winter
Start = '2020-01-01';
End = '2020-02-13';
winter_dates1 = datetime(Start):datetime(End);
Start = '2020-02-20';
End = '2020-02-26';
winter_dates2 = datetime(Start):datetime(End);
winter_dates = horzcat(winter_dates1,winter_dates2);
winter_dates = winter_dates(isWeekday(winter_dates));

% d_winter = day(datetime(Start), 'dayofyear');
% d_end_winter = day(datetime(End), 'dayofyear');
% winter_indices = d_winter:d_end_winter;
winter_indices = day(winter_dates, 'dayofyear')+275;
winter_indices(find(winter_indices>=326))=winter_indices(find(winter_indices>=326))-6;

winter = error(winter_indices);
winter_f = data1(:, winter_indices);
winter_m = data2(:, winter_indices);
winter_dem = data3(:, winter_indices);

spring_fall = horzcat(spring, fall);
spring_fall_f = horzcat(spring_f, fall_f);
spring_fall_m = horzcat(spring_m, fall_m);
spring_fall_dem = horzcat(spring_dem, fall_dem);

% 各シーズンで最も大きい、最も小さい、中ぐらいの予測誤差を抽出
PVF_season = [];
PVO_season = [];
DEM_season = [];

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
    median_error_spring_fall=median_error_spring_fall-d_e_spring;
else
    % 開始日の指定
    start_date = '2019-04-02';
end
% 加算して目標の日付を算出
spfa_med = datetime(start_date, 'InputFormat', 'yyyy-MM-dd') + days(median_error_spring_fall);

min_error_spring_fall = find(min(spring_fall)==spring_fall);
PVF_season=[PVF_season,spring_fall_f(:,min_error_spring_fall)];
PVO_season=[PVO_season,spring_fall_m(:,min_error_spring_fall)];
DEM_season=[DEM_season,spring_fall_dem(:,min_error_spring_fall)];
if min_error_spring_fall > d_e_spring
    % 開始日の指定
    start_date = '2019-10-01';
    min_error_spring_fall=min_error_spring_fall-d_e_spring;
else
    % 開始日の指定
    start_date = '2019-04-02';
end
% 加算して目標の日付を算出
spfa_min = datetime(start_date, 'InputFormat', 'yyyy-MM-dd') + days(min_error_spring_fall);

%% summer
% 開始日の指定
start_date = '2019-07-01';

max_error_summer = find(max(summer)==summer);
PVF_season=[PVF_season,summer_f(:,max_error_summer)];
PVO_season=[PVO_season,summer_m(:,max_error_summer)];
DEM_season=[DEM_season,summer_dem(:,max_error_summer)];
% 加算して目標の日付を算出
su_max = datetime(start_date, 'InputFormat', 'yyyy-MM-dd') + days(max_error_summer);

% summer=[0,summer];
% median_error_summer = find(median(summer,'omitnan')==summer);
% 絶対値でソート
sorted_abs = sort(abs(summer));
% 絶対値が2番目に最小の要素を取得
second_min_abs_value = sorted_abs(2);
% 対応する元の要素を抽出
median_error_summer = find(abs(summer) == second_min_abs_value);
% median_error_summer = find(abs(summer) == min(abs(summer)));


PVF_season=[PVF_season,summer_f(:,median_error_summer)];
PVO_season=[PVO_season,summer_m(:,median_error_summer)];
DEM_season=[DEM_season,summer_dem(:,median_error_summer)];
start_date = '2019-07-01';
% 加算して目標の日付を算出
su_med = datetime(start_date, 'InputFormat', 'yyyy-MM-dd') + days(median_error_summer);

% summer(1)=[];
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

% winter(1)=[];
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
    plot(PVF_season(:, i));
    plot(PVO_season(:, i));
    plot(DEM_season(:, i));
    sec_time_1hour

    % 曜日の取得
    dayOfWeekNumber = day(target(i), 'dayofweek');
    dayOfWeekString = japaneseDayOfWeek{dayOfWeekNumber};
    title(strjoin([string(target(i)),' (',dayOfWeekString,')']))
    ylim([0,5000])
end