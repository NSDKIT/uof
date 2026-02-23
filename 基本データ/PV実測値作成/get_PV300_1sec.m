function day1 = get_PV300_1sec(filename, dataLines)
%IMPORTFILE1 テキスト ファイルからデータをインポート
%  DAY1 = IMPORTFILE1(FILENAME) は既定の選択に関してテキスト ファイル FILENAME
%  からデータを読み取ります。  数値データを返します。
%
%  DAY1 = IMPORTFILE1(FILE, DATALINES) はテキスト ファイル FILENAME
%  の指定された行区間のデータを読み取ります。DATALINES
%  を正の整数スカラーとして指定するか、行区間が不連続の場合は正の整数スカラーからなる N 行 2 列の配列として指定します。
%
%  例:
%  day1 = importfile1("C:\Users\PowerSystemLab\Desktop\01_研究資料\05_実行ファイル\program\全体実行\PV実出力作成\PV300\1秒値\area1\2018_4\day1.csv", [10, Inf]);
%
%  READTABLE も参照してください。
%
% MATLAB からの自動生成日: 2022/08/14 13:33:10

%% 入力の取り扱い

% dataLines が指定されていない場合、既定値を定義します
if nargin < 2
    dataLines = [10, Inf];
end

%% インポート オプションの設定およびデータのインポート
opts = delimitedTextImportOptions("NumVariables", 8);

% 範囲と区切り記号の指定
opts.DataLines = dataLines;
opts.Delimiter = ",";

% 列名と型の指定
opts.VariableNames = ["Var1", "INST", "Var3", "Var4", "Var5", "Var6", "Var7", "Var8"];
opts.SelectedVariableNames = "INST";
opts.VariableTypes = ["string", "double", "string", "string", "string", "string", "string", "string"];

% ファイル レベルのプロパティを指定
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% 変数プロパティを指定
opts = setvaropts(opts, ["Var1", "Var3", "Var4", "Var5", "Var6", "Var7", "Var8"], "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["Var1", "Var3", "Var4", "Var5", "Var6", "Var7", "Var8"], "EmptyFieldRule", "auto");

% データのインポート
day1 = readtable(filename, opts);

%% 出力型への変換
day1 = table2array(day1);
end