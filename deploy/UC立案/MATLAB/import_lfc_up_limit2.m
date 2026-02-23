function Gupplanlimit = import_lfc_up_limit2(filename, dataLines)
%IMPORTFILE1 テキスト ファイルからデータをインポート
%  GUPPLANLIMIT = IMPORTFILE1(FILENAME) は既定の選択に関してテキスト ファイル FILENAME
%  からデータを読み取ります。  数値データを返します。
%
%  GUPPLANLIMIT = IMPORTFILE1(FILE, DATALINES) はテキスト ファイル FILENAME
%  の指定された行区間のデータを読み取ります。DATALINES
%  を正の整数スカラーとして指定するか、行区間が不連続の場合は正の整数スカラーからなる N 行 2 列の配列として指定します。
%
%  例:
%  Gupplanlimit = importfile1("E:\01_研究資料\UC最適化\G_up_plan_limit.csv", [1, Inf]);
%
%  READTABLE も参照してください。
%
% MATLAB からの自動生成日: 2022/09/02 19:18:52

%% 入力の取り扱い

% dataLines が指定されていない場合、既定値を定義します
if nargin < 2
    dataLines = [1, Inf];
end

%% インポート オプションの設定およびデータのインポート
opts = delimitedTextImportOptions("NumVariables", 2);

% 範囲と区切り記号の指定
opts.DataLines = dataLines;
opts.Delimiter = ",";

% 列名と型の指定
opts.VariableNames = ["G", "VarName2"];
opts.VariableTypes = ["double", "double"];

% ファイル レベルのプロパティを指定
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% 変数プロパティを指定
opts = setvaropts(opts, "G", "TrimNonNumeric", true);
opts = setvaropts(opts, "G", "ThousandsSeparator", ",");

% データのインポート
Gupplanlimit = readtable(filename, opts);

%% 出力型への変換
Gupplanlimit = table2array(Gupplanlimit);
end