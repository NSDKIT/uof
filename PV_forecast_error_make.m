%% PV_forecast_error_make.m
% # 役割
% 「予測PV出力」と「実績PV出力」の差分から「予測誤差」を計算し、`.mat`ファイルとして保存します。
% このスクリプトは、予測誤差分析の核心部分です。
%
% # 実行方法
%
% ```matlab
% PV_forecast_error_make(year)
% % (例: PV_forecast_error_make(2018))
% ```
%
% # 前提条件
%
% - `PV_forecast_make.m` の実行が完了していること。
% - `PV_make.m` の実行が完了していること。
%
% # 入力
%
% - `PV_forecast_YYYY.mat`: PV予測出力データ
% - `PV_YYYY.mat`: PV実績出力データ
% - `Load_YYYY.mat`: 電力需要(負荷)データ
% - `PV_base_YYYY.mat`: 基準となるPV導入量データ
%
% # 出力
%
% - `ERROR_YYYY.mat`: 計算されたPV予測誤差データ
%
% # 次のステップ
%
% このスクリプトで生成された `ERROR_YYYY.mat` は、以下の詳細分析スクリプトで使用されます。
%   - `PV_forecast_error_PVup_make.m`
%   - `SIGMA_get.m` / `mode1_no_sigma.m`

function PV_forecast_error_make(year)
%% 基準PV導入量でのPV出力予測誤差
data_all = [];
if year == 2018
    L_D = 365;
elseif year == 2019
    L_D = 366;
end
load(['PV_base_',num2str(year),'.mat'])     % 資源エネルギー庁より作成
load(['PV_forecast_',num2str(year),'.mat']) % PV_forecast_makeより作成
PV_f = data_all(:,1:48);
load(['PV_',num2str(year),'.mat'])          % PV_makeより作成
PV_o = data_all;
load(['Load_',num2str(year),'.mat'])        % 北陸電力提供データより作成
Lo = data_all;

E = [];
for day = 1:L_D
    data1 = PV_f(day,:);
    data2 = PV_o(day,:);
    data3 = Lo(day,:);
    E = [E;(data1-data2)./data3*100];
end
ERROR = [E zeros(L_D,2)];
save(['ERROR_',num2str(year),'.mat'],'ERROR')
end
