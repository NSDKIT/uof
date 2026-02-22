%% chose_data.m
% # 役割
% 指定された年・月・日から、通年のデータ(`data_YYYY.mat`)における
% 行番号(その年の1月1日から数えて何日目か)を検索し、
% ベースワークスペースに変数 `'a_day'`として返します。
%
% 他のスクリプト(`PV_compare.m`, `PV_forecast_error_PVup_make.m`など)から
% 補助的に呼び出されるユーティリティ関数です。
%
% # 実行方法
%
% ```matlab
% chose_data(year, month, day)
% % (例: chose_data(2018, 6, 15))
% ```
%
% # パラメータ
%
% - `year`: 対象年 (例: 2018)
% - `month`: 対象月 (例: 6)
% - `day`: 対象日 (例: 15)
%
% # 入力
%
% - `data_YYYY.mat`: 日付データ(各行が[年, 月, 日]の形式)
%
% # 出力
%
% - ベースワークスペースに `'a_day'` という変数が作成されます。
%   (値は指定された日付の行番号)

function chose_data(year,month,day)
p = pwd;
cd C:\Users\PowerSystemLab\Desktop\01_研究資料\05_実行ファイル\予測PV出力誤差
load(['data_',num2str(year),'.mat'])
if month < 4
year = year+1;
else
year = year;
end
a = data((find(data(:,2)==month)),:);
b = a((find(a(:,3)==day)),:);
a_day = b(1);
assignin('base',['a_day'],a_day)
cd(p)
end