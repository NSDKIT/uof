function Untitled = get_TMP(filename, dataLines)
%IMPORTFILE1 テキスト ファイルからデータをインポート
%  UNTITLED = IMPORTFILE1(FILENAME) は既定の選択に関してテキスト ファイル FILENAME
%  からデータを読み取ります。  数値データを返します。
%
%  UNTITLED = IMPORTFILE1(FILE, DATALINES) はテキスト ファイル FILENAME
%  の指定された行区間のデータを読み取ります。DATALINES
%  を正の整数スカラーとして指定するか、行区間が不連続の場合は正の整数スカラーからなる N 行 2 列の配列として指定します。
%
%  例:
%  Untitled = importfile1("C:\Users\PowerSystemLab\Desktop\01_研究資料\test\16_33.csv", [1, Inf]);
%
%  READTABLE も参照してください。
%
% MATLAB からの自動生成日: 2021/10/17 21:29:42

%% 入力の取り扱い

% dataLines が指定されていない場合、既定値を定義します
if nargin < 2
    dataLines = [1, Inf];
end

%% インポート オプションの設定およびデータのインポート
opts = delimitedTextImportOptions("NumVariables", 4);

% 範囲と区切り記号の指定
opts.DataLines = dataLines;
opts.Delimiter = "=";

% 列名と型の指定
opts.VariableNames = ["Var1", "Var2", "Var3", "VarName4"];
opts.SelectedVariableNames = "VarName4";
opts.VariableTypes = ["string", "string", "string", "double"];

% ファイル レベルのプロパティを指定
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% 変数プロパティを指定
opts = setvaropts(opts, ["Var1", "Var2", "Var3"], "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["Var1", "Var2", "Var3"], "EmptyFieldRule", "auto");
opts = setvaropts(opts, "VarName4", "ThousandsSeparator", ",");

% データのインポート
Untitled = readtable(filename, opts);

%% 出力型への変換
Untitled = table2array(Untitled);
end