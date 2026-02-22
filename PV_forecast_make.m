%% PV_forecast_make.m
% # 役割
% 気象情報(日射量予測など)からPVの「予測出力」を計算し、`.mat`ファイルとして保存します。
% このスクリプトは、予測誤差分析の最初のステップです。
%
% # 実行方法
%
% ```matlab
% PV_forecast_make(year)
% % (例: PV_forecast_make(2018))
% ```
%
% # 入力
%
% - `data_YYYY.mat`: 日付や時刻などの基本データ
% - `PV_base_YYYY.mat`: 基準となるPV導入量データ
% - `PR_YYYY.mat`: 性能係数(Performance Ratio)データ
% - `Radiation_fcst_YYYY.mat`: 日射量予測データ
%
% # 出力
%
% - `PV_forecast_YYYY.mat`: 計算されたPV予測出力データ
%
% # 次のステップ
%
% このスクリプトで生成されたファイルは、`PV_make.m` や `PV_forecast_error_make.m` で使用されます。

function PV_forecast_make(year)
%% 予測日射量→予測PV出力へ変換(2018,2019済)
load(['PV_base_',num2str(year),'.mat'])        % 各年，各月の基準PV導入量
load(['PR_',num2str(year),'.mat'])             % 各年，各月のシステム出力係数
load(['Radiation_fcst_',num2str(year),'.mat']) % 各年，各月の予測日射量
load(['data_',num2str(year),'.mat'])           % 日付の選択を行うための配列
M = [4:12 1:3];
PV_f = [];
for i = 1:12
    month = M(i);
    a = find(data(:,2)==month);                % 月毎に行番号取得
    b = data_all(a,:);                         % 月毎に日射量抽出
    PV_f = [PV_f;b*PR_value(i)*PV_base(i,3)/1000]; % 予測PV出力＝予測日射量×システム出力係数×基準PV導入量
end
data_all = PV_f;
save(['PV_forecast_',num2str(year),'.mat'],'data_all')
end