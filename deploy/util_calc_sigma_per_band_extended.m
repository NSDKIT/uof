%% =========================================================
%  util_calc_sigma_per_band_extended.m  ―  PV出力帯域別σ計算（拡張版補助スクリプト）
%  =========================================================
%
%  【役割】
%    SIGMA_get1.m の mode1=1 ループ内から呼び出される補助スクリプト。
%    util_calc_sigma_per_band_basic.m の拡張版で、帯域を10分割（可変幅）に細分化し、
%    各帯域の誤差データに対して確率分布を計算してσを取得する。
%
%  !! 【重要】このスクリプトは単体では実行できない !!
%    SIGMA_get1.m のワークスペース変数に依存しているため、
%    必ず SIGMA_get1.m（mode1=1）経由で実行すること。
%
%  【util_calc_sigma_per_band_basic.m との主な違い】
%    ┌────────────────────────┬──────────────────────┬──────────────────────┐
%    │ 項目                   │ util_calc_sigma_per_band_basic.m     │ util_calc_sigma_per_band_extended.m    │
%    ├────────────────────────┼──────────────────────┼──────────────────────┤
%    │ 帯域数                 │ 8                    │ 10                   │
%    │ 帯域の定義             │ 固定値（200MW刻み）  │ PVC/5 刻み（可変）   │
%    │ 帯域の種類             │ 累積（〜N以下）      │ 排他的（N〜M）       │
%    │ σの計算関数           │ KAKURITUBU_BUNNPU    │ KAKURITUBU_BUNNPU1   │
%    │ σの返し方             │ sigma_s, sigma_e     │ pd.mu, pd.sigma      │
%    └────────────────────────┴──────────────────────┴──────────────────────┘
%
%  【前提条件（SIGMA_get1.m のワークスペースに必要な変数）】
%    ┌───────────────┬──────────────────────────────────────────────┐
%    │ 変数名        │ 内容                                         │
%    ├───────────────┼──────────────────────────────────────────────┤
%    │ year          │ 対象年                                       │
%    │ i             │ 時間断面インデックス（1〜50）                 │
%    │ PVC_bai       │ PV導入量の倍率                               │
%    │ ERROR         │ 予測誤差率配列（日数×50列）                  │
%    │ PVC           │ PV設備容量 [MW]（PVC.mat から読み込み）      │
%    └───────────────┴──────────────────────────────────────────────┘
%
%  【帯域分割の定義（可変: PVC/5 刻み）】
%    帯域1:  0      〜 PVC/5
%    帯域2:  PVC/5  〜 PVC/5*2
%    帯域3:  PVC/5*2〜 PVC/5*3
%    ...（以下同様、10分割）
%    ※ 各帯域は排他的（前の帯域を除いた範囲）。
%
%  【出力（SIGMA_get1.m のワークスペースへ返す変数）】
%    s1〜s10: 各帯域のσ（max(|μ+σ|, |μ-σ|) として計算）
%    e1〜e10: 各帯域の誤差データ（SIGMA_get1.m で .mat ファイルに保存される）
%    l      : 各帯域のデータ数配列 [e_l1, ..., e_l10]
%
%  【依存する関数】
%    KAKURITUBU_BUNNPU1(fig番号, 誤差データ, 色, x軸範囲, [], フラグ)
%      → グローバル変数 pd（正規分布オブジェクト）に mu, sigma を返す
% =========================================================

%% --- PV予測出力データの読み込みと倍率適用 ---
load(fullfile('output', ['PV_forecast_',num2str(year),'.mat']));  % 変数: data_all → PV予測出力
load(fullfile('input_data', 'PVC.mat'))                              % 変数: PVC → PV設備容量 [MW]
data_all = data_all * PVC_bai;               % PV導入量倍率を適用
data = data_all(:, i);                       % 時間断面 i の予測出力（365日分）
global a_day

%% --- 季節区切りの行番号を取得（参考用・現在はコメントアウト） ---
% 2018年の季節区切りを chose_data で取得
util_get_row_index_by_date(2018,6,30);  sp2=a_day; su1=a_day+1;
util_get_row_index_by_date(2018,9,30);  su2=a_day; au1=a_day+1;
util_get_row_index_by_date(2018,12,31); au2=a_day; wi1=a_day+1; wi2=365;

%% --- 誤差データの倍率適用 ---
E = ERROR(:, i) * PVC_bai;
E(find(E==Inf)) = 0;   % Inf を 0 に置換
E(find(E==nan)) = 0;   % NaN を 0 に置換

%% --- 帯域幅の計算（PVC を5等分） ---
PV_kubun = PVC / 5;  % 1帯域あたりの幅 [MW]

%% --- 帯域別に誤差データを抽出（排他的帯域） ---
% 帯域1: 0 〜 PV_kubun
a200 = (data < PV_kubun);
E1 = E .* a200;
e1 = E1(find(a200==1));
e_l1 = length(e1);

% 帯域2: PV_kubun 〜 PV_kubun*2
a400 = (data < PV_kubun*2) .* (data >= PV_kubun);
E2 = E .* a400;
e2 = E2(find(a400==1));
e_l2 = length(e2);

% 帯域3: PV_kubun*2 〜 PV_kubun*3
a600 = (data < PV_kubun*3) .* (data > PV_kubun*2);
E3 = E .* a600;
e3 = E3(find(a600==1));
e_l3 = length(e3);

% 帯域4: PV_kubun*3 〜 PV_kubun*4
a800 = (data < PV_kubun*4) .* (data >= PV_kubun*3);
E4 = E .* a800;
e4 = E4(find(a800==1));
e_l4 = length(e4);

% 帯域5: PV_kubun*4 〜 PV_kubun*5
a1000 = (data < PV_kubun*5) .* (data >= PV_kubun*4);
E5 = E .* a1000;
e5 = E5(find(a1000==1));
e_l5 = length(e5);

% 帯域6: PV_kubun*5 〜 PV_kubun*6
a1200 = (data < PV_kubun*6) .* (data >= PV_kubun*5);
E6 = E .* a1200;
e6 = E6(find(a1200==1));
e_l6 = length(e6);

% 帯域7: PV_kubun*6 〜 PV_kubun*7
a1400 = (data < PV_kubun*7) .* (data >= PV_kubun*6);
E7 = E .* a1400;
e7 = E7(find(a1400==1));
e_l7 = length(e7);

% 帯域8: PV_kubun*7 〜 PV_kubun*8
a1600 = (data < PV_kubun*8) .* (data > PV_kubun*7);
E8 = E .* a1600;
e8 = E8(find(a1600==1));
e_l8 = length(e8);

% 帯域9: PV_kubun*8 〜 PV_kubun*9
a1800 = (data < PV_kubun*9) .* (data > PV_kubun*8);
E9 = E .* a1800;
e9 = E9(find(a1800==1));
e_l9 = length(e9);

% 帯域10: PV_kubun*9 〜 PV_kubun*10
a2000 = (data < PV_kubun*10) .* (data > PV_kubun*9);
E10 = E .* a2000;
e10 = E10(find(a2000==1));
e_l10 = length(e10);

%% --- 各帯域のデータ数を配列にまとめる ---
l = [e_l1, e_l2, e_l3, e_l4, e_l5, e_l6, e_l7, e_l8, e_l9, e_l10];

%% --- 各帯域のσを計算（KAKURITUBU_BUNNPU1 を呼び出し） ---
% データが空または1点の場合は σ=0 として処理する
global s1 s2 s3 s4 s5 s6 s7 s8 s9 s10
load(fullfile('input_data', 'time_label.mat'))
close all

% 共通処理: データが空または1点 → σ=0、それ以外 → KAKURITUBU_BUNNPU1 でσ計算
% σ = max(|μ+σ|, |μ-σ|) として保守的な値を採用

for band_idx = 1:10
    eval_str = sprintf('e%d', band_idx);
    e_data = eval(eval_str);
    if isempty(e_data) || numel(e_data) == 1
        eval(sprintf('s%d = 0;', band_idx));
    else
        KAKURITUBU_BUNNPU1(1, e_data, 'b', [-15:0.01:15], [], 1)
        global pd
        mu = pd.mu;
        sigma = pd.sigma;
        eval(sprintf('s%d = max([abs(mu+sigma), abs(mu-sigma)]);', band_idx));
    end
end

% → s1〜s10 が SIGMA_get1.m のワークスペースに返される
