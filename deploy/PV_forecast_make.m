%% =========================================================
%  PV_forecast_make.m  ―  予測PV出力データの生成
%  =========================================================
%
%  【役割】
%    気象情報（日射量予測）と設備情報（基準PV導入量・性能係数）から
%    PVの「予測出力」を計算し、.mat ファイルとして保存する。
%    これはデータ生成チェーンの【Step 1】。
%
%  【実行方法】
%    >> PV_forecast_make(2018)
%    >> PV_forecast_make(2019)
%
%  【フォルダ構成の前提】
%    このスクリプトは deploy/ フォルダをカレントディレクトリとして実行する。
%    入力ファイルは deploy/input_data/ に、出力は deploy/output/ に保存される。
%
%  【入力ファイル（input_data/ フォルダに配置すること）】
%    ┌──────────────────────────────┬──────────────────────────────────────┐
%    │ ファイル名                   │ 内容                                 │
%    ├──────────────────────────────┼──────────────────────────────────────┤
%    │ data_YYYY.mat                │ 日付配列（変数: data）               │
%    │ PV_base_YYYY.mat             │ 各月の基準PV導入量 [MW]（変数: PV_base）│
%    │ PR_YYYY.mat                  │ 各月のシステム性能係数（変数: PR_value）│
%    │ Radiation_fcst_YYYY.mat      │ 予測日射量 [W/m²]（変数: data_all）  │
%    └──────────────────────────────┴──────────────────────────────────────┘
%
%  【出力ファイル（output/ フォルダに保存される）】
%    output/PV_forecast_YYYY.mat  （変数: data_all → 予測PV出力 [MW]）
%
%  【次のステップ（このファイルを使う処理）】
%    → PV_forecast_error_make(year)  （Step 3: 予測誤差の計算）
%    → PV_compare(year, month, bai)  （可視化）
%
%  【計算式】
%    予測PV出力 [MW] = 予測日射量 × PR値 × 基準PV導入量 / 1000
%
%  【注意事項】
%    - 年度は4月始まり（M = [4:12 1:3]）で処理される。
% =========================================================

function PV_forecast_make(year)

%% --- データ読み込み（相対パス: input_data フォルダ） ---
load(fullfile('input_data', ['PV_base_',num2str(year),'.mat']))        % 変数: PV_base  → 各月の基準PV導入量 [MW]
load(fullfile('input_data', ['PR_',num2str(year),'.mat']))             % 変数: PR_value → 各月のシステム性能係数
load(fullfile('input_data', ['Radiation_fcst_',num2str(year),'.mat'])) % 変数: data_all → 予測日射量 [W/m²]
load(fullfile('input_data', ['data_',num2str(year),'.mat']))           % 変数: data     → 日付配列 [年, 月, 日, ...]

%% --- 月順序の定義（4月始まり） ---
M = [4:12 1:3];

%% --- 月ごとに予測PV出力を計算 ---
PV_f = [];
for i = 1:12
    month = M(i);
    a = find(data(:,2)==month);                    % 当月の行番号を取得
    b = data_all(a,:);                             % 当月の予測日射量を抽出
    % 予測PV出力 [MW] = 日射量 × PR値 × 基準導入量 / 1000
    PV_f = [PV_f; b * PR_value(i) * PV_base(i,3) / 1000];
end

%% --- 結果の保存（相対パス: output フォルダ） ---
data_all = PV_f;
save(fullfile('output', ['PV_forecast_',num2str(year),'.mat']), 'data_all')
% → 保存先: output/PV_forecast_YYYY.mat

end
