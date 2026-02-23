function day1 = get_PV300_1sec(filename, dataLines)
%IMPORTFILE1 繝�繧ｭ繧ｹ繝� 繝輔ぃ繧､繝ｫ縺九ｉ繝�繝ｼ繧ｿ繧偵う繝ｳ繝昴�ｼ繝�
%  DAY1 = IMPORTFILE1(FILENAME) 縺ｯ譌｢螳壹�ｮ驕ｸ謚槭↓髢｢縺励※繝�繧ｭ繧ｹ繝� 繝輔ぃ繧､繝ｫ FILENAME
%  縺九ｉ繝�繝ｼ繧ｿ繧定ｪｭ縺ｿ蜿悶ｊ縺ｾ縺吶��  謨ｰ蛟､繝�繝ｼ繧ｿ繧定ｿ斐＠縺ｾ縺吶��
%
%  DAY1 = IMPORTFILE1(FILE, DATALINES) 縺ｯ繝�繧ｭ繧ｹ繝� 繝輔ぃ繧､繝ｫ FILENAME
%  縺ｮ謖�螳壹＆繧後◆陦悟玄髢薙�ｮ繝�繝ｼ繧ｿ繧定ｪｭ縺ｿ蜿悶ｊ縺ｾ縺吶��DATALINES
%  繧呈ｭ｣縺ｮ謨ｴ謨ｰ繧ｹ繧ｫ繝ｩ繝ｼ縺ｨ縺励※謖�螳壹☆繧九°縲∬｡悟玄髢薙′荳埼�｣邯壹�ｮ蝣ｴ蜷医�ｯ豁｣縺ｮ謨ｴ謨ｰ繧ｹ繧ｫ繝ｩ繝ｼ縺九ｉ縺ｪ繧� N 陦� 2 蛻励�ｮ驟榊�励→縺励※謖�螳壹＠縺ｾ縺吶��
%
%  萓�:
%  day1 = importfile1("C:\Users\PowerSystemLab\Desktop\01_遐皮ｩｶ雉�譁兔05_螳溯｡後ヵ繧｡繧､繝ｫ\program\蜈ｨ菴灘ｮ溯｡圭PV螳溷�ｺ蜉帑ｽ懈�申PV300\1遘貞�､\area1\2018_4\day1.csv", [10, Inf]);
%
%  READTABLE 繧ょ盾辣ｧ縺励※縺上□縺輔＞縲�
%
% MATLAB 縺九ｉ縺ｮ閾ｪ蜍慕函謌先律: 2022/08/14 13:33:10

%% 蜈･蜉帙�ｮ蜿悶ｊ謇ｱ縺�

% dataLines 縺梧欠螳壹＆繧後※縺�縺ｪ縺�蝣ｴ蜷医�∵里螳壼�､繧貞ｮ夂ｾｩ縺励∪縺�
if nargin < 2
    dataLines = [10, Inf];
end

%% 繧､繝ｳ繝昴�ｼ繝� 繧ｪ繝励す繝ｧ繝ｳ縺ｮ險ｭ螳壹♀繧医�ｳ繝�繝ｼ繧ｿ縺ｮ繧､繝ｳ繝昴�ｼ繝�
opts = delimitedTextImportOptions("NumVariables", 8);

% 遽�蝗ｲ縺ｨ蛹ｺ蛻�繧願ｨ伜捷縺ｮ謖�螳�
opts.DataLines = dataLines;
opts.Delimiter = ",";

% 蛻怜錐縺ｨ蝙九�ｮ謖�螳�
opts.VariableNames = ["Var1", "INST", "Var3", "Var4", "Var5", "Var6", "Var7", "Var8"];
opts.SelectedVariableNames = "INST";
opts.VariableTypes = ["string", "double", "string", "string", "string", "string", "string", "string"];

% 繝輔ぃ繧､繝ｫ 繝ｬ繝吶Ν縺ｮ繝励Ο繝代ユ繧｣繧呈欠螳�
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% 螟画焚繝励Ο繝代ユ繧｣繧呈欠螳�
opts = setvaropts(opts, ["Var1", "Var3", "Var4", "Var5", "Var6", "Var7", "Var8"], "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["Var1", "Var3", "Var4", "Var5", "Var6", "Var7", "Var8"], "EmptyFieldRule", "auto");

% 繝�繝ｼ繧ｿ縺ｮ繧､繝ｳ繝昴�ｼ繝�
day1 = readtable(filename, opts);

%% 蜃ｺ蜉帛梛縺ｸ縺ｮ螟画鋤
day1 = table2array(day1);
end