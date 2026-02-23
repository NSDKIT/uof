%% 需要作成
disp('シミュレーション実行のための需要作成')
if year == 2018
    build_demand_data_2018         %需要曲線の選択，短周期変動の外挿 origin_load1算出
else
    load(fullfile(ROOT_DIR, \'lfclfc.mat\'), \'lfc\');
if lfc >= 100
    disp(\'    -> 非AGCモードのため build_demand_data_2019 を使用します。\');
    build_demand_data_2019
else
    disp(\'    -> AGCモードのため build_demand_data_2019_agc を使用します。\');
    build_demand_data_2019_agc
end
%     build_demand_data_2019_agc
end