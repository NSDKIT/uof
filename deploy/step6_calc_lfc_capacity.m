%% =========================================================
%  step6_calc_lfc_capacity.m  ―  動的LFC容量の計算
%  =========================================================
%
%  【役割】
%    指定した日の30分断面ごとに、必要なLFC容量 [%] を以下の式で計算する。
%
%    LFC_t = min{ i | a_i * ε_t^PV + b_i - F0 >= 0 }
%
%    ここで:
%      i       : LFC容量の候補値 [%]（2, 3, 4, ..., 10）
%      a_i     : LFC容量 i [%] での近似直線の傾き
%      b_i     : LFC容量 i [%] での近似直線の切片
%      ε_t^PV  : 時刻断面 t における予測誤差σ [%]
%                （対象日の予測PV出力に応じた帯域のσを使用）
%      F0      : 周波数管理目標値 = 95（±0.1Hz での管理目標95%以上）
%
%  【a_i, b_i の選択ルール（季節対応）】
%    計算対象の月に応じて、以下のフォルダの kinnji_data ファイルを使用する:
%      4〜6月（春）  → input_data/approximation_lines/{year-1}_5/
%      7〜9月（夏）  → input_data/approximation_lines/{year-1}_8/
%      10〜12月（秋）→ input_data/approximation_lines/{year-1}_11/
%      1〜3月（冬）  → input_data/approximation_lines/{year-1}_1/
%
%  【ε_t^PV の選択ルール（帯域対応）】
%    時刻断面 t の予測PV出力に応じて error_sigma の列を選択する:
%      予測出力 < 200MW  → 列1
%      予測出力 < 400MW  → 列2
%      予測出力 < 600MW  → 列3
%      予測出力 < 800MW  → 列4
%      予測出力 < 1000MW → 列5
%      予測出力 < 1200MW → 列6
%      予測出力 < 1400MW → 列7
%      予測出力 >= 1400MW → 列8
%
%  【実行方法】
%    >> step6_calc_lfc_capacity(2019, 5, 15, 1.0)
%       → 2019年5月15日のLFC容量を計算
%
%  【パラメータ説明】
%    year    : 対象年（例: 2019）
%    month   : 対象月（例: 5）
%    day     : 対象日（例: 15）
%    PVC_bai : PV導入量の倍率（例: 1.0=基準, 2.0=2倍）
%
%  【前提条件（先に実行しておくこと）】
%    1. step1_generate_pv_forecast(year) → PV_forecast_YYYY.mat が存在すること
%    2. step5_calc_sigma_basic または step5_calc_sigma_by_output_band
%                                        → error_sigma.mat が存在すること
%
%  【入力ファイル】
%    output/PV_forecast_YYYY.mat
%      変数: data_all → PV予測出力（日数×50列）[MW]
%    output/動的LFC容量決定手法/error_sigma.mat
%      変数: error_sigma → [50行（時間断面）× 8列（帯域別σ幅）]
%    input_data/approximation_lines/{rep_year}_{rep_month}/
%      kinnji_data_{rep_year}{rep_month}_LFC_{i}%.mat
%      変数: a, b → 近似直線の傾きと切片
%    input_data/data_YYYY.mat
%      変数: data → 日付配列
%
%  【出力ファイル】
%    output/動的LFC容量決定手法/LFC_amount_yyyymmdd.mat
%      変数: LFC_amount → [50×1] 各時刻断面のLFC容量 [%]
%
%  【依存する関数・スクリプト】
%    - util_get_row_index_by_date.m  （日付→行番号変換）
% =========================================================

function step6_calc_lfc_capacity(year, month, day, PVC_bai)

%% --- 定数設定 ---
F0        = 95;          % 周波数管理目標値 [%]（±0.1Hz での管理目標95%以上）
LFC_cands = 2:10;        % LFC容量の候補値 [%]（2〜10%）
bands_mw  = [200, 400, 600, 800, 1000, 1200, 1400, Inf];  % 帯域境界 [MW]

%% --- 季節に応じた近似直線フォルダを決定 ---
% 計算対象の月に応じて前年度の代表月フォルダを選択
if month >= 4 && month <= 6
    rep_year  = year - 1;
    rep_month = 5;
elseif month >= 7 && month <= 9
    rep_year  = year - 1;
    rep_month = 8;
elseif month >= 10 && month <= 12
    rep_year  = year - 1;
    rep_month = 11;
else  % 1〜3月（冬）
    rep_year  = year - 1;
    rep_month = 1;
end

folder_name = [num2str(rep_year), '_', num2str(rep_month)];
ab_dir = fullfile('input_data', 'approximation_lines', folder_name);

%% --- 各LFC容量候補の a, b を読み込む ---
n_cands = length(LFC_cands);
a_vec = zeros(n_cands, 1);
b_vec = zeros(n_cands, 1);

for k = 1:n_cands
    lfc_pct = LFC_cands(k);
    fname = sprintf('kinnji_data_%d%d_LFC_%d%%.mat', rep_year, rep_month, lfc_pct);
    fpath = fullfile(ab_dir, fname);
    if ~exist(fpath, 'file')
        error('近似直線ファイルが見つかりません: %s\n使用フォルダ: %s', fpath, ab_dir);
    end
    tmp = load(fpath);   % 変数: a, b
    a_vec(k) = tmp.a;
    b_vec(k) = tmp.b;
end

%% --- 対象日の行番号を取得 ---
load(fullfile('input_data', ['data_', num2str(year), '.mat']))  % 変数: data
a_day = util_get_row_index_by_date(data, year, month, day);
if isempty(a_day)
    error('指定した日付 %d年%d月%d日 がデータに存在しません。', year, month, day);
end

%% --- 対象日のPV予測出力を読み込む ---
load(fullfile('output', ['PV_forecast_', num2str(year), '.mat']))  % 変数: data_all
pv_forecast_day = data_all(a_day, :) * PVC_bai;  % [1×50] 対象日の予測PV出力（倍率適用）[MW]

%% --- error_sigma を読み込む ---
load(fullfile('output', '動的LFC容量決定手法', 'error_sigma.mat'))
% 変数: error_sigma → [50行（時間断面）× 8列（帯域別σ幅）]

%% --- 時刻断面ごとにLFC容量を計算 ---
% LFC_t = min{ i | a_i * ε_t^PV + b_i - F0 >= 0 }
LFC_amount = zeros(50, 1);

for t = 1:50

    %% --- 時刻 t の予測PV出力に応じた帯域列を選択 ---
    pv_t = pv_forecast_day(t);
    band_col = find(pv_t < bands_mw, 1, 'first');  % 最初に条件を満たす帯域列
    if isempty(band_col)
        band_col = 8;  % 1400MW以上は列8
    end

    %% --- 時刻 t のε（予測誤差σ）を取得 ---
    eps_t = error_sigma(t, band_col);  % スカラー [%]

    %% --- LFC容量候補を小さい順に評価し、条件を満たす最小値を選択 ---
    % 条件: a_i * ε_t^PV + b_i - F0 >= 0
    lfc_selected = LFC_cands(end);  % デフォルト: 全候補で条件を満たさない場合は最大値（10%）
    for k = 1:n_cands
        val = a_vec(k) * eps_t + b_vec(k) - F0;
        if val >= 0
            lfc_selected = LFC_cands(k);
            break  % 最小値が見つかったのでループを抜ける
        end
    end

    LFC_amount(t) = lfc_selected;
end

%% --- 結果の保存 ---
out_dir = fullfile('output', '動的LFC容量決定手法');
if ~exist(out_dir, 'dir')
    mkdir(out_dir)
end

date_str = sprintf('%04d%02d%02d', year, month, day);
out_file = fullfile(out_dir, ['LFC_amount_', date_str, '.mat']);
save(out_file, 'LFC_amount')
% → 保存先: output/動的LFC容量決定手法/LFC_amount_yyyymmdd.mat
% → 変数 LFC_amount: [50×1] 各時刻断面のLFC容量 [%]

fprintf('  LFC容量計算完了: %s年%s月%s日 → %s\n', ...
    num2str(year), num2str(month), num2str(day), out_file);

end
