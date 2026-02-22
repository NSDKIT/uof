%% =========================================================
%  PV_compare.m  ―  PV予測出力と実績出力の月別比較グラフ
%  =========================================================
%
%  【役割】
%    指定した年・月のPV「予測出力」と「実績出力」を日ごとに並べて描画し、
%    1ヶ月分の予測と実績の傾向を視覚的に確認する。
%    グラフは最大5行×7列のサブプロット（最大35日分）で表示される。
%
%  【実行方法】
%    >> PV_compare(2018, 6, 1.0)   % 2018年6月・基準PV導入量
%    >> PV_compare(2018, 8, 1.5)   % 2018年8月・PV1.5倍
%
%  【パラメータ説明】
%    year    : 対象年（例: 2018）
%    month   : 対象月（例: 6）
%    PV_bai  : PV導入量の倍率（例: 1.0=基準, 1.5=1.5倍）
%
%  【前提条件（先に実行しておくこと）】
%    1. PV_forecast_make(year)              → PV_forecast_YYYY.mat が存在すること
%    2. PV_make(year)                       → PV_YYYY.mat が存在すること
%    3. PV_forecast_error_PVup_make(year)   → 予測PV出力誤差_YYYY フォルダ内に
%                                             ERRORyyyymmdd.mat が存在すること
%
%  【入力ファイル】
%    ┌──────────────────────────────┬──────────────────────────────────┐
%    │ ファイル名                   │ 内容                             │
%    ├──────────────────────────────┼──────────────────────────────────┤
%    │ data_YYYY.mat                │ 日付配列                         │
%    │ PV_forecast_YYYY.mat         │ PV予測出力 [MW]                  │
%    │ PV_YYYY.mat                  │ PV実績出力 [MW]                  │
%    │ Load_YYYY.mat                │ 電力需要 [MW]                    │
%    │ 予測PV出力誤差_YYYY/         │                                  │
%    │   ERRORyyyymmdd.mat          │ 日別・容量別予測誤差              │
%    └──────────────────────────────┴──────────────────────────────────┘
%
%  【出力】
%    Figure 2: 指定月の各日のPV予測（黒）と実績（赤）を比較するサブプロット群
%    変数 aa: [日数×2] の行列（各日の予測最大値・実績最大値）
%
%  !! 【重要】パスのハードコーディングについて !!
%    スクリプト内の cd コマンドに絶対パスが記述されている:
%      cd C:\Users\PowerSystemLab\...\予測PV出力誤差
%    ↑ 実行環境に合わせて修正すること。
%
%  【依存する関数】
%    chose_data(year, month, day)  ← 同フォルダ内の chose_data.m
%    sec_time_30min.m              ← X軸の時刻ラベル設定
% =========================================================

function PV_compare(year, month, PV_bai)

%% --- カレントディレクトリの保存と移動 ---
p = pwd;
% !! 要修正: 以下のパスを実行環境に合わせて変更すること !!
cd C:\Users\PowerSystemLab\Desktop\01_研究資料\05_実行ファイル\予測PV出力誤差
close all

%% --- データ読み込み ---
load(['data_',num2str(year),'.mat'])          % 変数: data → 日付配列
a = find(data(:,2)==month);                   % 当月の行番号を取得

load(['PV_forecast_',num2str(year),'.mat'])   % 変数: data_all → PV予測出力
PV_f = data_all(a,:) * PV_bai;               % 当月の予測出力（倍率適用）

load(['PV_',num2str(year),'.mat'])            % 変数: data_all → PV実績出力
PV_o = data_all(a,:) * PV_bai;               % 当月の実績出力（倍率適用）

%% --- 当月の日数を決定 ---
% 1〜3月は翌年扱い（4月始まり年度のため）
if month < 4
    year1 = year + 1;
else
    year1 = year;
end
if month == 2
    if year1 == 2019; L_D = 28;
    elseif year1 == 2020; L_D = 29;
    end
elseif month == 4 || month == 6 || month == 9 || month == 11
    L_D = 30;
else
    L_D = 31;
end

%% --- 負荷データの読み込みと当月分の抽出 ---
load(['Load_',num2str(year),'.mat'])  % 変数: data_all → 電力需要
chose_data(year, month, 1)
global a_day
d1 = a_day;
chose_data(year, month, L_D)
global a_day
d2 = a_day;
L_f = data_all(d1:d2,:);  % 当月の負荷データ

%% --- 日ごとにサブプロットを描画 ---
global aa
aa = [];
for day = 1:L_D
    % 日別の誤差ファイルを読み込む（予測PV出力誤差_YYYY フォルダ内）
    load(['ERROR', num2str(year1), num2str(month), num2str(day), '.mat'])
    e = L_f(day,:) .* ERROR(1:48)' * PV_bai / 100;

    figure(2)
    subplot(5, 7, day)
    hold on
    plot(PV_f(day,:), 'k')   % 予測出力（黒）
    plot(PV_o(day,:), 'r')   % 実績出力（赤）
    title([num2str(day),'日'])
    ylim([0 1000])
    sec_time_30min  % X軸を30分間隔の時刻ラベルに設定

    % 各日の最大値を記録（予測・実績の最大値比較用）
    aa = [aa; max(PV_f(day,:)), max(PV_o(day,:))];
end

%% --- カレントディレクトリを元に戻す ---
cd(p)

end
