function Gupplanlimittime = get_Gupplanlimittime(filename, dataLines)
%IMPORTFILE1 テキスト ファイルからデータをインポート
%  GUPPLANLIMITTIME = IMPORTFILE1(FILENAME) は既定の選択に関してテキスト ファイル FILENAME
%  からデータを読み取ります。  数値データを返します。
%
%  GUPPLANLIMITTIME = IMPORTFILE1(FILE, DATALINES) はテキスト ファイル FILENAME
%  の指定された行区間のデータを読み取ります。DATALINES
%  を正の整数スカラーとして指定するか、行区間が不連続の場合は正の整数スカラーからなる N 行 2 列の配列として指定します。
%
%  例:
%  Gupplanlimittime = importfile1("C:\Users\PowerSystemLab\Desktop\01_研究資料\05_実行ファイル\program\全体実行\運用\G_up_plan_limit_time.csv", [1, Inf]);
%
%  READTABLE も参照してください。
%
% MATLAB からの自動生成日: 2022/10/28 13:36:49

%% 入力の取り扱い

% dataLines が指定されていない場合、既定値を定義します
if nargin < 2
    dataLines = [1, Inf];
end

%% インポート オプションの設定およびデータのインポート
opts = delimitedTextImportOptions("NumVariables", 30);

% 範囲と区切り記号の指定
opts.DataLines = dataLines;
opts.Delimiter = ",";

% 列名と型の指定
opts.VariableNames = ["VarName1", "VarName2", "VarName3", "VarName4", "VarName5", "VarName6", "VarName7", "VarName8", "VarName9", "VarName10", "VarName11", "VarName12", "VarName13", "VarName14", "VarName15", "VarName16", "VarName17", "VarName18", "VarName19", "VarName20", "VarName21", "VarName22", "VarName23", "VarName24", "VarName25", "VarName26", "VarName27", "VarName28", "VarName29", "VarName30"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];

% ファイル レベルのプロパティを指定
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% データのインポート
Gupplanlimittime = readtable(filename, opts);

%% 出力型への変換
Gupplanlimittime = table2array(Gupplanlimittime);
end