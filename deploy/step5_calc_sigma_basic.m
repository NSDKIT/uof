%% =========================================================
%  step5_calc_sigma_basic.m  ―  PV予測誤差の標準偏差(σ)計算（メイン）
%  =========================================================
%
%  【役割】
%    PV予測誤差の標準偏差(σ)を計算し、動的LFC容量決定手法フォルダへ保存する。
%    mode パラメータにより、集計期間（月・季節）を柔軟に切り替え可能。
%    mode1=1 / mode1=2 ともに、PV出力を8帯域に分割した帯域別σを出力する。
%
%  【実行方法】
%    >> step5_calc_sigma_basic(2018, 1, 1, 5, 1.0)   % 2018年・5月・帯域別σ
%    >> step5_calc_sigma_basic(2018, 1, 2, 2, 1.0)   % 2018年・夏季・帯域別σ
%    >> step5_calc_sigma_basic(2018, 2, 1, 5, 1.0)   % 2018年・5月・全体σ（2列）
%
%  【パラメータ説明】
%    ┌─────────┬──────────────────────────────────────────────────────┐
%    │ 引数    │ 説明                                                 │
%    ├─────────┼──────────────────────────────────────────────────────┤
%    │ year    │ 対象年（例: 2018）                                   │
%    │ mode1   │ σの計算方法                                         │
%    │         │  1 = PV出力の大きさ別にσを計算（帯域別・8列出力）   │
%    │         │  2 = 月・季節で絞り込んだ上で帯域別σを計算（8列出力）│
%    │ mode2   │ 集計期間の選択                                       │
%    │         │  1 = 月別（mode3で月番号を指定）                     │
%    │         │  2 = 季節別（mode3で季節番号を指定）                 │
%    │ mode3   │ mode2=1 のとき: 月番号（1〜12）                      │
%    │         │ mode2=2 のとき: 1=春(4〜6月) / 2=夏(7〜9月)         │
%    │         │                 3=秋(10〜12月) / 4=冬(1〜3月)        │
%    │ PVC_bai │ PV導入量の倍率（例: 1.0=基準, 2.0=2倍）             │
%    └─────────┴──────────────────────────────────────────────────────┘
%
%  【mode1=1 と mode1=2 の違い】
%    ┌──────────┬──────────────────────────────────────┬──────────────────────────────────────┐
%    │ 項目     │ mode1=1                              │ mode1=2                              │
%    ├──────────┼──────────────────────────────────────┼──────────────────────────────────────┤
%    │ 帯域分類 │ 全年間データを使って帯域分類         │ 月・季節で絞り込んだデータで帯域分類 │
%    │ 絞り込み │ なし（365日全て）                    │ mode2/mode3 で月・季節を指定         │
%    │ 出力列数 │ 8列（帯域別σ幅）                    │ 8列（帯域別σ幅）                    │
%    └──────────┴──────────────────────────────────────┴──────────────────────────────────────┘
%
%  【前提条件（先に実行しておくこと）】
%    1. step1_generate_pv_forecast(year)      → PV_forecast_YYYY.mat が存在すること
%    2. step3_calc_forecast_error(year)       → ERROR_YYYY.mat が存在すること
%
%  【入力ファイル】
%    output/ERROR_YYYY.mat         変数: ERROR  → 予測誤差率 [%]（日数×50列）
%    output/PV_forecast_YYYY.mat   変数: data_all → PV予測出力（日数×50列）
%    input_data/data_YYYY.mat      変数: data   → 日付配列
%
%  【出力】
%    output/動的LFC容量決定手法/error_sigma.mat
%      ・変数 error_sigma: [50行（時間断面）× 8列（帯域別σ幅）]
%        各列は帯域（〜200, 〜400, ..., 〜1600MW）のσ幅（s_e - s_s）
%
%  【依存する関数・スクリプト】
%    - util_calc_sigma_per_band_basic.m  （帯域別σ計算補助スクリプト）
%    - util_fit_normal_distribution.m    （正規分布フィッティング）
%    - util_get_plot_colors.m            （グラフの色設定）
%    - util_set_xaxis_time_labels.m      （X軸の時刻ラベル設定）
% =========================================================

function step5_calc_sigma_basic(year, mode1, mode2, mode3, PVC_bai)

close all

%% --- データ読み込み ---
load(fullfile('output', ['ERROR_',num2str(year),'.mat']))      % 変数: ERROR    → 予測誤差率 [%]（日数×50列）
load(fullfile('output', ['PV_forecast_',num2str(year),'.mat']))% 変数: data_all → PV予測出力（日数×50列）
load(fullfile('input_data', ['data_',num2str(year),'.mat']))   % 変数: data     → 日付配列

%% --- 集計対象の行インデックスを決定 ---
% mode1=1: 全年間（絞り込みなし）
% mode1=2: mode2/mode3 で月・季節を絞り込む
if mode1 == 1
    % 全年間のデータを使用
    row = 1:size(data, 1);
    name = '全年間';
else
    % mode2/mode3 で絞り込む
    if ~exist('mode2', 'var') || isempty(mode2)
        row = 1:size(data, 1);
        name = '全年間';
    else
        if mode2 == 1
            % 月別集計
            row = find(data(:,2) == mode3);
            name = [num2str(mode3), '月'];
        elseif mode2 == 2
            % 季節別集計
            if mode3 == 1
                row = [find(data(:,2)==4); find(data(:,2)==5); find(data(:,2)==6)];
                name = 'spring';
            elseif mode3 == 2
                row = [find(data(:,2)==7); find(data(:,2)==8); find(data(:,2)==9)];
                name = 'summer';
            elseif mode3 == 3
                row = [find(data(:,2)==10); find(data(:,2)==11); find(data(:,2)==12)];
                name = 'autumn';
            elseif mode3 == 4
                row = [find(data(:,2)==1); find(data(:,2)==2); find(data(:,2)==3)];
                name = 'winter';
            end
        end
    end
end

%% --- 時間断面ごと（i=1〜50）にσを計算 ---
% 50断面 = 30分×50コマ（0:00〜24:30 相当）
% mode1=1: 全年間データで帯域分類
% mode1=2: 絞り込んだ行（row）のデータで帯域分類
S = [];
for i = 1:50

    %% --- 時間断面 i の予測出力と誤差を取り出す ---
    data_i = data_all(row, i) * PVC_bai;   % 絞り込み後の予測PV出力（倍率適用）
    E_i    = ERROR(row, i) * PVC_bai;      % 絞り込み後の予測誤差率 [%]（倍率適用）

    %% --- 帯域別に誤差データを抽出（累積帯域: 〜200, 〜400, ..., 〜1600MW）---
    bands = [200, 400, 600, 800, 1000, 1200, 1400, 1600];
    s_s_arr = zeros(1, 8);
    s_e_arr = zeros(1, 8);

    for b = 1:8
        mask = (data_i < bands(b));
        e_band = E_i(mask);
        if isempty(e_band) || numel(e_band) == 1
            s_s_arr(b) = 0;
            s_e_arr(b) = 0;
        else
            util_fit_normal_distribution(b, e_band, 'b', [-15:0.01:15], [], 1)
            s_s_arr(b) = sigma_s;
            s_e_arr(b) = sigma_e;
        end
    end

    %% --- 各帯域のσ幅（s_e - s_s）を収集 ---
    S = [S; s_e_arr - s_s_arr];
end

%% --- 結果のグラフ描画 ---
figure('Name', ['帯域別σ（', name, '）'])
hold on
util_get_plot_colors
for b = 1:8
    plot(S(:,b), 'Color', color(b,:))
end
ylim([0 5])
legend('~200MW','~400MW','~600MW','~800MW','~1000MW','~1200MW','~1400MW','~1600MW')
util_set_xaxis_time_labels  % X軸を30分間隔の時刻ラベルに設定

%% --- 結果の保存（相対パス: output/動的LFC容量決定手法/ フォルダ） ---
out_dir = fullfile('output', '動的LFC容量決定手法');
if ~exist(out_dir, 'dir')
    mkdir(out_dir)
end
error_sigma = S;
save(fullfile(out_dir, 'error_sigma.mat'), 'error_sigma')
% → 保存先: output/動的LFC容量決定手法/error_sigma.mat
% → error_sigma: [50行（時間断面）× 8列（帯域別σ幅）]

end
