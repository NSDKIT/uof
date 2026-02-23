%% 【重要】実行前の準備
% このスクリプトを実行する前に、以下の準備が必要です。
% 
% 1. 気象庁MSM気象モデルのGPVデータ（.bin）をダウンロードします。
%    - ダウンロード先: https://www.jmbsc.or.jp/jp/online/file/f-online1.html
%    - 対象: MSM 地上 1時間毎
% 
% 2. ダウンロードしたデータを配置するフォルダを決め、そのパスを環境変数に設定します。
%    - 例: setenv("MSM_DATA_DIR", "C:\msm_data")
% 
% 3. wgrib2（.binファイル読み込みツール）をインストールし、そのパスを環境変数に設定します。
%    - 例: setenv("WGRIB2_DIR", "C:\wgrib2")

%% 予測PV出力作成
% 蟷ｴ譛域律繧帝∈謚
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
%% .bin繝輔ぃ繧､繝ｫ蜿門ｾ
search1
%% 蜷繧ｨ繝ｪ繧｢縺ｮ豌ｴ蟷ｳ髱｢蜈ｨ螟ｩ譌･蟆驥丞叙蠕
TDBTDB
irr_forecast=irr_forecast(2:end,:);
data = irr_forecast;
%%%%%%%%%%%% 窶ｻ 遐皮ｩｶ莨夂畑 %%%%%%%%%%%%
for j = 1:2
    AGC_kaisei          % 窶ｻ
%     if j == 1           % 窶ｻ
%         data=data_o;    % 窶ｻ
%     elseif j == 2       % 窶ｻ
%         data=data;      % 窶ｻ
%     end
%% PV髱｢譌･蟆驥上∈螟画鋤
MSM_change_for_agc
%% 譌｢險ｭPV螳ｹ驥
load(["../蝓ｺ譛ｬ繝繝ｼ繧ｿ/PV_base_",num2str(Year),".mat"])
PV_base=[PV_base(end-2:end,3)",PV_base(1:end-3,3)"];
%% 繧ｷ繧ｹ繝繝蜃ｺ蜉帑ｿよ焚
load(["../蝓ｺ譛ｬ繝繝ｼ繧ｿ/PR_",num2str(Year),".mat"])
%% MSM縺ｮ蛟肴焚菫よ焚
load(["../蝓ｺ譛ｬ繝繝ｼ繧ｿ/MSM_bai_",num2str(Year),".mat"])
%% PV髱｢譌･蟆蠑ｷ蠎ｦ縺九ｉPV莠域ｸｬ蜃ｺ蜉帙∈螟画鋤
l=size(IRR.sum);
IRR.sum = [IRR.sum;zeros(2,l(2))];
load("../PVC.mat")
load("../mode.mat")
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
if j ==1                          % 窶ｻ
    PVO_30min=PVF_30min*0.9;
    save PVO_30min.mat PVO_30min; % 窶ｻ
elseif j == 2                     % 窶ｻ
    save PVF_30min.mat PVF_30min; % 窶ｻ
end
%%%%%%%%%%%%%%%%%% Sunny %%%%%%%%%%%%%%%%%%
PVO_30min=PVF_30min;
%%%%%%%%%%%%%%%%%% Ramp-down %%%%%%%%%%%%%%%%%%
PVO_30min=[PVF_30min(1:25);PVO_30min(26:end)];
save PVO_30min.mat PVO_30min; % 窶ｻ
end
