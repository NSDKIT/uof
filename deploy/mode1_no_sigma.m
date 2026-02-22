%% =========================================================
%  mode1_no_sigma.m  ―  PV出力帯域別σ計算（補助スクリプト）
%  =========================================================
%
%  【役割】
%    SIGMA_get.m の mode1=1 ループ内から呼び出される補助スクリプト。
%    時間断面 i における予測PV出力を8つの帯域（〜200, 〜400, ..., 〜1600MW）
%    に分割し、各帯域の誤差データに対して確率分布を計算してσを取得する。
%
%  !! 【重要】このスクリプトは単体では実行できない !!
%    SIGMA_get.m のワークスペース変数に依存しているため、
%    必ず SIGMA_get.m（mode1=1）経由で実行すること。
%
%  【前提条件（SIGMA_get.m のワークスペースに必要な変数）】
%    ┌───────────────┬──────────────────────────────────────────────┐
%    │ 変数名        │ 内容                                         │
%    ├───────────────┼──────────────────────────────────────────────┤
%    │ year          │ 対象年（PV_forecast_YYYY.mat の読み込みに使用）│
%    │ i             │ 時間断面インデックス（1〜50）                 │
%    │ PVC_bai       │ PV導入量の倍率                               │
%    │ ERROR         │ 予測誤差率配列（日数×50列）                  │
%    └───────────────┴──────────────────────────────────────────────┘
%
%  【帯域分割の定義（固定値）】
%    帯域1: 予測PV出力 < 200MW
%    帯域2: 予測PV出力 < 400MW
%    帯域3: 予測PV出力 < 600MW
%    帯域4: 予測PV出力 < 800MW
%    帯域5: 予測PV出力 < 1000MW
%    帯域6: 予測PV出力 < 1200MW
%    帯域7: 予測PV出力 < 1400MW
%    帯域8: 予測PV出力 < 1600MW
%    ※ 各帯域は累積（〜200以下, 〜400以下, ...）であり、排他的ではない点に注意。
%
%  【出力（SIGMA_get.m のワークスペースへ返す変数）】
%    s_s1〜s_s8: 各帯域のσ下限（KAKURITUBU_BUNNPU の global sigma_s）
%    s_e1〜s_e8: 各帯域のσ上限（KAKURITUBU_BUNNPU の global sigma_e）
%    → SIGMA_get.m で (s_e - s_s) としてσ幅を計算する
%
%  【依存する関数】
%    KAKURITUBU_BUNNPU(fig番号, 誤差データ, 色, x軸範囲, [], フラグ)
%      → グローバル変数 sigma_s, sigma_e にσの下限・上限を返す
% =========================================================

%% --- PV予測出力データの読み込みと倍率適用 ---
load(fullfile('output', ['PV_forecast_',num2str(year),'.mat']))  % 変数: data_all → PV予測出力
data_all = data_all * PVC_bai;               % PV導入量倍率を適用
data = data_all(:, i);                       % 時間断面 i の予測出力（365日分）

%% --- 誤差データの倍率適用 ---
ERROR1 = ERROR * PVC_bai;
E = ERROR1(:, i);  % 時間断面 i の誤差（365日分）

%% --- 帯域別に誤差データを抽出 ---
% 各帯域: 当該出力以下の日のみ誤差を抽出（累積帯域）

% 帯域1: 〜200MW
a200 = (data < 200);
E1 = E .* a200;
e1 = E1(find(a200==1));
e_l1 = length(e1);

% 帯域2: 〜400MW
a400 = (data < 400);
E2 = E .* a400;
e2 = E2(find(a400==1));
e_l2 = length(e2);

% 帯域3: 〜600MW
a600 = (data < 600);
E3 = E .* a600;
e3 = E3(find(a600==1));
e_l3 = length(e3);

% 帯域4: 〜800MW
a800 = (data < 800);
E4 = E .* a800;
e4 = E4(find(a800==1));
e_l4 = length(e4);

% 帯域5: 〜1000MW
a1000 = (data < 1000);
E5 = E .* a1000;
e5 = E5(find(a1000==1));
e_l5 = length(e5);

% 帯域6: 〜1200MW
a1200 = (data < 1200);
E6 = E .* a1200;
e6 = E6(find(a1200==1));
e_l6 = length(e6);

% 帯域7: 〜1400MW
a1400 = (data < 1400);
E7 = E .* a1400;
e7 = E7(find(a1400==1));
e_l7 = length(e7);

% 帯域8: 〜1600MW
a1600 = (data < 1600);
E8 = E .* a1600;
e8 = E5(find(a1600==1));  % ※ E8 ではなく E5 を参照している（元コードの記述通り）
e_l8 = length(e8);

%% --- 各帯域のσを計算（KAKURITUBU_BUNNPU を呼び出し） ---
% KAKURITUBU_BUNNPU は確率分布を計算し、グローバル変数 sigma_s, sigma_e にσを返す
load(fullfile('input_data', 'time_label.mat'))  % 変数: time_label → 時刻ラベル（グラフ表示用）
close all

KAKURITUBU_BUNNPU(1, E1, 'b', [-15:0.01:15], [], 1)
global sigma_s sigma_e
s_s1 = sigma_s; s_e1 = sigma_e;

KAKURITUBU_BUNNPU(2, E2, 'b', [-15:0.01:15], [], 1)
global sigma_s sigma_e
s_s2 = sigma_s; s_e2 = sigma_e;

KAKURITUBU_BUNNPU(3, E3, 'b', [-15:0.01:15], [], 1)
global sigma_s sigma_e
s_s3 = sigma_s; s_e3 = sigma_e;

KAKURITUBU_BUNNPU(4, E4, 'b', [-15:0.01:15], [], 1)
global sigma_s sigma_e
s_s4 = sigma_s; s_e4 = sigma_e;

KAKURITUBU_BUNNPU(5, E5, 'b', [-15:0.01:15], [], 1)
global sigma_s sigma_e
s_s5 = sigma_s; s_e5 = sigma_e;

KAKURITUBU_BUNNPU(5, E6, 'b', [-15:0.01:15], [], 1)
global sigma_s sigma_e
s_s6 = sigma_s; s_e6 = sigma_e;

KAKURITUBU_BUNNPU(5, E7, 'b', [-15:0.01:15], [], 1)
global sigma_s sigma_e
s_s7 = sigma_s; s_e7 = sigma_e;

KAKURITUBU_BUNNPU(5, E8, 'b', [-15:0.01:15], [], 1)
global sigma_s sigma_e
s_s8 = sigma_s; s_e8 = sigma_e;

% → s_s1〜s_e8 が SIGMA_get.m のワークスペースに返される
