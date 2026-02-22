%% MAE.m
% # 役割
% PVの予測出力(`PV_F`)と実績出力(`PV_O`)を比較し、月ごとの
% 平均絶対誤差率(MAE: Mean Absolute Error)を計算・描画します。
%
% **注意:** このスクリプトは特定の関数として定義されておらず、
% 実行するとワークスペース上の変数を使って直接計算と描画を行います。
%
% # 実行方法
%
% ```matlab
% % ワークスペースに必要なデータを読み込んでから実行
% MAE
% ```
%
% # 前提条件
%
% ワークスペースに以下の変数が読み込まれていること。
%   - `PV_forecast_2018.mat` (予測値)
%   - `PV_2018.mat` (実績値)
%   - `data_2018.mat` (日付データ)
%
% # 入力(ワークスペースから)
%
% - `PV_F`: PV予測出力データ
% - `PV_O`: PV実績出力データ
% - `data`: 日付データ
%
% # 出力
%
% - 月別の平均絶対誤差率(RMSE)をプロットしたグラフ。
%   (**注:** 変数名は`mae`ですが、計算式はRMSE(二乗平均平方根誤差)です)
%
% # 注意
%
% - スクリプト内でファイル名(`'PV_2018.mat'`など)が固定されているため、他の年で実行する場合は、ファイル名を修正する必要があります。
% - 計算対象時間が 6:00 から 18:00 (13~37番目のデータ)に固定されています。

load('PV_forecast_2018.mat')
PV_F = data_all;
load('PV_2018.mat')
PV_O = data_all;
M = [];
%% 対象 6:00~18:00
load('data_2018.mat')
for month = [10:12 1:9]
    %% month 月
    a=find(data(:,2)==month);
    PV_o1 = PV_O(a,:);
    PV_f1 = PV_F(a,:);
    %% 合計
    d = length(a);
    %% PV出力実測値
    PV_o = [PV_o1];
    pv_o = PV_o(:,13:37);
    %% 予測PV出力値
    PV_f = [PV_f1];
    pv_f = PV_f(:,13:37);
    m = [];
    for num = 1:d
        Pv_o=pv_o(num,:);
        Pv_f=pv_f(num,:);
        mae = sqrt(sum((Pv_o-Pv_f).^2)/25)/mean(Pv_o)*100;
        m = [m;mae];
    end
    M = [M;mean(m)];
end
figure,plot(M,'bo-')
xlim([1 12])
xticks([1:12])
xticklabels([10:12 1:9])
grid on
ylim([0 120])