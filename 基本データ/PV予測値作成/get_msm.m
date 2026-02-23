clear;p=pwd;
%% 経緯度の設定
load('ido_keido.mat')
IDO=ido;KEIDO=keido;

LAT = IDO; % 緯度
LAT = fix(LAT)+(LAT-fix(LAT))*100/60; % 緯度の更新
LON = KEIDO; % 経度    
LON = fix(LON)+(LON-fix(LON))*100/60; % 経度の更新

%% 日時情報作成
start_date = datetime(2019, 4, 1);end_date = datetime(2020, 3, 31);date_range = start_date:end_date;date_strings = datestr(date_range, 'yyyymmdd');

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
        %% 経緯度取得
        fai = LAT(area);
        keido = LON(area);
        %% ファイル名取得
        GRIB_F=[year_l,'-',month_l,'-',day_l];
        f1=[year_l,'-',month_l,'-',day_l];
        %% 日射量取得
        get_irr
        %% 設置方法毎に変換
        change_set_irr

        IRR=IRR+irr_area;
    end
    cd(p)
    all_data(:,DD)=a/17;
    irr_fore_data(24*(DD-1)+1:24*DD,:)=IRR/17;
end

%% 配列変換（行：日時，列：要素）
X=[];x=0:.5:24.5;
msm_data=[];
for DD=1:length(date_range)
    d1=reshape(all_data(11:end,DD),12,39);
    d1=[[all_data(1:10,DD);zeros(2,1)],d1];
    d3=zeros(50,12);
    for n=1:12
        d2=d1(n,16:40);
        d3(:,n)=reshape(interp1(0:24,d2',x,'linear'),[],1);
    end
    msm_data=[msm_data;d3(1:48,:)];
end
save msm_data.mat msm_data
save('../irr_fore_data.mat','irr_fore_data')