function idokeido = get_ido_keido(workbookFile, sheetName, dataLines)
%IMPORTFILE1 スプレッドシートからデータをインポート
%  IDOKEIDO = IMPORTFILE1(FILE) は、FILE という名前の Microsoft Excel スプレッドシート
%  ファイルの最初のワークシートからデータを読み取ります。  数値データを返します。
%
%  IDOKEIDO = IMPORTFILE1(FILE, SHEET) は、指定されたワークシートから読み取ります。
%
%  IDOKEIDO = IMPORTFILE1(FILE, SHEET, DATALINES)
%  は、指定されたワークシートから指定された行区間を読み取ります。DATALINES
%  を正の整数スカラーとして指定するか、行区間が不連続の場合は正の整数スカラーからなる N 行 2 列の配列として指定します。
%
%  例:
%  idokeido = importfile1("C:\Users\PowerSystemLab\Desktop\01_研究資料\05_実行ファイル\program\一軸追尾\ido_keido.xlsx", "Sheet1", [2, 20]);
%
%  READTABLE も参照してください。
%
% MATLAB からの自動生成日: 2022/07/13 12:55:38

%% 入力の取り扱い

% シートが指定されていない場合、最初のシートを読み取ります
if nargin == 1 || isempty(sheetName)
    sheetName = 1;
end

% 行の始点と終点が指定されていない場合、既定値を定義します
if nargin <= 2
    dataLines = [2, 20];
end

%% インポート オプションの設定およびデータのインポート
opts = spreadsheetImportOptions("NumVariables", 2);

% シートと範囲の指定
opts.Sheet = sheetName;
opts.DataRange = "B" + dataLines(1, 1) + ":C" + dataLines(1, 2);

% 列名と型の指定
opts.VariableNames = ["VarName2", "VarName3"];
opts.VariableTypes = ["double", "double"];

% データのインポート
idokeido = readtable(workbookFile, opts, "UseExcel", false);

for idx = 2:size(dataLines, 1)
    opts.DataRange = "B" + dataLines(idx, 1) + ":C" + dataLines(idx, 2);
    tb = readtable(workbookFile, opts, "UseExcel", false);
    idokeido = [idokeido; tb]; %#ok<AGROW>
end

%% 出力型への変換
idokeido = table2array(idokeido);
end