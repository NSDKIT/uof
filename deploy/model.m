%% =========================================================================
%  model.m  ─  電力系統需給運用シミュレーション メインスクリリプト
% =========================================================================
%
% 【概要】
%   このスクリプトを MATLAB で実行するだけで、以下の処理が自動的に実施されます。
%   1. 必要なパスの設定（環境依存なし・相対パスで管理）
%   2. 入力データ（PV・需要）の準備
%   3. 発電機起動停止計画（Unit Commitment）の最適化
%   4. Simulink モデル（AGC30_PVcut.slx）による動的シミュレーション
%   5. 結果の保存（results/ フォルダへ）
%
% 【使い方】
%   1. MATLAB を起動する
%   2. このファイル（model.m）が置かれているフォルダを
%      カレントディレクトリに設定する
%   3. コマンドウィンドウで  model  と入力して Enter を押す
%
% =========================================================================

%% ── 初期化 ──────────────────────────────────────────────────────────────
clear; close all; clc;

%% ── パス設定（環境依存なし・相対パスで管理）────────────────────────────
ROOT_DIR = fileparts(mfilename(\'fullpath\'));
cd(ROOT_DIR);
addpath(genpath(ROOT_DIR));

results_dir = fullfile(ROOT_DIR, \'results\');
if ~exist(results_dir, \'dir\')
    mkdir(results_dir);
    fprintf(\'[INFO] 結果保存フォルダを作成しました: %s\n\', results_dir);
end

uc_backup_dir = fullfile(ROOT_DIR, \'UC立案\', \'MATLAB\', \'uc_backup\');
if ~exist(uc_backup_dir, \'dir\')
    mkdir(uc_backup_dir);
end

%% ── 外部ツール・データフォルダ設定 ──────────────────────────────────────
% ▼▼▼ 環境に合わせて変更してください ▼▼▼
% wgrib2.exe が置かれているフォルダ（MSMバイナリの処理に使用）
WGRIB2_DIR  = fullfile(ROOT_DIR, \'wgrib2\');
% MSM気象データ（.binファイル）が格納されているフォルダ
MSM_DATA_DIR = fullfile(ROOT_DIR, \'MSMデータ\');
% ▲▲▲ 設定ここまで ▲▲▲

save(fullfile(ROOT_DIR, \'WGRIB2_DIR.mat\'),   \'WGRIB2_DIR\');
save(fullfile(ROOT_DIR, \'MSM_DATA_DIR.mat\'), \'MSM_DATA_DIR\');

fprintf(\'[INFO] ROOT_DIR    = %s\n\', ROOT_DIR);
fprintf(\'[INFO] results_dir = %s\n\', results_dir);
fprintf(\'[INFO] WGRIB2_DIR  = %s\n\', WGRIB2_DIR);
fprintf(\'[INFO] MSM_DATA_DIR= %s\n\', MSM_DATA_DIR);

%% ── シミュレーション条件設定 ─────────────────────────────────────────────
% ▼▼▼ ここを変更してシミュレーション条件を設定してください ▼▼▼
YYYYMMDD_list = [\'20190828\'];
PVC_list = [5300];
meth_num_list = [2];
mode_list = [1];
error_ox = 0;
sigma = 2;
lfc = 8;
% ▲▲▲ 設定ここまで ▲▲▲

%% ── 年度カレンダーの作成 ────────────────────────────────────────────────
start_date   = datetime(2019, 4, 1);
end_date     = datetime(2020, 3, 31);
date_range   = start_date:end_date;
date_strings = datestr(date_range, \'yyyymmdd\');

%% ── メインループ ─────────────────────────────────────────────────────────
fprintf(\'\n========================================\n\');
fprintf(\' シミュレーション開始\n\');
fprintf(\'========================================\n\');

save(fullfile(ROOT_DIR, \'error_ox.mat\'), \'error_ox\');
save(fullfile(ROOT_DIR, \'sigma.mat\'),    \'sigma\');
save(fullfile(ROOT_DIR, \'lfclfc.mat\'),   \'lfc\');
save(fullfile(ROOT_DIR, \'ROOT_DIR.mat\'), \'uc_backup_dir\');

for meth_num = meth_num_list
    save(fullfile(ROOT_DIR, \'meth_num.mat\'), \'meth_num\');

    for day_idx = 1:size(YYYYMMDD_list, 1)
        YYYYMMDD = YYYYMMDD_list(day_idx, :);
        save(fullfile(ROOT_DIR, \'YYYYMMDD.mat\'), \'YYYYMMDD\');

        year_l  = str2num(YYYYMMDD(1:4));
        month_l = str2num(YYYYMMDD(5:6));
        day_l   = str2num(YYYYMMDD(7:8));
        DN = find(strcmp(cellstr(date_strings), YYYYMMDD));

        fprintf(\'\n[%d/%d] 対象日: %s (年度内 %d 日目), 手法: %d\n\', ...
                day_idx, size(YYYYMMDD_list,1), YYYYMMDD, DN, meth_num);

        save(fullfile(ROOT_DIR, \'YMD.mat\'), \'year_l\', \'month_l\', \'day_l\', \'DN\');

        setup_fixed_params;

        for mode = mode_list
            save(fullfile(ROOT_DIR, \'mode.mat\'), \'mode\');

            for PVC = PVC_list
                save(fullfile(ROOT_DIR, \'PVC.mat\'), \'PVC\');

                fprintf(\'\n  PV導入容量: %d MW, パネルモード: %d\n\', PVC, mode);

                clearvars -except ROOT_DIR results_dir uc_backup_dir ...
                                  YYYYMMDD_list meth_num_list mode_list PVC_list ...
                                  error_ox sigma lfc date_strings ...
                                  meth_num YYYYMMDD DN year_l month_l day_l mode PVC ...
                                  day_idx;

                y = year_l;
                if year_l == 2020 && month_l <= 3, y = year_l - 1; end

                %% ── [1/5] 基本データの読み込み ──────────────────────────
                fprintf(\'  [1/5] 基本データを読み込み中...\n\');
                
                % --- 入力ファイルの存在チェック ---
                required_files = {
                    fullfile(ROOT_DIR, \'基本データ\', [\'PV_base_\', num2str(y), \'.mat\']),
                    fullfile(ROOT_DIR, \'基本データ\', [\'PR_\', num2str(y), \'.mat\']),
                    fullfile(ROOT_DIR, \'基本データ\', [\'MSM_bai_\', num2str(y), \'.mat\']),
                    fullfile(ROOT_DIR, \'基本データ\', \'irr_fore_data.mat\'),
                    fullfile(ROOT_DIR, \'基本データ\', \'D_1sec.mat\'),
                    fullfile(ROOT_DIR, \'基本データ\', \'D_30min.mat\'),
                    fullfile(ROOT_DIR, \'基本データ\', \'irr_mea_data.mat\')
                };
                
                missing_files = {};
                for i = 1:length(required_files)
                    if ~exist(required_files{i}, \'file\')
                        missing_files{end+1} = required_files{i};
                    end
                end
                
if ~isempty(missing_files)
                    fprintf(\\'  [WARN]  必須入力ファイルが不足しています。前処理を実行します...\\n\\');
                    for i = 1:length(missing_files)
                        fprintf(\\'    - 不足ファイル: %s\\n\\', missing_files{i});
                    end

                    % lfc の値に応じて実行する前処理スクリプトを決定
                    if lfc >= 100
                        fprintf(\\'  [INFO]  非AGCモード (lfc=%d) のため、通常版の前処理を実行します。\\n\\', lfc);
                        pv_script_path      = fullfile(ROOT_DIR, \\'PV実出力作成\\', \\'calc_pv_actual_output.m\\');
                        pvf_script_path     = fullfile(ROOT_DIR, \\'予測PV出力作成\\', \\'calc_pv_forecast_year.m\\');
                        load_script_path    = fullfile(ROOT_DIR, \\'需要実績・予測作成\\', \\'calc_demand.m\\');
                    else
                        fprintf(\\'  [INFO]  AGCモード (lfc=%d) のため、AGC版の前処理を実行します。\\n\\', lfc);
                        pv_script_path      = fullfile(ROOT_DIR, \\'PV実出力作成\\', \\'calc_pv_actual_output_agc.m\\');
                        pvf_script_path     = fullfile(ROOT_DIR, \\'予測PV出力作成\\', \\'calc_pv_forecast_year_agc.m\\');
                        load_script_path    = fullfile(ROOT_DIR, \\'需要実績・予測作成\\', \\'calc_demand.m\\'); % calc_demand.m 内部で lfc を見て分岐する
                    end

                    try
                        fprintf(\\'  [RUN]   需要データを作成中...\\n\\');
                        run(load_script_path);
                        fprintf(\\'  [RUN]   PV予測データを作成中...\\n\\');
                        run(pvf_script_path);
                        fprintf(\\'  [RUN]   PV実績データを作成中...\\n\\');
                        run(pv_script_path);
                        fprintf(\\'  [SUCCESS] 前処理が完了しました。シミュレーションを続行します。\\n\\');
                    catch ME_preprocess
                        fprintf(\\'  [ERROR] 前処理の実行中にエラーが発生しました: %s\\n\\', ME_preprocess.message);
                        fprintf(\\'  [INFO]  前処理に必要な手動データ（Excel, CSV等）が配置されているか確認してください。\\n\\');
                        fprintf(\\'  [SKIP]  このケースをスキップします。\\n\\');
                        continue;
                    end
                end
                % --- チェックここまで ---

                try
                    load(required_files{1}); % PV_base
                    PV_base = [PV_base(end-2:end,3)\\'', PV_base(1:end-3,3)\\''];
                    load(required_files{2}); % PR
                    load(required_files{3}); % MSM_bai
                    load(required_files{4}); % irr_fore_data
                    load(required_files{5}); % D_1sec
                    load(required_files{6}); % D_30min
                    load(required_files{7}); % irr_mea_data
                catch ME_load
                    fprintf(\'  [ERROR] 基本データの読み込み中に予期せぬエラーが発生: %s\n\', ME_load.message);
                    continue;
                end

                %% ── [2/5] PV 予測・実績出力と需要データの計算 ───────────
                fprintf(\'  [2/5] PV/需要データを計算中...\n\');
                n_l = [1, mode];
                PV_al = 1100;

                PVF_30min_al  = irr_fore_data(24*((DN-1)-1)+1 : 24*(DN-1), n_l(1)) * MSM_bai(month_l) * PR(month_l) * PV_base(month_l) / 1000;
                PVF_30min_new = irr_fore_data(24*((DN-1)-1)+1 : 24*(DN-1), n_l(2)) * MSM_bai(month_l) * PR(month_l) * PV_base(month_l) / 1000;
                PVF_30min = PVF_30min_al * PV_al / PV_base(month_l) + PVF_30min_new * (PVC - PV_al) / PV_base(month_l);
                x = 1:24;  xq_1min = 1:1/2:24;
                PVF_30min = [interp1(x, PVF_30min, xq_1min), 0, 0, 0];
                PVF_30min(isnan(PVF_30min)) = 0;
                save(fullfile(ROOT_DIR, \'PVF_30min.mat\'), \'PVF_30min\');

                demand_1sec  = D_1sec(DN, :)  - 500;
                demand_30min = D_30min(DN, :) - 500;
                save(fullfile(ROOT_DIR, \'demand_30min.mat\'), \'demand_30min\');
                save(fullfile(ROOT_DIR, \'demand_1sec.mat\'),  \'demand_1sec\');

                PV_1sec_al  = irr_mea_data(86401*(DN-1)+1 : 86401*DN, n_l(1)) * PR(month_l) * PV_base(month_l) / 1000;
                PV_1sec_new = irr_mea_data(86401*(DN-1)+1 : 86401*DN, n_l(2)) * PR(month_l) * PV_base(month_l) / 1000;
                PV_1sec = PV_1sec_al * PV_al / PV_base(month_l) + PV_1sec_new * (PVC - PV_al) / PV_base(month_l);
                save(fullfile(ROOT_DIR, \'PV_1sec.mat\'), \'PV_1sec\');

                if DN == 91
                    try
                        load(fullfile(results_dir, [\'PV_\', num2str(PVC), \".mat\"]), \'load_input\', \'PVF\', \'PV_real_Output\');
                        demand_1sec  = [load_input, load_input(end)*ones(1,3599)];
                        demand_30min = demand_1sec(1:1800:end);
                        save(fullfile(ROOT_DIR, \'demand_1sec.mat\'),  \'demand_1sec\');
                        save(fullfile(ROOT_DIR, \'demand_30min.mat\'), \'demand_30min\');
                        PVF_30min = [PVF(1:1800:end), 0];
                        save(fullfile(ROOT_DIR, \'PVF_30min.mat\'), \'PVF_30min\');
                        PV_1sec = [nan; PV_real_Output(2,:)\\''];
                        save(fullfile(ROOT_DIR, \'PV_1sec.mat\'), \'PV_1sec\');
                        fprintf(\'  [INFO] 特殊日(DN=91)のデータを上書きしました。\n\');
                    catch
                        fprintf(\'  [WARN] 特殊日(DN=91)のデータファイルが見つかりません。\n\');
                    end
                end

                %% ── [3/5] 起動停止計画（Unit Commitment）────────────────────
                fprintf(\'  [3/5] 起動停止計画（UC）を計算中...\n\');
                cd(fullfile(ROOT_DIR, \'UC立案\', \'MATLAB\'));
                uc_success = false;
                try
                    run_unit_commitment;
                    uc_success = true;
                catch ME_uc
                    fprintf(\'  [ERROR] UC計算中にエラー: %s\n\', ME_uc.message);
                end
                cd(ROOT_DIR);

                if uc_success
                    copyfile(fullfile(ROOT_DIR, \'UC立案\', \'MATLAB\', \'*.csv\'), fullfile(ROOT_DIR, \'運用\'));
                else
                    fprintf(\'  [ERROR] UC計算に失敗したため、このケースをスキップします。\n\');
                    continue;
                end

                %% ── [4/5] Simulink 動的シミュレーション ──────────────────
                fprintf(\'  [4/5] Simulink シミュレーションを実行中...\n\');
                cd(fullfile(ROOT_DIR, \'運用\'));
                try
                    build_simulink_input_csv;
                    fprintf(\'       モデルパラメータを初期化中...\n\');
                    init_simulation_data; init_inertia_model; init_tieline_model; init_lfc_model;
                    init_edc_model; init_thermal_model; init_other_area_model;

                    P_F = struct(\'PV_Forecast\', PV_Forecast);
                    PVF = P_F.PV_Forecast(2, :);
                    L_F = struct(\'load_forecast_input\', load_forecast_input);
                    LOF = L_F.load_forecast_input(2, :);
                    save(fullfile(ROOT_DIR, \'FO.mat\'), \'PVF\', \'LOF\');

                    P_M = struct(\'PV_Out\', PV_Out);
                    PV_MAX = max(P_M.PV_Out(2, :));
                    save(fullfile(ROOT_DIR, \'PV_MAX.mat\'), \'PV_MAX\');

                    apply_pv_lowpass_filter;
                    PV_real_Output = PV_Out;
                    save(fullfile(ROOT_DIR, \'PV_real_Output.mat\'), \'PV_real_Output\');

                    if lfc >= 100, sim(\'Hydro_load.slx\'); else, sim(\'AGC30_PVcut.slx\'); end
                    fprintf(\'       シミュレーション終了\n\');

                    %% ── [5/5] 結果の収集と保存 ────────────────────────────────
                    fprintf(\'  [5/5] シミュレーション結果を保存中...\n\');

                    M = load(fullfile(ROOT_DIR, \'inertia_input.mat\'));
                    inertia_input = M.inertia_input;
                    FO  = load(fullfile(ROOT_DIR, \'FO.mat\'));
                    PVF = FO.PVF; LOF = FO.LOF;
                    LFC_data = load(fullfile(ROOT_DIR, \'UC立案\', \'LFC.mat\'));

                    G_Out_UC = import_generator_output(\'G_Out.csv\');
                    LFC_up   = import_lfc_updown_limit(\'G_up_plan_limit.csv\');
                    LFC_down = import_lfc_updown_limit(\'G_down_plan_limit.csv\');
                    g_c_o_s  = struct(\'g_const_out_sum\', g_const_out_sum);
                    g_const_out_sum = g_c_o_s.g_const_out_sum(2, :);
                    LFC_t    = import_lfc_up_limit_time(\'G_up_plan_limit_time.csv\');

                    inertia_input = inertia_input(2, :);
                    load_forecast_input = load_forecast_input(2, :);
                    load_input = load_input(2, :);
                    PV_Forecast = PV_Forecast(2, :);
                    PV_Out = PV_Out(2, :);

                    mode_prefix = [\'n\', \'E\', \'W\', \'T\', \'T_V\'];
                    filename = sprintf(\'%s_Sigma%d_Method%d_PV%d_%s.mat\', ...
                                     mode_prefix(mode), sigma, meth_num, PVC, YYYYMMDD);

                    save(fullfile(results_dir, filename), ...
                         \'PV_CUR\', \'LFC_t\', \'Reserved_power\', \'PV_real_Output\', ...
                         \'LFC_up\', \'LFC_down\', \'PV_MAX\', \'G_Out_UC\', \'g_const_out_sum\', ...
                         \'load_forecast_input\', \'PV_Forecast\', \'Oil_Output\', \'Coal_Output\', ...
                         \'Combine_Output\', \'LOF\', \'PVF\', \'dpout\', \'load_input\', \'dfout\', ...
                         \'TieLineLoadout\', \'LFC_Output\', \'EDC_Output\', \'PV_Out\', ...
                         \'LFC_data\', \'inertia_input\');
                    fprintf(\'  [5/5] 保存完了: %s\n\', fullfile(results_dir, filename));

                catch ME_sim
                    fprintf(\'  [ERROR] Simulink実行/結果保存中にエラー: %s\n\', ME_sim.message);
                end
                cd(ROOT_DIR);

            end
        end
    end
end

fprintf(\'\n========================================\n\');
fprintf(\' 全シミュレーション完了\n\');
fprintf(\' 結果保存先: %s\n\', results_dir);
fprintf(\'========================================\n\');
