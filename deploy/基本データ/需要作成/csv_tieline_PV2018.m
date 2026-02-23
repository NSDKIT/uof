function data = csv_tieline1(workbookFile, sheetName, dataLines)
%IMPORTFILE スプレッドシートからデータをインポート
%  UNTITLED = IMPORTFILE(FILE) は、FILE という名前の Microsoft Excel スプレッドシート
%  ファイルの最初のワークシートからデータを読み取ります。  データを table として返します。
%
%  UNTITLED = IMPORTFILE(FILE, SHEET) は、指定されたワークシートから読み取ります。
%
%  UNTITLED = IMPORTFILE(FILE, SHEET, DATALINES)
%  は、指定されたワークシートから指定された行区間を読み取ります。DATALINES
%  を正の整数スカラーとして指定するか、行区間が不連続の場合は正の整数スカラーからなる N 行 2 列の配列として指定します。
%
%  例:
%  Untitled = importfile("C:\Users\powersystemsetsubi\Downloads\北陸電力_共同研究データ_LFC必要データ\2018年度\連系線201810-11.xlsx", "Sheet1", [2, 535682]);
%
%  READTABLE も参照してください。
%
% MATLAB からの自動生成日: 2020/07/31 14:25:46

%% 入力の取り扱い

% シートが指定されていない場合、最初のシートを読み取ります
if nargin == 1 || isempty(sheetName)
    sheetName = 1;
end

% 行の始点と終点が指定されていない場合、既定値を定義します
if nargin <= 2
    dataLines = [2, 535682];
end

%% インポート オプションの設定
opts = spreadsheetImportOptions("NumVariables", 7);

% シートと範囲の指定
opts.Sheet = sheetName;
opts.DataRange = "A" + dataLines(1, 1) + ":G" + dataLines(1, 2);

% 列名と型の指定
opts.VariableNames = ["year", "time", "date", "Var4", "year1", "time1", "date1"];
opts.SelectedVariableNames = ["year", "time", "date", "year1", "time1", "date1"];
opts.VariableTypes = ["categorical", "string", "double", "char", "categorical", "string", "double"];
opts = setvaropts(opts, [2, 4, 6], "WhitespaceRule", "preserve");
opts = setvaropts(opts, [1, 2, 4, 5, 6], "EmptyFieldRule", "auto");

% データのインポート
data = readtable(workbookFile, opts, "UseExcel", false);

for idx = 2:size(dataLines, 1)
    opts.DataRange = "A" + dataLines(idx, 1) + ":G" + dataLines(idx, 2);
    tb = readtable(workbookFile, opts, "UseExcel", false);
    data = [data; tb]; %#ok<AGROW>
end

end