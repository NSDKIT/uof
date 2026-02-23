%% 需要作成
disp('シミュレーション実行のための需要作成')
if year == 2018
    Load_origin2018         %需要曲線の選択，短周期変動の外挿 origin_load1算出
else
    load(fullfile(fileparts(mfilename(\'fullpath\')), \'..\', \'lfclfc.mat\'), \'lfc\');
if lfc >= 100
    disp(\'    -> 非AGCモードのため Load_origin2019 を使用します。\');
    Load_origin2019
else
    disp(\'    -> AGCモードのため Load_origin2019_for_agc を使用します。\');
    Load_origin2019_for_agc
end
%     Load_origin2019_for_agc
end