%% =========================================================
%  PV_forecast_error_bar_make.m  ―  日別予測誤差の棒グラフ可視化
%  =========================================================
%
%  【役割】
%    指定した年・月のPV予測誤差を、日ごとの棒グラフで可視化する。
%    PV_forecast_error_PVup_make で生成された日別の誤差ファイルを使用する。
%
%  【実行方法】
%    >> PV_forecast_error_bar_make(2018, 6, 1)   % 2018年6月・1列目（基準容量）
%    >> PV_forecast_error_bar_make(2018, 8, 3)   % 2018年8月・3列目（容量ステップ3）
%
%  【パラメータ説明】
%    year  : 対象年（例: 2018）
%    month : 対象月（例: 6）
%    num   : 表示する誤差データの列番号（PV導入量ステップに対応）
%              1列目 = 基準PV導入量での誤差
%              2列目以降 = 20MW刻みで増加した容量での誤差
%
%  【前提条件（先に実行しておくこと）】
%    PV_forecast_error_PVup_make(year)  → 予測PV出力誤差_YYYY フォルダ内に
%                                         ERRORyyyymmdd.mat が存在すること
%
%  【入力ファイル】
%    予測PV出力誤差_YYYY フォルダ内の ERRORyyyymmdd.mat
%      ・変数 ERROR: [48行（時間断面）× 容量ステップ数列]
%
%  【出力】
%    Figure 10: 指定月の各日の誤差棒グラフ（サブプロット群）
%    Figure (新規): 月平均の誤差棒グラフ
%
%  !! 【重要】パスのハードコーディングについて !!
%    スクリプト内の cd コマンドに絶対パスが記述されている:
%      cd('C:\Users\PowerSystemLab\...\予測PV出力誤差')
%    ↑ 実行環境に合わせて修正すること。
%
%  【依存する関数】
%    sec_time_30min.m  ← X軸の時刻ラベル設定
% =========================================================

function PV_forecast_error_bar_make(year, month, num)

%% --- 入力フォルダの設定（相対パス） ---
err_dir = fullfile('output', '予測PV出力誤差');  % 日別誤差ファイルが格納されたフォルダ

%% --- 当月の日数を決定 ---
% 1〜3月は翌年扱い（4月始まり年度のため）
if month < 4
    year = year + 1;
end
if month == 2
    if year == 2019; L_D = 28;
    elseif year == 2020; L_D = 29;
    end
elseif month == 4 || month == 6 || month == 9 || month == 11
    L_D = 30;
else
    L_D = 31;
end

%% --- 日ごとに誤差棒グラフを描画 ---
ERROR_M = [];
for day = 1:L_D
    % 日別の誤差ファイルを読み込む（相対パス）
    load(fullfile(err_dir, ['ERROR', num2str(year), num2str(month,'%02d'), num2str(day,'%02d'), '.mat']))

    % Figure 10 にサブプロットで描画
    figure(10)
    hold on
    subplot(5, 7, day)
    bar(ERROR(:, num))    % num 列目（指定したPV導入量ステップ）の誤差を棒グラフ表示
    ylim([0 12])

    % 月平均計算用に1列目（基準容量）の誤差を収集
    ERROR_M = [ERROR_M, ERROR(:,1)];
end

%% --- 月平均の誤差棒グラフを描画 ---
ERROR_M = mean(ERROR_M');  % 各時間断面の月平均を計算
figure, bar(ERROR_M)
sec_time_30min  % X軸を30分間隔の時刻ラベルに設定

end
