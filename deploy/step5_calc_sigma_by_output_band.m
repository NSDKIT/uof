%% =========================================================
%  step5_calc_sigma_by_output_band.m  ―  PV予測誤差の標準偏差(σ)計算（拡張版）
%  =========================================================
%
%  【役割】
%    SIGMA_get.m の拡張版。
%    PV出力帯域をより細かく（10分割）σを計算し、
%    各時間断面の誤差データを「時間粒度_気象分解能別予測誤差」フォルダへ
%    個別に保存する機能が追加されている。
%
%  【SIGMA_get.m との主な違い】
%    ┌────────────────────────┬──────────────────┬──────────────────────┐
%    │ 項目                   │ SIGMA_get.m      │ SIGMA_get1.m         │
%    ├────────────────────────┼──────────────────┼──────────────────────┤
%    │ 帯域分割数             │ 8分割            │ 10分割               │
%    │ 帯域の定義方法         │ 固定値（200MW刻み）│ PVC/5 刻み（可変）  │
%    │ 補助スクリプト         │ util_calc_sigma_per_band_basic   │ util_calc_sigma_per_band_extended      │
%    │ 中間データの保存       │ なし             │ 時刻断面_i.mat を保存│
%    └────────────────────────┴──────────────────┴──────────────────────┘
%
%  【実行方法】
%    >> step5_calc_sigma_by_output_band(2018, 1, 1, 6, 1.0)
%
%  【パラメータ説明】（SIGMA_get.m と同じ）
%    year    : 対象年
%    mode1   : 1=PV出力帯域別σ / 2=全体σ
%    mode2   : 1=月別 / 2=季節別
%    mode3   : 月番号(1〜12) または 季節番号(1〜4)
%    PVC_bai : PV導入量の倍率
%
%  【前提条件（先に実行しておくこと）】
%    1. step1_generate_pv_forecast(year)       → PV_forecast_YYYY.mat が存在すること
%    2. step3_calc_forecast_error(year) → ERROR_YYYY.mat が存在すること
%
%  【出力】
%    error_sigma.mat  ← 動的LFC容量決定手法フォルダに保存
%    時刻断面_i.mat   ← 時間粒度_気象分解能別予測誤差\データ\PV*倍 フォルダに保存
%
%  !! 【重要】パスのハードコーディングについて !!
%    スクリプト内に以下の絶対パスが記述されている（要修正）:
%      cd C:\Users\PowerSystemLab\...\予測PV出力誤差
%      mkdir C:\Users\PowerSystemLab\...\PV*倍
%      cd('C:\Users\PowerSystemLab\...\動的LFC容量決定手法')
%    ↑ 実行環境に合わせてすべて修正すること。
%
%  【依存する関数・スクリプト】
%    - util_calc_sigma_per_band_extended.m     （mode1=1 のとき内部ループで呼び出し）
%    - KAKURITUBU_BUNNPU.m   （mode1=2 のとき使用）
% =========================================================

function step5_calc_sigma_by_output_band(year, mode1, mode2, mode3, PVC_bai)

close all

%% --- データ読み込み（相対パス） ---
load(fullfile('output', ['ERROR_',num2str(year),'.mat']))      % 変数: ERROR → 予測誤差率 [%]
load(fullfile('input_data', ['data_',num2str(year),'.mat']))   % 変数: data  → 日付配列

%% --- 時刻断面データの保存先フォルダを作成 ---
sigma_dir = fullfile('output', '時間粒度_気象分解能別予測誤差', 'データ', ['PV',num2str(PVC_bai),'倍']);
if ~exist(sigma_dir, 'dir')
    mkdir(sigma_dir)
end

%% --- mode1=2 のとき: 集計期間の行番号を決定 ---
if mode1 ~= 1
    if ~exist('mode2', 'var') || isempty(mode2)
        name = '時間断面ごとに365日分';
    else
        if mode2 == 1
            row = find(data(:,2)==mode3);
            name = [num2str(mode3),'月'];
        elseif mode2 == 2
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
S = [];
all_num = [];
for i = 1:50
    if mode1 == 1
        % PV出力帯域別σの計算（補助スクリプト util_calc_sigma_per_band_extended を呼び出し）
        % → util_calc_sigma_per_band_extended.m が year, i, PVC_bai, ERROR, PVC を参照する
        util_calc_sigma_per_band_extended
        % 各帯域（10分割）のσを収集
        S = [S; s1, s2, s3, s4, s5, s6, s7, s8, s9, s10];
        all_num = [all_num; l];  % 各帯域のデータ数

        % 時間断面ごとの誤差データを個別ファイルに保存（相対パス）
        save(fullfile(sigma_dir, ['時刻断面_',num2str(i),'.mat']), ...
             'e1','e2','e3','e4','e5','e6','e7','e8','e9','e10')
        % → 保存先: output/時間粒度_気象分解能別予測誤差/データ/PV*倍/時刻断面_i.mat
    else
        if ~exist('mode2', 'var') || isempty(mode2)
            KAKURITUBU_BUNNPU(i, (ERROR(:,i)), 'b', [-15:0.01:15], [], [])
        else
            KAKURITUBU_BUNNPU(i, (ERROR(row,i)), 'b', [-15:0.01:15], [], [])
        end
        global sigma_s sigma_e
        S = [S; sigma_s, sigma_e];
    end
end

%% --- 全断面のデータ数をベースワークスペースへ返す ---
assignin('base', 'all_num', all_num);

%% --- 結果の保存（相対パス: output/動的LFC容量決定手法/ フォルダ） ---
out_dir = fullfile('output', '動的LFC容量決定手法');
if ~exist(out_dir, 'dir')
    mkdir(out_dir)
end
error_sigma = S;
save(fullfile(out_dir, 'error_sigma.mat'), 'error_sigma')
% → 保存先: output/動的LFC容量決定手法/error_sigma.mat

end
