%% 確認事項
% シミュレーションをしたい年月日の「Z__C・・・」ファイルが16個(初期時間：8つ × 予報時間：2つ = 16)あるか確認
% 年月日・位置の選択・変更
% IK = get_ido_keido('ido_keido.xlsx');
load('ido_keido.mat')
disp('日射量予測算出')
% load('xyz.mat')
cd(WGRIB2_DIR)  % wgrib2.exe が置かれているフォルダに移動
%% 開始
%% コマンドの作成('wgrib2.exe -match "DSWRF:surface:" Z__C_RJTD_yyyymmdd060000_MSM_GPV_Rjp_Lsurf_FH16-33_grib2.bin -lon 135.13 36.04 -last grib.csv -nl_out grib.csv')
%% 自動
if Month<10
    if Month < 4
        file_a = ['wgrib2.exe -match "DSWRF:surface:" ',num2str(Year+1),'-0',num2str(month)];
        file_e = ['grib0',num2str(Month)];
        filename_a=['grib',num2str(Year),'0',num2str(Month)];
    else
        file_a = ['wgrib2.exe -match "DSWRF:surface:" ',num2str(Year),'-0',num2str(Month)];
        file_e = ['grib0',num2str(Month)];
        filename_a=['grib',num2str(Year),'0',num2str(Month)];
    end
else
    file_a = ['wgrib2.exe -match "DSWRF:surface:" ',num2str(Year),'-',num2str(Month),];
    file_e = ['grib',num2str(Month)];
    filename_a=['grib',num2str(Year),num2str(Month)];
end

if Day<10
    file_b = [file_a,'-0',num2str(Day)];
    file_f = [file_e,'-0',num2str(Day)];
    file_ff = [file_e,'0',num2str(Day)];
else
    file_b = [file_a,'-',num2str(Day),];
    file_f = [file_e,'-',num2str(Day)];
    file_ff = [file_e,num2str(Day)];
end

file_c = 'wgrib2.exe -match "DSWRF:surface:" 00-15.bin';
file_z = 'wgrib2.exe -match "DSWRF:surface:" 16-33.bin';
file_l = 'wgrib2.exe -match "DSWRF:surface:" 34-39.bin';
% load('ido_keido.mat')
IDO=ido;KEIDO=keido;
irr_forecast=[];
for area = 1:17
    loc1 =['area',num2str(area)];
    location1 = [' -lon ',num2str(KEIDO(area)),' ',num2str(IDO(area))];
    %% 自動（grib~.csv）
    %% 位置1
    file_d1 = [file_c,location1,' -last '];
    file_x1 = [file_z,location1,' -last '];
    file_y1 = [file_l,location1,' -last '];
    %% コマンドの結合
    file_g = [file_ff,num2str(T1),'_00-15.csv'];
    file_h = [file_ff,num2str(T1),'_16-33.csv'];
    file_m = [file_ff,num2str(T1),'_34-39.csv'];
    file_i1 = [file_d1,loc1,'_',file_g,' -nl_out ',loc1,'_',file_g];
    file_j1 = [file_x1,loc1,'_',file_h,' -nl_out ',loc1,'_',file_h];
    file_o1 = [file_y1,loc1,'_',file_m,' -nl_out ',loc1,'_',file_m];
    %% コマンド実行
    system(file_i1);
    system(file_j1);
    system(file_o1);
	%% 日射量予測データの算出
    if Month<10
        file_k1 = [loc1,'_grib0',num2str(Month)];
    else
        file_k1 = [loc1,'_grib',num2str(Month)];
    end

    if Day<10
            filename_b1 = [file_k1,'0',num2str(Day),num2str(T1),'_00-15.csv'];
            filename_c1 = [file_k1,'0',num2str(Day),num2str(T1),'_16-33.csv'];
            filename_d1 = [file_k1,'0',num2str(Day),num2str(T1),'_34-39.csv'];
    else
            filename_b1 = [file_k1,num2str(Day),num2str(T1),'_00-15.csv'];
            filename_c1 = [file_k1,num2str(Day),num2str(T1),'_16-33.csv'];
            filename_d1 = [file_k1,num2str(Day),num2str(T1),'_34-39.csv'];
    end
    DATA_b1 = grib2(filename_b1);
    DATA_c1 = grib2(filename_c1);
    DATA_d1 = grib2(filename_d1);
    DATA_b1 = DATA_b1';
    DATA_c1 = DATA_c1';
    DATA_d1 = DATA_d1';
    data_all1 = [DATA_b1 DATA_c1 DATA_d1];
    delete(filename_b1);delete(filename_c1);delete(filename_d1)
    %% 時刻作成・日射量予測データとの結合
    if T1 == '00'
        data_all1 = data_all1(15:39);
    elseif T1 == '06'
        data_all1 = data_all1(10:34); %位置1の初期時刻 T1から予測データ
    end
    irr_forecast=[irr_forecast,data_all1'];
end
data = irr_forecast;

% if Day+1<10
%     NAME = [filename_a,'0',num2str(Day+1),'_use.csv'];
% else
%     NAME = [filename_a,num2str(Day+1),'_use.csv'];
% end
% %% 全データの移動
% mkdir GRIBPV
% % copyfile *csv GRIBPV
% copyfile(file_c(end-19:end),'GRIBPV')
% copyfile(file_z(end-19:end),'GRIBPV')
% copyfile(file_l(end-19:end),'GRIBPV')
% cd GRIBPV
% %% GRIBPVへのデータの保存
% csvwrite(NAME,data) %ave
% save PVdata.mat data %ave
% cd ..
save PVdata.mat data %ave
% %% ファイル名の変更
% tmp=dir("*PV");
% filename = {tmp.name};
% 
% if Month<10
%     newfilename_a = ['0',num2str(Month)];
% else
%     newfilename_a = [num2str(Month)];
% end
% 
% if Day<10
%     newfilename_b=[newfilename_a,'0',num2str(Day)];
% else
%     newfilename_b=[newfilename_a,num2str(Day)];
% end
% if Month < 4
%     newfilename = cellfun(@(x) [x(1:4),'_', num2str(Year+1),newfilename_b,'_', x(5:6)], filename, 'UniformOutput', false);
% else
%     newfilename = cellfun(@(x) [x(1:4),'_', num2str(Year),newfilename_b,'_', x(5:6)], filename, 'UniformOutput', false);
% end
% % newfilename = cellfun(@(x) [x(1:4),'_', num2str(Year),'0',num2str(Month),'0',num2str(Day),'_', x(5:6)], filename, 'UniformOutput', false);
% for k=1:length(filename)
%     movefile(filename{k}, newfilename{k});
% end
%% ファイルの移動
% copyfile PVdata.mat ../../05_実行ファイル  % 旧パス（不使用）
cd(WGRIB2_DIR)  % wgrib2.exe が置かれているフォルダに移動
% movefile *PV ../../03_日射量予測
delete(file_c(end-8:end))
delete(file_z(end-8:end))
delete(file_l(end-8:end))
cd(ROOT_DIR)
clearvars -except Year Month Day MSM_max PV_base PR irr_forecast