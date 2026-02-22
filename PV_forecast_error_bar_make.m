%% PV_forecast_error_bar_make.m
% # 役割
% 指定した年・月のPV予測誤差を、日ごとの棒グラフで可視化します。
% `PV_forecast_error_PVup_make`で生成された日別の誤差ファイルを使用します。
%
% # 実行方法
%
% ```matlab
% PV_forecast_error_bar_make(year, month, num)
% % (例: PV_forecast_error_bar_make(2018, 6, 1))
% ```
%
% # パラメータ
%
% - `year`: 対象年 (例: 2018)
% - `month`: 対象月 (例: 6)
% - `num`: 棒グラフで表示する誤差データの列番号 (PV導入量に対応)
%
% # 前提条件
%
% - `PV_forecast_error_PVup_make.m` の実行が完了しており、
%   `予測PV出力誤差_YYYY` フォルダ内に日別誤差ファイルが存在すること。
%
% # 入力
%
% - `予測PV出力誤差_YYYY` フォルダ内の `ERRORyyyymmdd.mat` ファイル群
%
% # 出力
%
% - 指定した月の誤差状況を日別に示すサブプロット群を持つFigure。
% - 月平均の誤差を示す棒グラフのFigure。

function PV_forecast_error_bar_make(year,month,num)
% close all
p = pwd;
cd('C:\Users\PowerSystemLab\Desktop\01_研究資料\05_実行ファイル\予測PV出力誤差')
cd(['予測PV出力誤差_',num2str(year)])
if month < 4
    year = year + 1;
end
if month == 2
    if year == 2019
        L_D = 28;
    elseif year== 2020
        L_D = 29;
    end
elseif month == 4 || month == 6 || month == 9 || month == 11
    L_D = 30;
else
    L_D = 31;
end
ERROR_M = [];
for day =1:L_D
    load(['ERROR',num2str(year),num2str(month),num2str(day),'.mat'])
    figure(10)
    hold on
    subplot(5,7,day)
    bar(ERROR(:,num))
    ylim([0 12])
    ERROR_M = [ERROR_M ERROR(:,1)];
end
ERROR_M = mean(ERROR_M');
figure,bar(ERROR_M)
sec_time_30min
cd(p)
end
    