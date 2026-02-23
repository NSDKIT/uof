%% =========================================================================
%  run_simulation.m  ─  電力系統需給運用シミュレーション メインスクリプト
% =========================================================================
%
% 【概要】
%   このスクリプトを MATLAB で実行するだけで、以下の処理が自動的に実施されます。
%   1. 必要なパスの設定（環境依存なし）
%   2. 入力データ（PV・需要）の準備
%   3. 発電機起動停止計画（Unit Commitment）の最適化
%   4. Simulink モデル（AGC30_PVcut.slx）による動的シミュレーション
%   5. 結果の保存（results/ フォルダへ）
%
% 【使い方】
%   1. MATLAB を起動する
%   2. このファイル（run_simulation.m）が置かれているフォルダを
%      カレントディレクトリに設定する
%   3. コマンドウィンドウで run_simulation と入力して Enter を押す
%
% 【フォルダ構成】
%   run_simulation.m  ← このファイル（ルートに置く）
%   model.m           ← 元のシミュレーション本体（参照用）
%   基本データ/       ← PV・需要の入力データ（.mat）
%   UC立案/MATLAB/    ← 起動停止計画（UC）の最適化スクリプト
%   運用/             ← Simulink モデルと初期設定スクリプト群
%   results/          ← シミュレーション結果の保存先（自動生成）
%
% 【必要なデータファイル（基本データ/フォルダ内）】
%   - PV_base_YYYY.mat    : 既設PV容量データ
%   - PR_YYYY.mat         : システム出力係数
%   - MSM_bai_YYYY.mat    : MSM倍数係数
%   - irr_fore_data.mat   : 予測日射量データ
%   - irr_mea_data.mat    : 実測日射量データ
%   - D_1sec.mat          : 1秒値需要データ
%   - D_30min.mat         : 30分値需要データ
%
% 【注意事項】
%   - MATLAB R2019b 以降を推奨
%   - Simulink および Control System Toolbox が必要
%   - 初回実行時は results/ フォルダが自動作成されます
%
% =========================================================================

%% ── 初期化 ──────────────────────────────────────────────────────────────
clear; close all; clc;

%% ── パス設定（環境依存なし・相対パスで管理）────────────────────────────
% このスクリプトが置かれているフォルダを ROOT_DIR として取得
ROOT_DIR = fileparts(mfilename('fullpath'));
cd(ROOT_DIR);

% サブフォルダを全て MATLAB パスに追加
addpath(genpath(ROOT_DIR));

% 結果保存フォルダ（存在しなければ自動作成）
results_dir = fullfile(ROOT_DIR, 'results');
if ~exist(results_dir, 'dir')
    mkdir(results_dir);
    fprintf('[INFO] 結果保存フォルダを作成しました: %s\n', results_dir);
end

fprintf('[INFO] ROOT_DIR = %s\n', ROOT_DIR);
fprintf('[INFO] results_dir = %s\n', results_dir);

%% ── シミュレーション条件設定 ─────────────────────────────────────────────
% ▼▼▼ ここを変更してシミュレーション条件を設定してください ▼▼▼

% 対象日付（YYYYMMDD 形式、複数日は行を追加）
YYYYMMDD = ['20190828'];
% 例: 複数日の場合
% YYYYMMDD = ['20190828';
%             '20190917';
%             '20191022'];

% PV 導入容量 [MW]（複数ケースはベクトルで指定）
PVC_list = [5300];
% 例: 複数ケースの場合
% PVC_list = [3300, 5300, 7300, 9300, 11300];

% 解析手法番号
% 1: 従来手法（固定）
% 2: 線形補間手法
% 3: 統計的手法
% 4: 機械学習手法
meth_num = 2;

% PV パネル設置モード
% 1: 片面（通常）
% 2: 両面（東向き）
% 3: 両面（西向き）
% 4: 片面（一軸追尾）
% 5: 両面（一軸追尾）
mode = 1;

% 予測誤差の有無
% 0: 予測誤差なし（実測値 = 予測値）
% 1: 予測誤差あり（実測値 ≠ 予測値）
error_ox = 0;

% 予測誤差の標準偏差パラメータ
sigma = 2;

% LFC 制御パラメータ
lfc = 8;

% ▲▲▲ 設定ここまで ▲▲▲

%% ── 年度カレンダーの作成 ─────────────────────────────────────────────────
% 2019年度（2019/4/1 〜 2020/3/31）の日付一覧を作成
start_date = datetime(2019, 4, 1);
end_date   = datetime(2020, 3, 31);
date_range = start_date:end_date;
date_strings = datestr(date_range, 'yyyymmdd');
save(fullfile(ROOT_DIR, 'date_strings.mat'), 'date_strings');

%% ── 設定値の保存（サブスクリプトから参照するため）────────────────────────
save(fullfile(ROOT_DIR, 'error_ox.mat'),  'error_ox');
save(fullfile(ROOT_DIR, 'method.mat'),    'meth_num');
save(fullfile(ROOT_DIR, 'meth_num.mat'),  'meth_num');
save(fullfile(ROOT_DIR, 'sigma.mat'),     'sigma');
save(fullfile(ROOT_DIR, 'mode.mat'),      'mode');
save(fullfile(ROOT_DIR, 'lfclfc.mat'),    'lfc');
save(fullfile(ROOT_DIR, 'YYYYMMDD.mat'),  'YYYYMMDD');

%% ── メインループ ─────────────────────────────────────────────────────────
fprintf('\n========================================\n');
fprintf(' シミュレーション開始\n');
fprintf('========================================\n');

for iii = 1:size(YYYYMMDD, 1)

    % 対象日の年月日を取得
    year_l  = str2num(YYYYMMDD(iii, 1:4));
    month_l = str2num(YYYYMMDD(iii, 5:6));
    day_l   = str2num(YYYYMMDD(iii, 7:8));
    save(fullfile(ROOT_DIR, 'YMD.mat'), 'year_l', 'month_l', 'day_l');

    % 年度内の通算日数（DN）を計算
    load(fullfile(ROOT_DIR, 'date_strings.mat'));
    YYYY = str2num(date_strings(:,1:4)) == year_l;
    MM   = str2num(date_strings(:,5:6)) == month_l;
    DD   = str2num(date_strings(:,7:8)) == day_l;
    DN   = find(YYYY .* MM .* DD);

    fprintf('\n[%d/%d] 対象日: %s (年度内 %d 日目)\n', ...
            iii, size(YYYYMMDD,1), YYYYMMDD(iii,:), DN);

    % 年度の判定（2020年1〜3月は 2019年度データを使用）
    y = year_l;
    if year_l == 2020
        y = year_l - 1;
    end

    %% ── 基本データの読み込み ────────────────────────────────────────────
    fprintf('  [1/5] 基本データを読み込み中...\n');

    % 既設 PV 容量（月別）
    load(fullfile(ROOT_DIR, '基本データ', sprintf('PV_base_%d.mat', y)));
    PV_base = [PV_base(end-2:end, 3)', PV_base(1:end-3, 3)'];

    % システム出力係数（月別）
    load(fullfile(ROOT_DIR, '基本データ', sprintf('PR_%d.mat', y)));

    % MSM 倍数係数（月別）
    load(fullfile(ROOT_DIR, '基本データ', sprintf('MSM_bai_%d.mat', y)));

    % 予測・実測日射量データ
    load(fullfile(ROOT_DIR, '基本データ', 'irr_fore_data.mat'));
    load(fullfile(ROOT_DIR, '基本データ', 'irr_mea_data.mat'));

    % 需要データ（1秒値・30分値）
    load(fullfile(ROOT_DIR, '基本データ', 'D_1sec.mat'));
    load(fullfile(ROOT_DIR, '基本データ', 'D_30min.mat'));

    % 需要（一般水力分 500MW を減算）
    demand_1sec  = D_1sec(DN, :)  - 500;
    demand_30min = D_30min(DN, :) - 500;
    save(fullfile(ROOT_DIR, 'demand_1sec.mat'),  'demand_1sec');
    save(fullfile(ROOT_DIR, 'demand_30min.mat'), 'demand_30min');

    %% ── PVC ループ ──────────────────────────────────────────────────────
    for PVC = PVC_list
        save(fullfile(ROOT_DIR, 'PVC.mat'), 'PVC');
        fprintf('\n  PV 導入容量: %d MW\n', PVC);

        %% ── PV 予測出力の計算 ───────────────────────────────────────────
        fprintf('  [2/5] PV 予測・実績出力を計算中...\n');
        n_l = [1, mode];
        PV_al = 1100;  % 既設 PV 容量 [MW]

        % 30分値 PV 予測出力の計算
        PVF_al  = irr_fore_data(24*(DN-2)+1 : 24*(DN-1), n_l(1)) ...
                  * MSM_bai(month_l) * PR(month_l) * PV_base(month_l) / 1000;
        PVF_new = irr_fore_data(24*(DN-2)+1 : 24*(DN-1), n_l(2)) ...
                  * MSM_bai(month_l) * PR(month_l) * PV_base(month_l) / 1000;
        PVF_30min = PVF_al * PV_al / PV_base(month_l) ...
                  + PVF_new * (PVC - PV_al) / PV_base(month_l);

        % 30分値 → 1分値に補間
        x = 1:24;  xq = 1:0.5:24;
        PVF_30min = [interp1(x, PVF_30min, xq), 0, 0, 0];
        PVF_30min(isnan(PVF_30min)) = 0;
        save(fullfile(ROOT_DIR, 'PVF_30min.mat'), 'PVF_30min');

        % 1秒値 PV 実績出力の計算
        PV_al_1s  = irr_mea_data(86401*(DN-1)+1 : 86401*DN, n_l(1)) ...
                    * PR(month_l) * PV_base(month_l) / 1000;
        PV_new_1s = irr_mea_data(86401*(DN-1)+1 : 86401*DN, n_l(2)) ...
                    * PR(month_l) * PV_base(month_l) / 1000;
        PV_1sec = PV_al_1s * PV_al / PV_base(month_l) ...
                + PV_new_1s * (PVC - PV_al) / PV_base(month_l);
        save(fullfile(ROOT_DIR, 'PV_1sec.mat'), 'PV_1sec');

        %% ── 起動停止計画（Unit Commitment）────────────────────────────
        fprintf('  [3/5] 起動停止計画（UC）を計算中...\n');
        uc_dir = fullfile(ROOT_DIR, 'UC立案', 'MATLAB');
        cd(uc_dir);
        try
            new_optimization;
            % UC 計算結果の CSV を 運用/ フォルダにコピー
            copyfile('*.csv', fullfile(ROOT_DIR, '運用'));
            fprintf('  [3/5] UC 計算が完了しました。\n');
            ME_uc = [];
        catch ME_uc
            warning('  [3/5] UC 計算でエラーが発生しました: %s', ME_uc.message);
        end
        cd(ROOT_DIR);

        if ~isempty(ME_uc)
            fprintf('  UC エラーのため、このケースをスキップします。\n');
            continue;
        end

        %% ── Simulink 動的シミュレーション ───────────────────────────────
        fprintf('  [4/5] Simulink シミュレーションを実行中...\n');
        sim_dir = fullfile(ROOT_DIR, '運用');
        cd(sim_dir);

        % Simulink 入力 CSV の作成（Load.csv, PV_Out.csv）
        make_csv;
        clear;

        % 各モデルの初期パラメータを設定
        fprintf('       モデルパラメータを初期化中...\n');
        initset_dataload;    % 時系列データ・発電計画の読み込みと入力ファイル作成
        initset_inertia;     % 慣性モデルの設定（K_L, F0, MVABase）
        initset_trfpP;       % 連系線潮流モデルの設定（T_0）
        initset_lfc;         % LFC モデルの設定（ゲイン・不感帯等）
        initset_edc;         % EDC モデルの初期設定（等ラムダ法による初期配分）
        initset_thermals;    % 汽力・GTCC プラントモデルの初期設定
        % initset_conhydros; % 定速揚水モデル（使用する場合はコメントを外す）
        % initset_vahydros;  % 可変速揚水モデル（使用する場合はコメントを外す）
        initset_otherarea;   % 他エリアモデルの設定

        % PV 出力の調整（予測値を超えないようにローパスフィルタ処理）
        load(fullfile(ROOT_DIR, 'lfclfc.mat'));
        PVF = PV_Forecast(2, :);
        LOF = load_forecast_input(2, :);
        save(fullfile(sim_dir, 'FO.mat'), 'PVF', 'LOF');
        PV_MAX = max(PV_Out(2, :));
        save(fullfile(sim_dir, 'PV_MAX.mat'), 'PV_MAX');
        lowpass_PV;
        PV_real_Output = PV_Out;
        save(fullfile(sim_dir, 'PV_real_Output.mat'), 'PV_real_Output');

        % Simulink モデルの実行
        try
            if lfc >= 100
                open_system('Hydro_load.slx');
                sim('Hydro_load.slx');
            else
                open_system('AGC30_PVcut.slx');
                sim('AGC30_PVcut.slx');
            end
            fprintf('  [4/5] シミュレーションが正常に終了しました。\n');
            ME_sim = [];
        catch ME_sim
            warning('  [4/5] シミュレーション実行中にエラーが発生しました: %s', ME_sim.message);
        end
        cd(ROOT_DIR);

        if ~isempty(ME_sim)
            fprintf('  Simulink エラーのため、このケースをスキップします。\n');
            continue;
        end

        %% ── 結果の保存 ──────────────────────────────────────────────────
        fprintf('  [5/5] シミュレーション結果を保存中...\n');

        % 保存データの収集
        M = load(fullfile(sim_dir, 'inertia_input.mat'));
        inertia_input = M.inertia_input(2, :);
        FO = load(fullfile(sim_dir, 'FO.mat'));
        PVF = FO.PVF;  LOF = FO.LOF;
        G_Out_UC  = get_GOUT(fullfile(sim_dir, 'G_Out.csv'));
        LFC_up    = get_LFC_updown(fullfile(sim_dir, 'G_up_plan_limit.csv'));
        LFC_down  = get_LFC_updown(fullfile(sim_dir, 'G_down_plan_limit.csv'));
        g_c_o_s   = load(fullfile(sim_dir, 'g_const_out_sum.mat'));
        g_const_out_sum = g_c_o_s.g_const_out_sum(2, :);
        LFC_t     = get_Gupplanlimittime(fullfile(sim_dir, 'G_up_plan_limit_time.csv'));
        load(fullfile(ROOT_DIR, 'Reserved_power.mat'));
        LFC       = load(fullfile(ROOT_DIR, 'UC立案', 'LFC.mat'));

        % 出力変数の次元整合
        inertia_input       = inertia_input(2, :);
        load_forecast_input = load_forecast_input(2, :);
        load_input          = load_input(2, :);
        PV_Forecast         = PV_Forecast(2, :);
        PV_Out              = PV_Out(2, :);

        % ファイル名の生成（モード・sigma・手法・PVC・日付を含む）
        mode_prefix = {'n', 'E', 'W', 'T', 'T_V'};
        filename = sprintf('%sSigma_%d_Method_%d_PVcapacity_%d_%d-%d-%d.mat', ...
                           mode_prefix{mode}, sigma, meth_num, PVC, ...
                           year_l, month_l, day_l);

        % 結果を results/ フォルダに保存
        save(fullfile(results_dir, filename), ...
             'PV_CUR', 'LFC_t', 'Reserved_power', 'PV_real_Output', ...
             'LFC_up', 'LFC_down', 'PV_MAX', 'G_Out_UC', 'g_const_out_sum', ...
             'load_forecast_input', 'PV_Forecast', 'Oil_Output', 'Coal_Output', ...
             'Combine_Output', 'LOF', 'PVF', 'dpout', 'load_input', 'dfout', ...
             'TieLineLoadout', 'LFC_Output', 'EDC_Output', 'PV_Out', ...
             'LFC', 'inertia_input');

        fprintf('  [5/5] 保存完了: %s\n', fullfile(results_dir, filename));

    end % PVC ループ
end % 日付ループ

fprintf('\n========================================\n');
fprintf(' 全シミュレーション完了\n');
fprintf(' 結果保存先: %s\n', results_dir);
fprintf('========================================\n');
