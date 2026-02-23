load('irr_fore_data.mat')
irr_fore_data=irr_fore_data(1:7992,1);
data1 = reshape(irr_fore_data,24,[]);  % 莠域ｸｬ蛟､繝�繝ｼ繧ｿ
data1(:,end)=[];

load('irr_mea_data.mat')
irr_mea_data_1sec=irr_mea_data;
irr_mea_data=irr_mea_data(1:3600:end,1);
irr_mea_data(isnan(irr_mea_data))=0;
irr_mea_data=irr_mea_data(1:7992);
data2 = reshape(irr_mea_data,24,[]);  % 螳滓ｸｬ蛟､繝�繝ｼ繧ｿ
data2(:,1)=[];

load('D_30min.mat') % 2020/2/14-2020/2/19縺ｾ縺ｧ縺ｯ谺�謳肴律
data3=D_30min(1:333,1:2:48)';
data3(:,1)=[];
[line,row]=find((data3<1)+(isnan(data3)));

data1(:,unique(row))=[];
data2(:,unique(row))=[];
data3(:,unique(row))=[];

% 莠域ｸｬ隱､蟾ｮ繧定ｨ育ｮ励＠縺ｦ譁ｰ縺励＞螟画焚繧剃ｽ懈��
error = (data1 - data2);
error = sum(error,'omitnan');

% 繧ｷ繝ｼ繧ｺ繝ｳ縺斐→縺ｫ繝�繝ｼ繧ｿ繧貞��蜑ｲ
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
t_target = datetime(End)-6; % 谺�謳肴律蛻�(6譌･髢薙ｒ髯､邂�)
d_e = day(t_target,'dayofyear')+275;

winter = error((d_s-1)+1:d_e);
winter_f = data1(:,(d_s-1)+1:d_e);
winter_m = data2(:,(d_s-1)+1:d_e);
winter_dem = data3(:,(d_s-1)+1:d_e);

spring_fall = horzcat(spring,fall);
spring_fall_f = horzcat(spring_f,fall_f);
spring_fall_m = horzcat(spring_m,fall_m);
spring_fall_dem = horzcat(spring_dem,fall_dem);

% 蜷�繧ｷ繝ｼ繧ｺ繝ｳ縺ｧ譛�繧ょ､ｧ縺阪＞縲∵怙繧ょｰ上＆縺�縲∽ｸｭ縺舌ｉ縺�縺ｮ莠域ｸｬ隱､蟾ｮ繧呈歓蜃ｺ
PVF_season=[];
PVO_season=[];
DEM_season=[];
%% spring&fall
max_error_spring_fall = find(max(spring_fall)==spring_fall);
PVF_season=[PVF_season,spring_fall_f(:,max_error_spring_fall)];
PVO_season=[PVO_season,spring_fall_m(:,max_error_spring_fall)];
DEM_season=[DEM_season,spring_fall_dem(:,max_error_spring_fall)];
if max_error_spring_fall > d_e_spring
    % 髢句ｧ区律縺ｮ謖�螳�
    start_date = '2019-10-01';
    max_error_spring_fall=max_error_spring_fall-d_e_spring;
else
    % 髢句ｧ区律縺ｮ謖�螳�
    start_date = '2019-04-02';
end
% 蜉�邂励＠縺ｦ逶ｮ讓吶�ｮ譌･莉倥ｒ邂怜�ｺ
spfa_max = datetime(start_date, 'InputFormat', 'yyyy-MM-dd') + days(max_error_spring_fall);

% median_error_spring_fall = find(median(spring_fall,'omitnan')==spring_fall);
median_error_spring_fall = find(abs(spring_fall) == min(abs(spring_fall)));

PVF_season=[PVF_season,spring_fall_f(:,median_error_spring_fall)];
PVO_season=[PVO_season,spring_fall_m(:,median_error_spring_fall)];
DEM_season=[DEM_season,spring_fall_dem(:,median_error_spring_fall)];
if median_error_spring_fall > d_e_spring
    % 髢句ｧ区律縺ｮ謖�螳�
    start_date = '2019-10-01';
    median_error_spring_fall=median_error_spring_fall-d_e_spring+1;
else
    % 髢句ｧ区律縺ｮ謖�螳�
    start_date = '2019-04-02';
end
% 蜉�邂励＠縺ｦ逶ｮ讓吶�ｮ譌･莉倥ｒ邂怜�ｺ
spfa_med = datetime(start_date, 'InputFormat', 'yyyy-MM-dd') + days(median_error_spring_fall);

spring_fall([48])=nan;
min_error_spring_fall = find(min(spring_fall)==spring_fall);
PVF_season=[PVF_season,spring_fall_f(:,min_error_spring_fall)];
PVO_season=[PVO_season,spring_fall_m(:,min_error_spring_fall)];
DEM_season=[DEM_season,spring_fall_dem(:,min_error_spring_fall)];
if min_error_spring_fall > d_e_spring
    % 髢句ｧ区律縺ｮ謖�螳�
    start_date = '2019-10-01';
    min_error_spring_fall=min_error_spring_fall-d_e_spring+1;
else
    % 髢句ｧ区律縺ｮ謖�螳�
    start_date = '2019-04-02';
end
% 蜉�邂励＠縺ｦ逶ｮ讓吶�ｮ譌･莉倥ｒ邂怜�ｺ
spfa_min = datetime(start_date, 'InputFormat', 'yyyy-MM-dd') + days(min_error_spring_fall);

%% summer
% 髢句ｧ区律縺ｮ謖�螳�
start_date = '2019-07-01';

summer(14)=nan;
max_error_summer = find(max(summer)==summer);
PVF_season=[PVF_season,summer_f(:,max_error_summer)];
PVO_season=[PVO_season,summer_m(:,max_error_summer)];
DEM_season=[DEM_season,summer_dem(:,max_error_summer)];
% 蜉�邂励＠縺ｦ逶ｮ讓吶�ｮ譌･莉倥ｒ邂怜�ｺ
su_max = datetime(start_date, 'InputFormat', 'yyyy-MM-dd') + days(max_error_summer);

% summer=[0,summer];
% median_error_summer = find(median(summer,'omitnan')==summer);
median_error_summer = find(abs(summer) == min(abs(summer)));
PVF_season=[PVF_season,summer_f(:,median_error_summer)];
PVO_season=[PVO_season,summer_m(:,median_error_summer)];
DEM_season=[DEM_season,summer_dem(:,median_error_summer)];
start_date = '2019-07-01';
% 蜉�邂励＠縺ｦ逶ｮ讓吶�ｮ譌･莉倥ｒ邂怜�ｺ
su_med = datetime(start_date, 'InputFormat', 'yyyy-MM-dd') + days(median_error_summer);

% summer(1)=[];
summer(28)=nan; % 譛ｬ譚･縺ｯ�ｼ�28逡ｪ逶ｮ縺梧怙繧ゆｸ頑険繧後＠縺ｦ縺�繧区律縺�縺鯉ｼ碁�崎ｲ�闕ｷ縺ｧ譛�驕ｩ蛹悶〒縺阪↑縺�縺溘ａ�ｼ御ｺ檎分逶ｮ縺ｫ荳頑険繧後＠縺ｦ縺�繧区律繧帝∈謚槭☆繧九◆繧√↓�ｼ�28逡ｪ逶ｮ繧地an縺ｫ縺励※縺�繧�
min_error_summer = find(min(summer)==summer);
PVF_season=[PVF_season,summer_f(:,min_error_summer)];
PVO_season=[PVO_season,summer_m(:,min_error_summer)];
DEM_season=[DEM_season,summer_dem(:,min_error_summer)];
% 蜉�邂励＠縺ｦ逶ｮ讓吶�ｮ譌･莉倥ｒ邂怜�ｺ
su_min = datetime(start_date, 'InputFormat', 'yyyy-MM-dd') + days(min_error_summer);

%% winter
% 髢句ｧ区律縺ｮ謖�螳�
start_date = '2020-01-01';

max_error_winter = find(max(winter)==winter);
PVF_season=[PVF_season,winter_f(:,max_error_winter)];
PVO_season=[PVO_season,winter_m(:,max_error_winter)];
DEM_season=[DEM_season,winter_dem(:,max_error_winter)];
% 蜉�邂励＠縺ｦ逶ｮ讓吶�ｮ譌･莉倥ｒ邂怜�ｺ
wi_max = datetime(start_date, 'InputFormat', 'yyyy-MM-dd') + days(max_error_winter);

% winter=[0,winter];
% median_error_winter = find(median(winter,'omitnan')==winter);
median_error_winter = find(abs(winter) == min(abs(winter)));
PVF_season=[PVF_season,winter_f(:,median_error_winter)];
PVO_season=[PVO_season,winter_m(:,median_error_winter)];
DEM_season=[DEM_season,winter_dem(:,median_error_winter)];
% 蜉�邂励＠縺ｦ逶ｮ讓吶�ｮ譌･莉倥ｒ邂怜�ｺ
wi_med = datetime(start_date, 'InputFormat', 'yyyy-MM-dd') + days(median_error_winter);

winter([8:9,32,34,16])=nan;
min_error_winter = find(min(winter)==winter);
PVF_season=[PVF_season,winter_f(:,min_error_winter)];
PVO_season=[PVO_season,winter_m(:,min_error_winter)];
DEM_season=[DEM_season,winter_dem(:,min_error_winter)];
% 蜉�邂励＠縺ｦ逶ｮ讓吶�ｮ譌･莉倥ｒ邂怜�ｺ
wi_min = datetime(start_date, 'InputFormat', 'yyyy-MM-dd') + days(min_error_winter);

spfa=horzcat(spfa_max,spfa_med,spfa_min);
su=horzcat(su_max,su_med,su_min);
wi=horzcat(wi_max,wi_med,wi_min);

target=horzcat(spfa,su,wi);

% subplot縺ｮ險ｭ螳�
figure;

% 蜷�蛻励ｒplot
% 謨ｰ蟄励°繧画律譛ｬ隱槭�ｮ譖懈律縺ｫ螟画鋤
japaneseDayOfWeek = {'譌･', '譛�', '轣ｫ', '豌ｴ', '譛ｨ', '驥�', '蝨�'};
for i = 1:9
    subplot(3, 3, i);
    hold on
    plot(PVF_season(:, i),'LineWidth',2);
    plot(PVO_season(:, i),'LineWidth',2);
    % plot(DEM_season(:, i),'LineWidth',2);
    sec_time_1hour

    % 譖懈律縺ｮ蜿門ｾ�
    dayOfWeekNumber = day(target(i), 'dayofweek');
    dayOfWeekString = japaneseDayOfWeek{dayOfWeekNumber};
    title(strjoin([string(target(i)),' (',dayOfWeekString,')']))
    ylim([0,1000])
end