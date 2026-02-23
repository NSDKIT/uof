function idokeido = import_lat_lon(workbookFile, sheetName, dataLines)
%IMPORTFILE1 繧ｹ繝励Ξ繝�繝峨す繝ｼ繝医°繧峨ョ繝ｼ繧ｿ繧偵う繝ｳ繝昴�ｼ繝�
%  IDOKEIDO = IMPORTFILE1(FILE) 縺ｯ縲：ILE 縺ｨ縺�縺�蜷榊燕縺ｮ Microsoft Excel 繧ｹ繝励Ξ繝�繝峨す繝ｼ繝�
%  繝輔ぃ繧､繝ｫ縺ｮ譛�蛻昴�ｮ繝ｯ繝ｼ繧ｯ繧ｷ繝ｼ繝医°繧峨ョ繝ｼ繧ｿ繧定ｪｭ縺ｿ蜿悶ｊ縺ｾ縺吶��  謨ｰ蛟､繝�繝ｼ繧ｿ繧定ｿ斐＠縺ｾ縺吶��
%
%  IDOKEIDO = IMPORTFILE1(FILE, SHEET) 縺ｯ縲∵欠螳壹＆繧後◆繝ｯ繝ｼ繧ｯ繧ｷ繝ｼ繝医°繧芽ｪｭ縺ｿ蜿悶ｊ縺ｾ縺吶��
%
%  IDOKEIDO = IMPORTFILE1(FILE, SHEET, DATALINES)
%  縺ｯ縲∵欠螳壹＆繧後◆繝ｯ繝ｼ繧ｯ繧ｷ繝ｼ繝医°繧画欠螳壹＆繧後◆陦悟玄髢薙ｒ隱ｭ縺ｿ蜿悶ｊ縺ｾ縺吶��DATALINES
%  繧呈ｭ｣縺ｮ謨ｴ謨ｰ繧ｹ繧ｫ繝ｩ繝ｼ縺ｨ縺励※謖�螳壹☆繧九°縲∬｡悟玄髢薙′荳埼�｣邯壹�ｮ蝣ｴ蜷医�ｯ豁｣縺ｮ謨ｴ謨ｰ繧ｹ繧ｫ繝ｩ繝ｼ縺九ｉ縺ｪ繧� N 陦� 2 蛻励�ｮ驟榊�励→縺励※謖�螳壹＠縺ｾ縺吶��
%
%  萓�:
%  idokeido = importfile1("C:\Users\PowerSystemLab\Desktop\01_遐皮ｩｶ雉�譁兔05_螳溯｡後ヵ繧｡繧､繝ｫ\program\荳�霆ｸ霑ｽ蟆ｾ\ido_keido.xlsx", "Sheet1", [2, 20]);
%
%  READTABLE 繧ょ盾辣ｧ縺励※縺上□縺輔＞縲�
%
% MATLAB 縺九ｉ縺ｮ閾ｪ蜍慕函謌先律: 2022/07/13 12:55:38

%% 蜈･蜉帙�ｮ蜿悶ｊ謇ｱ縺�

% 繧ｷ繝ｼ繝医′謖�螳壹＆繧後※縺�縺ｪ縺�蝣ｴ蜷医�∵怙蛻昴�ｮ繧ｷ繝ｼ繝医ｒ隱ｭ縺ｿ蜿悶ｊ縺ｾ縺�
if nargin == 1 || isempty(sheetName)
    sheetName = 1;
end

% 陦後�ｮ蟋狗せ縺ｨ邨らせ縺梧欠螳壹＆繧後※縺�縺ｪ縺�蝣ｴ蜷医�∵里螳壼�､繧貞ｮ夂ｾｩ縺励∪縺�
if nargin <= 2
    dataLines = [2, 20];
end

%% 繧､繝ｳ繝昴�ｼ繝� 繧ｪ繝励す繝ｧ繝ｳ縺ｮ險ｭ螳壹♀繧医�ｳ繝�繝ｼ繧ｿ縺ｮ繧､繝ｳ繝昴�ｼ繝�
opts = spreadsheetImportOptions("NumVariables", 2);

% 繧ｷ繝ｼ繝医→遽�蝗ｲ縺ｮ謖�螳�
opts.Sheet = sheetName;
opts.DataRange = "B" + dataLines(1, 1) + ":C" + dataLines(1, 2);

% 蛻怜錐縺ｨ蝙九�ｮ謖�螳�
opts.VariableNames = ["VarName2", "VarName3"];
opts.VariableTypes = ["double", "double"];

% 繝�繝ｼ繧ｿ縺ｮ繧､繝ｳ繝昴�ｼ繝�
idokeido = readtable(workbookFile, opts, "UseExcel", false);

for idx = 2:size(dataLines, 1)
    opts.DataRange = "B" + dataLines(idx, 1) + ":C" + dataLines(idx, 2);
    tb = readtable(workbookFile, opts, "UseExcel", false);
    idokeido = [idokeido; tb]; %#ok<AGROW>
end

%% 蜃ｺ蜉帛梛縺ｸ縺ｮ螟画鋤
idokeido = table2array(idokeido);
end