function weather20186 = get_weather(filename, dataLines)
%IMPORTFILE1 テキスト ファイルからデータをインポート
%  WEATHER20186 = IMPORTFILE1(FILENAME) は既定の選択に関してテキスト ファイル FILENAME
%  からデータを読み取ります。  データを cell 配列として返します。
%
%  WEATHER20186 = IMPORTFILE1(FILE, DATALINES) はテキスト ファイル FILENAME
%  の指定された行区間のデータを読み取ります。DATALINES
%  を正の整数スカラーとして指定するか、行区間が不連続の場合は正の整数スカラーからなる N 行 2 列の配列として指定します。
%
%  例:
%  weather20186 = importfile1("C:\Users\PowerSystemLab\Desktop\01_研究資料\05_実行ファイル\program\一軸追尾\weather_20186.csv", [1, Inf]);
%
%  READTABLE も参照してください。
%
% MATLAB からの自動生成日: 2022/07/13 21:31:04

%% 入力の取り扱い

% dataLines が指定されていない場合、既定値を定義します
if nargin < 2
    dataLines = [1, Inf];
end

%% インポート オプションの設定およびデータのインポート
opts = delimitedTextImportOptions("NumVariables", 7);

% 範囲と区切り記号の指定
opts.DataLines = dataLines;
opts.Delimiter = ",";

% 列名と型の指定
opts.VariableNames = ["VarName1", "VarName2", "VarName3", "VarName4", "VarName5", "VarName6", "VarName7"];
opts.VariableTypes = ["char", "char", "double", "double", "char", "double", "double"];

% ファイル レベルのプロパティを指定
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% 変数プロパティを指定
opts = setvaropts(opts, ["VarName1", "VarName2", "VarName5"], "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["VarName1", "VarName2", "VarName5"], "EmptyFieldRule", "auto");

% データのインポート
weather20186 = readtable(filename, opts);

%% 出力型への変換
weather20186 = table2cell(weather20186);
numIdx = cellfun(@(x) ~isnan(str2double(x)), weather20186);
weather20186(numIdx) = cellfun(@(x) {str2double(x)}, weather20186(numIdx));
end