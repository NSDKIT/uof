%% =========================================================
%  SIGMA_get.m  ―  PV予測誤差の標準偏差(σ)計算（メイン）
%  =========================================================
%
%  【役割】
%    PV予測誤差の標準偏差(σ)を計算し、動的LFC容量決定手法フォルダへ保存する。
%    mode パラメータにより、計算条件（期間・PV出力帯域別）を柔軟に切り替え可能。
%
%  【実行方法】
%    >> SIGMA_get(2018, 1, 1, 6, 1.0)   % 2018年・6月・PV出力帯域別σ
%    >> SIGMA_get(2018, 2, 2, 1, 1.5)   % 2018年・春季・全体σ・PV1.5倍
%
%  【パラメータ説明】
%    ┌─────────┬──────────────────────────────────────────────────────┐
%    │ 引数    │ 説明                                                 │
%    ├─────────┼──────────────────────────────────────────────────────┤
%    │ year    │ 対象年（例: 2018）                                   │
%    │ mode1   │ σの計算方法                                         │
%    │         │  1 = PV出力の大きさ別にσを計算（mode1_no_sigma使用）│
%    │         │  2 = 全体のσを計算（KAKURITUBU_BUNNPU使用）         │
%    │ mode2   │ 集計期間の選択                                       │
%    │         │  1 = 月別（mode3で月番号を指定）                     │
%    │         │  2 = 季節別（mode3で季節番号を指定）                 │
%    │ mode3   │ mode2=1 のとき: 月番号（1〜12）                      │
%    │         │ mode2=2 のとき: 1=春(4〜6月) / 2=夏(7〜9月)         │
%    │         │                 3=秋(10〜12月) / 4=冬(1〜3月)        │
%    │ PVC_bai │ PV導入量の倍率（例: 1.0=基準, 2.0=2倍）             │
%    └─────────┴──────────────────────────────────────────────────────┘
%
%  【前提条件（先に実行しておくこと）】
%    1. PV_forecast_make(year)      → PV_forecast_YYYY.mat が存在すること
%    2. PV_forecast_error_make(year) → ERROR_YYYY.mat が存在すること
%
%  【入力ファイル】
%    ERROR_YYYY.mat  / data_YYYY.mat
%
%  【出力】
%    error_sigma.mat  ← 動的LFC容量決定手法フォルダに保存
%      ・変数 error_sigma: [50行（時間断面）× σ列数]
%
%  !! 【重要】パスのハードコーディングについて !!
%    スクリプト末尾の cd コマンドに絶対パスが記述されている:
%      cd('C:\Users\PowerSystemLab\...\動的LFC容量決定手法')
%    ↑ 実行環境に合わせて修正すること。
%
%  【依存する関数・スクリプト】
%    - mode1_no_sigma.m      （mode1=1 のとき内部ループで呼び出し）
%    - KAKURITUBU_BUNNPU.m   （mode1=2 のとき確率分布計算に使用）
%    - get_color.m           （グラフの色設定）
%    - sec_time_30min.m      （X軸の時刻ラベル設定）
% =========================================================

function SIGMA_get(year, mode1, mode2, mode3, PVC_bai)

close all

%% --- データ読み込み ---
load(['ERROR_',num2str(year),'.mat'])  % 変数: ERROR → 予測誤差率 [%]（日数×50列）
load(['data_',num2str(year),'.mat'])   % 変数: data  → 日付配列

%% --- mode1=2 のとき: 集計期間の行番号を決定 ---
if mode1 ~= 1
    if ~exist('mode2', 'var') || isempty(mode2)
        name = '時間断面ごとに365日分';
    else
        if mode2 == 1
            % 月別集計
            row = find(data(:,2)==mode3);
            name = [num2str(mode3),'月'];
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
                name = 'automm';
            elseif mode3 == 4
                row = [find(data(:,2)==1); find(data(:,2)==2); find(data(:,2)==3)];
                name = 'winter';
            end
        end
    end
end

%% --- 時間断面ごと（i=1〜50）にσを計算 ---
% 50断面 = 30分×50コマ（0:00〜24:30 相当）
S = [];
all_num = [];
for i = 1:50
    if mode1 == 1
        % PV出力帯域別σの計算（補助スクリプト mode1_no_sigma を呼び出し）
        % → mode1_no_sigma.m が year, i, PVC_bai, ERROR を参照する
        mode1_no_sigma
        % 各帯域（〜200, 〜400, ..., 〜1600MW）のσ幅を収集
        S = [S; s_e1-s_s1, s_e2-s_s2, s_e3-s_s3, s_e4-s_s4, ...
                s_e5-s_s5, s_e6-s_s6, s_e7-s_s7, s_e8-s_s8];
    else
        if ~exist('mode2', 'var') || isempty(mode2)
            % 全期間（365日分）の確率分布を計算
            KAKURITUBU_BUNNPU(i, (ERROR(:,i)), 'b', [-15:0.01:15], [], [])
        else
            % 指定した月・季節の確率分布を計算
            KAKURITUBU_BUNNPU(i, (ERROR(row,i)), 'b', [-15:0.01:15], [], [])
        end
        global sigma_s sigma_e
        S = [S; sigma_s, sigma_e];
    end
end

%% --- 結果のグラフ描画 ---
if mode1 == 1
    figure('Name','予測PV出力の大きさでσを比較')
    hold on
    get_color
    for i = 1:8
        plot(S(:,i), 'Color', color(i,:))
    end
    ylim([0 5])
    legend(['~200'],['~400'],['~600'],['~800'],['~1000'])
else
    figure('Name', name)
    hold on
    bar(S(:,1), 'b')
    bar(S(:,2), 'r')
    ylim([-4 4])
end
sec_time_30min  % X軸を30分間隔の時刻ラベルに設定

%% --- 結果の保存（動的LFC容量決定手法フォルダへ） ---
% !! 要修正: 以下のパスを実行環境に合わせて変更すること !!
cd('C:\Users\PowerSystemLab\Desktop\01_研究資料\05_実行ファイル\動的LFC容量決定手法')
error_sigma = S;
save('error_sigma.mat', 'error_sigma')
% → 保存先: 動的LFC容量決定手法フォルダ内の error_sigma.mat

end
