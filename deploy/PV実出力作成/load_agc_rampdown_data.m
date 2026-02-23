%% 【重要】実行前の準備
% このスクリプトを実行する前に、以下のファイルを準備する必要があります。
%
% 必要なファイル:
%   - PV_ランプダウン.xlsx  （AGC30用PVランプダウンデータ）
%
% 配置先:
%   ROOT_DIR/PV実出力作成/AGC_データ/ フォルダに配置してください。
%
% また、get_PVstandard 関数が MATLAB パス上に存在する必要があります。
%% AGC30用PVデータ読み込み
p = pwd;
% AGCデータフォルダのパス（ROOT_DIR は model.m で設定される）
agc_data_dir = fullfile(ROOT_DIR, 'PV実出力作成', 'AGC_データ');
if ~exist(agc_data_dir, 'dir')
    mkdir(agc_data_dir);
    warning('[load_agc_rampdown_data] AGCデータフォルダが存在しません: %s\n  PV_ランプダウン.xlsx を配置してください。', agc_data_dir);
end
cd(agc_data_dir);
PV = get_PVstandard('PV_ランプダウン.xlsx');
cd(p)
