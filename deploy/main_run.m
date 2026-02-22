%% =========================================================
%  main_run.m  ―  全処理の一括実行スクリプト
%  =========================================================
%
%  【役割】
%    このスクリプトを実行するだけで、PV予測誤差分析の全処理を
%    順番に実行する。初めてこのプロジェクトを実行する人向けの
%    エントリーポイント。
%
%  【実行前の準備】
%    1. MATLABのカレントディレクトリを「deploy/」フォルダに設定すること
%       （MATLABのGUIで deploy/ を開く、またはコマンドウィンドウで
%        >> cd('C:\...\deploy')  を実行）
%
%    2. deploy/input_data/ フォルダに以下のファイルを配置すること:
%       ┌─────────────────────────────────┬────────────────────────────────────────┐
%       │ ファイル名                      │ 内容                                   │
%       ├─────────────────────────────────┼────────────────────────────────────────┤
%       │ data_2018.mat                   │ 2018年度の日付配列                     │
%       │ data_2019.mat                   │ 2019年度の日付配列                     │
%       │ PV_base_2018.mat                │ 2018年度の基準PV導入量（月別）         │
%       │ PV_base_2019.mat                │ 2019年度の基準PV導入量（月別）         │
%       │ PR_2018.mat                     │ 2018年度のシステム性能係数（月別）     │
%       │ PR_2019.mat                     │ 2019年度のシステム性能係数（月別）     │
%       │ Radiation_fcst_2018.mat         │ 2018年度の予測日射量                   │
%       │ Radiation_fcst_2019.mat         │ 2019年度の予測日射量                   │
%       │ PV_capa_2018.mat                │ 2018年度の実際のPV導入容量（月別）     │
%       │ PV_capa_2019.mat                │ 2019年度の実際のPV導入容量（月別）     │
%       │ Pv_real_out_2018.mat            │ 2018年度のPV実績出力（補正前）         │
%       │ Pv_real_out_2019.mat            │ 2019年度のPV実績出力（補正前）         │
%       │ Load_2018.mat                   │ 2018年度の電力需要                     │
%       │ Load_2019.mat                   │ 2019年度の電力需要                     │
%       │ douteki_lfc_ab.mat              │ LFC容量計算の係数（a, b）              │
%       │ new_ave_PV.mat                  │ 平均的なPV出力カーブ                   │
%       │ new_ave_load.mat                │ 平均的な負荷カーブ                     │
%       │ PVC.mat                         │ PV設備容量                             │
%       │ time_label.mat                  │ 時刻ラベル（グラフ表示用）             │
%       └─────────────────────────────────┴────────────────────────────────────────┘
%
%    3. 外部関数が MATLABパス上に存在することを確認すること:
%       - Mabiki(data, n)          ← PV実績データのダウンサンプリング
%       - KAKURITUBU_BUNNPU(...)   ← 確率分布計算（σ取得）
%       - KAKURITUBU_BUNNPU1(...)  ← 確率分布計算（拡張版）
%       - sec_time_30min           ← X軸の時刻ラベル設定
%       - get_color                ← グラフの色設定
%
%  【実行方法】
%    >> main_run
%
%  【処理の流れ】
%    Step 1: PV予測出力の生成    → output/PV_forecast_YYYY.mat
%    Step 2: PV実績出力の生成    → output/PV_YYYY.mat
%    Step 3: 予測誤差の計算      → output/ERROR_YYYY.mat
%    Step 4: 容量別・日別誤差の生成 → output/予測PV出力誤差/ERRORyyyymmdd.mat
%    Step 5: σ計算              → output/動的LFC容量決定手法/error_sigma.mat
%    Step 6: LFC必要容量の計算   → output/動的LFC容量決定手法/LFC_amount_*.mat
%
%  【注意事項】
%    - Step 4 は処理に時間がかかる（365日×12ヶ月分のファイルを生成するため）
%    - Step 5 の SIGMA_get1 は外部関数 KAKURITUBU_BUNNPU1 が必要
%    - 可視化スクリプト（viz_compare_forecast_vs_actual, viz_plot_error_bar_by_day 等）は
%      このスクリプトには含まれていない。必要に応じて個別に実行すること。
% =========================================================

%% =========================================================
%  【設定】対象年度とパラメータをここで変更する
% =========================================================

YEARS = [2018, 2019];   % 処理対象の年度（複数年を配列で指定可能）
PVC_bai = 1.0;          % PV導入量の倍率（1.0=基準, 1.5=1.5倍, 2.0=2倍）

%% =========================================================
%  【事前確認】カレントディレクトリの確認
% =========================================================

fprintf('==============================================\n');
fprintf('  main_run.m: 全処理の一括実行を開始します\n');
fprintf('==============================================\n');
fprintf('カレントディレクトリ: %s\n', pwd);
fprintf('対象年度: %s\n', num2str(YEARS));
fprintf('PV導入量倍率: %.1f 倍\n\n', PVC_bai);

% input_data フォルダの存在確認
if ~exist('input_data', 'dir')
    error(['[エラー] input_data フォルダが見つかりません。\n' ...
           'MATLABのカレントディレクトリを deploy/ フォルダに設定してください。\n' ...
           '現在のディレクトリ: %s'], pwd);
end

% output フォルダの作成（存在しない場合）
if ~exist('output', 'dir')
    mkdir('output');
    fprintf('[情報] output フォルダを作成しました。\n');
end

%% =========================================================
%  Step 1: PV予測出力の生成
%  入力: input_data/PV_base_YYYY.mat, PR_YYYY.mat,
%         Radiation_fcst_YYYY.mat, data_YYYY.mat
%  出力: output/PV_forecast_YYYY.mat
% =========================================================

fprintf('------ Step 1: PV予測出力の生成 ------\n');
for year = YEARS
    fprintf('  処理中: %d年度 ... ', year);
    try
        step1_generate_pv_forecast(year);
        fprintf('完了\n');
    catch ME
        fprintf('エラー: %s\n', ME.message);
        warning('Step 1 (%d年) でエラーが発生しました。Step 2 以降をスキップします。', year);
        continue
    end
end

%% =========================================================
%  Step 2: PV実績出力の生成
%  入力: input_data/PV_capa_YYYY.mat, Pv_real_out_YYYY.mat,
%         data_YYYY.mat
%  出力: output/PV_YYYY.mat
%  注意: 外部関数 Mabiki が必要
% =========================================================

fprintf('\n------ Step 2: PV実績出力の生成 ------\n');
for year = YEARS
    fprintf('  処理中: %d年度 ... ', year);
    try
        step2_generate_pv_actual(year);
        fprintf('完了\n');
    catch ME
        fprintf('エラー: %s\n', ME.message);
        warning('Step 2 (%d年) でエラーが発生しました。', year);
    end
end

%% =========================================================
%  Step 3: 予測誤差の計算
%  入力: output/PV_forecast_YYYY.mat, output/PV_YYYY.mat,
%         input_data/Load_YYYY.mat, input_data/PV_base_YYYY.mat
%  出力: output/ERROR_YYYY.mat
% =========================================================

fprintf('\n------ Step 3: 予測誤差の計算 ------\n');
for year = YEARS
    fprintf('  処理中: %d年度 ... ', year);
    try
        step3_calc_forecast_error(year);
        fprintf('完了\n');
    catch ME
        fprintf('エラー: %s\n', ME.message);
        warning('Step 3 (%d年) でエラーが発生しました。', year);
    end
end

%% =========================================================
%  Step 4: 容量別・日別予測誤差ファイルの生成
%  入力: output/ERROR_YYYY.mat, input_data/data_YYYY.mat,
%         input_data/PV_capa_YYYY.mat
%  出力: output/予測PV出力誤差/ERRORyyyymmdd.mat
%  注意: 処理に時間がかかる（365日分のファイルを生成）
% =========================================================

fprintf('\n------ Step 4: 容量別・日別予測誤差の生成（時間がかかります）------\n');
for year = YEARS
    fprintf('  処理中: %d年度 ... \n', year);
    try
        step4_calc_error_by_capacity(year);
        fprintf('  %d年度 完了\n', year);
    catch ME
        fprintf('  エラー: %s\n', ME.message);
        warning('Step 4 (%d年) でエラーが発生しました。', year);
    end
end

%% =========================================================
%  Step 5: σ計算（PV出力帯域別・全期間）
%  入力: output/ERROR_YYYY.mat, input_data/data_YYYY.mat,
%         output/PV_forecast_YYYY.mat
%  出力: output/動的LFC容量決定手法/error_sigma.mat
%  注意: 外部関数 KAKURITUBU_BUNNPU1 が必要
% =========================================================

fprintf('\n------ Step 5: σ計算 ------\n');
for year = YEARS
    fprintf('  処理中: %d年度（PV出力帯域別σ、全期間） ... \n', year);
    try
        % mode1=1: PV出力帯域別σ, mode2/mode3: 省略（全期間）
        step5_calc_sigma_by_output_band(year, 1, [], [], PVC_bai);
        fprintf('  %d年度 完了\n', year);
    catch ME
        fprintf('  エラー: %s\n', ME.message);
        warning('Step 5 (%d年) でエラーが発生しました。', year);
    end
end

%% =========================================================
%  Step 6: 動的LFC必要容量の計算（サンプル: 各年の代表日）
%  入力: input_data/douteki_lfc_ab.mat, new_ave_PV.mat,
%         new_ave_load.mat
%  出力: output/動的LFC容量決定手法/LFC_amount_yyyymmdd.mat
%  注意: ここでは代表日（6月15日）のみ計算。必要に応じて日付を変更すること。
% =========================================================

fprintf('\n------ Step 6: 動的LFC必要容量の計算（代表日） ------\n');
SAMPLE_MONTHS = [4, 7, 10, 1];   % 代表月（春・夏・秋・冬）
SAMPLE_DAY    = 15;               % 代表日

for year = YEARS
    for month = SAMPLE_MONTHS
        fprintf('  処理中: %d年 %d月%d日 (PV倍率=%.1f) ... ', year, month, SAMPLE_DAY, PVC_bai);
        try
            step6_calc_lfc_capacity(year, month, SAMPLE_DAY, PVC_bai);
            fprintf('完了\n');
        catch ME
            fprintf('エラー: %s\n', ME.message);
        end
    end
end

%% =========================================================
%  完了メッセージ
% =========================================================

fprintf('\n==============================================\n');
fprintf('  全処理が完了しました。\n');
fprintf('  出力ファイルは output/ フォルダを確認してください。\n');
fprintf('==============================================\n');
fprintf('\n【出力フォルダ構成】\n');
fprintf('  output/\n');
fprintf('    PV_forecast_YYYY.mat         ← PV予測出力\n');
fprintf('    PV_YYYY.mat                  ← PV実績出力\n');
fprintf('    ERROR_YYYY.mat               ← 予測誤差\n');
fprintf('    予測PV出力誤差/\n');
fprintf('      ERRORyyyymmdd.mat          ← 日別・容量別誤差\n');
fprintf('    動的LFC容量決定手法/\n');
fprintf('      error_sigma.mat            ← σ計算結果\n');
fprintf('      LFC_amount_yyyymmdd.mat    ← LFC必要容量\n');
fprintf('\n【可視化スクリプト（個別実行）】\n');
fprintf('  >> viz_compare_forecast_vs_actual(2018, 6, 1.0)              %% 月別比較グラフ\n');
fprintf('  >> viz_plot_error_bar_by_day(2018, 6, 1) %% 日別誤差棒グラフ\n');
fprintf('  >> eval_forecast_accuracy_boxplot                           %% 予測精度評価\n');
fprintf('  >> eval_calc_monthly_rmse                                    %% 月別RMSE計算\n');
