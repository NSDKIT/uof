%% =========================================================
%  util_get_row_index_by_date.m  ―  日付から通算行番号を取得するユーティリティ
% =========================================================
%
%  【役割】
%    指定した年・月・日から、data_YYYY.mat における行番号（通算日）を
%    検索して戻り値として返す。
%    グローバル変数・assignin を使わず、どの環境でも安全に動作する。
%
%  【呼び出し方法】
%    row = util_get_row_index_by_date(year, month, day)
%
%  【引数】
%    year  : 西暦年（例: 2018）
%    month : 月（1〜12）
%    day   : 日（1〜31）
%
%  【戻り値】
%    row   : data 配列における行番号（通算日）
%            ※ 1〜3月は year+1 として扱われる（4月始まり年度のため）
%
%  【入力ファイル】
%    input_data/data_YYYY.mat  ← 変数 data（各行: [年, 月, 日, ...]）
%
%  【使用するスクリプト】
%    step4_calc_error_by_capacity.m
%    util_calc_sigma_per_band_extended.m
%    viz_compare_forecast_vs_actual.m
%
%  【注意事項】
%    - 1月〜3月は year+1 として扱われる（4月始まり年度のため）。
%    - 同月・同日が複数行ある場合、最初の行番号が返される。
%    - deploy/ フォルダをカレントディレクトリとして実行すること。
% =========================================================

function row = util_get_row_index_by_date(year, month, day)
%% --- データ読み込み（相対パス: input_data フォルダ） ---
load(fullfile('input_data', ['data_', num2str(year), '.mat']))
% 変数: data → 日付配列 [年, 月, 日, ...]

%% --- 1〜3月は翌年扱い（4月始まり年度） ---
if month < 4
    year = year + 1;
end

%% --- 指定した月・日の行番号を検索 ---
a = data(find(data(:,2) == month), :);  % 当月の行を抽出
b = a(find(a(:,3) == day), :);          % 当日の行を抽出

if isempty(b)
    error('util_get_row_index_by_date: %d年%d月%d日のデータが見つかりません。', year, month, day);
end

row = b(1);  % 最初の行番号を返す（通算日）
end
