%% =========================================================
%  util_get_row_index_by_date.m  ―  日付から通算行番号を取得するユーティリティ
%  =========================================================
%
%  【役割】
%    指定した年・月・日から、data_YYYY.mat における行番号（通算日）を
%    検索し、ベースワークスペースの変数 a_day に返す。
%    単体では使用せず、他のスクリプトから補助的に呼び出されるユーティリティ。
%
%  【実行方法】（直接呼び出す場合）
%    >> util_get_row_index_by_date(2018, 6, 15)
%    >> disp(a_day)  % ベースワークスペースに a_day が作成される
%
%  【呼び出し元スクリプト】
%    - PV_compare.m
%    - PV_forecast_error_PVup_make.m
%    - util_calc_sigma_per_band_extended.m
%
%  【フォルダ構成の前提】
%    このスクリプトは deploy/ フォルダをカレントディレクトリとして実行する。
%    data_YYYY.mat は deploy/input_data/ フォルダに配置すること。
%
%  【入力ファイル】
%    input_data/data_YYYY.mat  ← 変数 data（各行: [年, 月, 日, ...]）
%
%  【出力】
%    ベースワークスペースに変数 a_day が作成される
%      a_day: 指定した日付の data 配列における行番号（通算日）
%
%  【注意事項】
%    - 1月〜3月は year+1 として扱われる（4月始まり年度のため）。
%    - 同月・同日が複数行ある場合、最初の行番号が返される（b(1)）。
% =========================================================

function util_get_row_index_by_date(year, month, day)

%% --- データ読み込み（相対パス: input_data フォルダ） ---
load(fullfile('input_data', ['data_',num2str(year),'.mat']))
% 変数: data → 日付配列 [年, 月, 日, ...]

%% --- 1〜3月は翌年扱い（4月始まり年度） ---
if month < 4
    year = year + 1;
end

%% --- 指定した月・日の行番号を検索 ---
a = data(find(data(:,2)==month), :);   % 当月の行を抽出
b = a(find(a(:,3)==day), :);           % 当日の行を抽出
a_day = b(1);                          % 最初の行番号を取得（通算日）

%% --- ベースワークスペースへ結果を返す ---
assignin('base', 'a_day', a_day)
% → 呼び出し元のワークスペースで "global a_day" または直接参照可能

end
