%% =========================================================
%  PV_forecast_error_make.m  ―  基準PV導入量での予測誤差の計算
%  =========================================================
%
%  【役割】
%    「予測PV出力」と「実績PV出力」の差分を電力需要（負荷）で割り、
%    予測誤差率 [%] を計算して保存する。
%    このスクリプトは予測誤差分析チェーンの【3番目・核心ステップ】。
%    ここで生成される ERROR_YYYY.mat が、以降の全分析の基礎となる。
%
%  【実行方法】
%    >> PV_forecast_error_make(2018)   % 2018年度分を生成
%    >> PV_forecast_error_make(2019)   % 2019年度分を生成
%
%  【前提条件（先に実行しておくこと）】
%    1. PV_forecast_make(year)  → PV_forecast_YYYY.mat が存在すること
%    2. PV_make(year)           → PV_YYYY.mat が存在すること
%
%  【入力ファイル（事前に同フォルダへ配置すること）】
%    ┌──────────────────────────┬──────────────────────────────────────┐
%    │ ファイル名               │ 内容                                 │
%    ├──────────────────────────┼──────────────────────────────────────┤
%    │ PV_forecast_YYYY.mat     │ PV予測出力 [MW]（PV_forecast_makeで生成）│
%    │ PV_YYYY.mat              │ PV実績出力 [MW]（PV_makeで生成）     │
%    │ Load_YYYY.mat            │ 電力需要（負荷）データ [MW]          │
%    │ PV_base_YYYY.mat         │ 基準PV導入量データ（月別）           │
%    └──────────────────────────┴──────────────────────────────────────┘
%
%  【出力ファイル】
%    ERROR_YYYY.mat  ← 変数 ERROR に予測誤差率 [%] を格納
%      ・サイズ: [日数 × 50列]（48列が30分×48コマ分の誤差、末尾2列は予備ゼロ）
%      ・計算式: ERROR = (予測 - 実績) / 負荷 × 100 [%]
%
%  【次のステップ（このファイルを使う処理）】
%    → PV_forecast_error_PVup_make.m  （容量別・日別誤差の生成）
%    → SIGMA_get.m / SIGMA_get1.m     （σ計算）
%    → mode1_no_sigma.m               （帯域別σ計算・補助スクリプト）
%
%  【注意事項】
%    - 2018年は365日、2019年は366日（うるう年）として処理される。
%    - 誤差の符号は「予測 > 実績」のとき正（予測が過大）。
% =========================================================

function PV_forecast_error_make(year)

%% --- 日数の設定 ---
if year == 2018
    L_D = 365;
elseif year == 2019
    L_D = 366;  % 2019年度は4月始まりで2020年3月末まで → うるう年（2020年2月）を含む
end

%% --- データ読み込み ---
load(fullfile('input_data', ['PV_base_',num2str(year),'.mat']))      % 変数: PV_base → 基準PV導入量（月別）
load(fullfile('output', ['PV_forecast_',num2str(year),'.mat']))       % 変数: data_all → PV予測出力 [MW]
PV_f = data_all(:, 1:48);                    % 30分×48コマ分のみ抽出（予測値）

load(fullfile('output', ['PV_',num2str(year),'.mat']))                % 変数: data_all → PV実績出力 [MW]
PV_o = data_all;                             % 実績値

load(fullfile('input_data', ['Load_',num2str(year),'.mat']))         % 変数: data_all → 電力需要 [MW]
Lo = data_all;                               % 負荷データ

%% --- 日ごとに予測誤差率を計算 ---
% 計算式: ERROR [%] = (予測 - 実績) / 負荷 × 100
E = [];
for day = 1:L_D
    data1 = PV_f(day,:);   % 当日の予測PV出力
    data2 = PV_o(day,:);   % 当日の実績PV出力
    data3 = Lo(day,:);     % 当日の電力需要
    E = [E; (data1 - data2) ./ data3 * 100];
end

%% --- 出力ファイルへ保存 ---
ERROR = [E zeros(L_D, 2)];  % 末尾2列にゼロを追加（50列に統一）
save(fullfile('output', ['ERROR_',num2str(year),'.mat']), 'ERROR')
% → 保存先: output/ERROR_YYYY.mat（変数名: ERROR、サイズ: [日数 × 50]）

end
