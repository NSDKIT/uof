function Untitled = get_ihan(workbookFile, sheetName, dataLines)
%IMPORTFILE1 スプレッドシートからデータをインポート
%  UNTITLED = IMPORTFILE1(FILE) は、FILE という名前の Microsoft Excel スプレッドシート
%  ファイルの最初のワークシートからデータを読み取ります。  数値データを返します。
%
%  UNTITLED = IMPORTFILE1(FILE, SHEET) は、指定されたワークシートから読み取ります。
%
%  UNTITLED = IMPORTFILE1(FILE, SHEET, DATALINES)
%  は、指定されたワークシートから指定された行区間を読み取ります。DATALINES
%  を正の整数スカラーとして指定するか、行区間が不連続の場合は正の整数スカラーからなる N 行 2 列の配列として指定します。
%
%  例:
%  Untitled = importfile1("C:\Users\PowerSystemLab\Desktop\01_研究資料\05_実行ファイル\運転停止時間違反.xlsx", "運転停止時間違反", [1, 12]);
%
%  READTABLE も参照してください。
%
% MATLAB からの自動生成日: 2022/06/07 12:48:08

%% 入力の取り扱い

% シートが指定されていない場合、最初のシートを読み取ります
if nargin == 1 || isempty(sheetName)
    sheetName = 1;
end

% 行の始点と終点が指定されていない場合、既定値を定義します
if nargin <= 2
    dataLines = [1, 12];
end

%% インポート オプションの設定およびデータのインポート
opts = spreadsheetImportOptions("NumVariables", 51);

% シートと範囲の指定
opts.Sheet = sheetName;
opts.DataRange = "A" + dataLines(1, 1) + ":AY" + dataLines(1, 2);

% 列名と型の指定
opts.VariableNames = ["VarName1", "VarName2", "VarName3", "VarName4", "VarName5", "VarName6", "VarName7", "VarName8", "VarName9", "VarName10", "VarName11", "VarName12", "VarName13", "VarName14", "VarName15", "VarName16", "VarName17", "VarName18", "VarName19", "VarName20", "VarName21", "VarName22", "VarName23", "VarName24", "VarName25", "VarName26", "VarName27", "VarName28", "VarName29", "VarName30", "VarName31", "VarName32", "VarName33", "VarName34", "VarName35", "VarName36", "VarName37", "VarName38", "VarName39", "VarName40", "VarName41", "VarName42", "VarName43", "VarName44", "VarName45", "VarName46", "VarName47", "VarName48", "VarName49", "VarName50", "VarName51"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];

% データのインポート
Untitled = readtable(workbookFile, opts, "UseExcel", false);

for idx = 2:size(dataLines, 1)
    opts.DataRange = "A" + dataLines(idx, 1) + ":AY" + dataLines(idx, 2);
    tb = readtable(workbookFile, opts, "UseExcel", false);
    Untitled = [Untitled; tb]; %#ok<AGROW>
end

%% 出力型への変換
Untitled = table2array(Untitled);
end