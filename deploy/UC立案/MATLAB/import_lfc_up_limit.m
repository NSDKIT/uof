function Gupplanlimit = import_lfc_up_limit(filename, dataLines)
%IMPORTFILE1 テキスト ファイルからデータをインポート
%  GUPPLANLIMIT = IMPORTFILE1(FILENAME) は既定の選択に関してテキスト ファイル FILENAME
%  からデータを読み取ります。  数値データを返します。
%
%  GUPPLANLIMIT = IMPORTFILE1(FILE, DATALINES) はテキスト ファイル FILENAME
%  の指定された行区間のデータを読み取ります。DATALINES
%  を正の整数スカラーとして指定するか、行区間が不連続の場合は正の整数スカラーからなる N 行 2 列の配列として指定します。
%
%  例:
%  Gupplanlimit = importfile1("C:\Users\PowerSystemLab\Desktop\01_研究資料\05_実行ファイル\program\全体実行\UC立案\MATLAB\G_up_plan_limit.csv", [1, Inf]);
%
%  READTABLE も参照してください。
%
% MATLAB からの自動生成日: 2022/10/05 18:36:26

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
opts.VariableNames = ["VarName1", "VarName2"];
opts.VariableTypes = ["double", "double"];

% ファイル レベルのプロパティを指定
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% データのインポート
Gupplanlimit = readtable(filename, opts);

%% 出力型への変換
Gupplanlimit = table2array(Gupplanlimit);
end