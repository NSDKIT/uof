clear;p=pwd;
%% 経緯度の設定
load('ido_keido.mat')
IDO=ido;KEIDO=keido;

LAT = IDO; % 緯度
LAT = fix(LAT)+(LAT-fix(LAT))*100/60; % 緯度の更新
LON = KEIDO; % 経度    
LON = fix(LON)+(LON-fix(LON))*100/60; % 経度の更新

%% 日時情報作成
start_date = datetime(2019, 4, 1);end_date = datetime(2020, 2, 27);date_range = start_date:end_date;date_strings = datestr(date_range, 'yyyymmdd');

%% パラメータ設定
% 傾斜角設定時に3×3配列を作成し，モードに対応する(一軸追尾は傾斜角関係なし)
keisha_kaku = [20;90;90]; % 2行目は両面東・西(m:2,3)
% 方角設定時に3×3配列を作成し，モードに対応する(一軸追尾は方角関係なし)
hougaku = [0;90;270]; % 2行目は両面東(m:2)，3行目は両面西(m:3)
% 時刻断面
t=[1:24]-0.5;
% UTCに対する時差設定時に5×3配列を作成し，モードに対応する
jisa = [9*ones(1,4),9-12];

for DD = 1:length(date_strings)
    %% 日付番号の取得
    year_l=date_strings(DD,1:4);
    month_l=date_strings(DD,5:6);
    day_l=date_strings(DD,7:8);
    %% x: 元旦を1とした年間日付の通し番号[deg]
    t_target = datetime(str2num(year_l),str2num(month_l),str2num(day_l));
    day_num = day(t_target,'dayofyear'); %解析対象日の日付番号を取得
    x = (day_num-1)*360/365;
    
    IRR=0;a=0;
    for area = 1:17
        %% PV300の取得
        data = zeros(1,86401);
        pv300 = get_PV300_1sec(['1秒値\area',num2str(area),'\',num2str(str2double(year_l)),'_',num2str(str2double(month_l)),'\day',num2str(str2double(day_l)),'.csv']);
        data(1:length(pv300))=pv300; % W⇒kW⇒kWh
        % 前15分後15分平均値
        irr_data=[0,mean(reshape(data(1800+1:end-1801),3600,[]))];
        irr_data(find(irr_data<0))=0;
        if (sum(irr_data~=0)==0)==1
            irr_area=zeros(86401,5);
        else
            %% 経緯度取得
            fai = LAT(area);
            keido = LON(area);
            %% ファイル名取得
            GRIB_F=[year_l,'-',month_l,'-',day_l];
            f1=[year_l,'-',month_l,'-',day_l];
            %% 設置方法毎に変換
            change_set_irr_measure
        end
        IRR=IRR+irr_area;
    end
    cd(p)
    irr_mea_data(86401*(DD-1)+1:86401*DD,:)=IRR/17;
end
save('../irr_mea_data.mat','irr_mea_data')