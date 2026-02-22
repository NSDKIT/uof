%% PV_compare.m
% # 役割
% 指定した年・月のPV「予測出力」と「実績出力」を比較するグラフを
% 日ごとに並べて描画します。
% 1ヶ月分の予測と実績の傾向を視覚的に確認するために使用します。
%
% # 実行方法
%
% ```matlab
% PV_compare(year, month, PV_bai)
% % (例: PV_compare(2018, 6, 1.5))
% ```
%
% # パラメータ
%
% - `year`: 対象年 (例: 2018)
% - `month`: 対象月 (例: 6)
% - `PV_bai`: PV導入量の倍率
%
% # 前提条件
%
% - `PV_forecast_error_PVup_make.m` の実行が完了しており、
%   `予測PV出力誤差_YYYY` フォルダ内に日別誤差ファイルが存在すること。
%
% # 入力
%
% - `data_YYYY.mat`, `PV_forecast_YYYY.mat`, `PV_YYYY.mat`, `Load_YYYY.mat`
% - `予測PV出力誤差_YYYY` フォルダ内の `ERRORyyyymmdd.mat` ファイル群
%
% # 出力
%
% - 指定した月の実績(赤)と予測(黒)を比較するサブプロット群を持つFigure。
%
% # 内部処理
%
% - `chose_data.m` を使用して日付のインデックスを取得します。
% - ループ処理で1日から最終日まで、日ごとのグラフをサブプロットに描画します。

function PV_compare(year,month,PV_bai)
%% 予測PV出力とPV出力の比較
p = pwd;
cd C:\Users\PowerSystemLab\Desktop\01_研究資料\05_実行ファイル\予測PV出力誤差
close all
load(['data_',num2str(year),'.mat'])
a = find(data(:,2)==month);       % 月毎に行番号取得
load(['PV_forecast_',num2str(year),'.mat'])
% load(['Radiation_fcst_',num2str(year),'.mat'])
PV_f = data_all(a,:)*PV_bai;
load(['PV_',num2str(year),'.mat'])
PV_o = data_all(a,:)*PV_bai;

if month < 4
    year1 = year + 1;
else
    year1 = year;
end
if month == 2
    if year1 == 2019
        L_D = 28;
    elseif year1== 2020
        L_D = 29;
    end
elseif month == 4 || month == 6 || month == 9 || month == 11
    L_D = 30;
else
    L_D = 31;
end

load(['Load_',num2str(year),'.mat'])
chose_data(year,month,1)
global a_day
d1 = a_day;
chose_data(year,month,L_D)
global a_day
d2 = a_day;
L_f = data_all(d1:d2,:);
global aa
aa=[];
for day =1:L_D
    load(['ERROR',num2str(year1),num2str(month),num2str(day),'.mat'])
    e = L_f(day,:).*ERROR(1:48)'*PV_bai/100;
    figure(2)
    subplot(5,7,day)
    hold on
    plot(PV_f(day,:),'k')
    plot(PV_o(day,:),'r')
%     plot(PV_f(day,1:48)-e,'b')
    title([num2str(day),'日'])
    ylim([0 1000])
    sec_time_30min
%     legend({[num2str(max(PV_f(day,:)))],[num2str(max(PV_o(day,:)))]})
aa = [aa;max(PV_f(day,:)) max(PV_o(day,:))];
end
cd (p)
end
    