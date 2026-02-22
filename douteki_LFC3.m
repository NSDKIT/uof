%% douteki_LFC3.m
% # 役割
% PV予測出力と負荷予測から、動的に必要なLFC(負荷周波数制御)容量を計算します。
% 計算結果は、シミュレーションなどで使用するために`.mat`ファイルとして保存されます。
%
% # 実行方法
%
% ```matlab
% douteki_LFC3(year, month, day, PV_bai)
% % (例: douteki_LFC3(2018, 6, 15, 1.5))
% ```
%
% # パラメータ
%
% - `year`: 対象年
% - `month`: 対象月
% - `day`: 対象日
% - `PV_bai`: PV導入量の倍率
%
% # 入力
%
% - `douteki_lfc_ab.mat`: LFC容量を計算するための係数(傾きaと切片b)
% - `new_ave_PV.mat`: 平均的なPV出力カーブ
% - `new_ave_load.mat`: 平均的な負荷カーブ
%
% # 出力
%
% - `LFC_amount_yyyymmdd.mat`: 計算された30分ごとのLFC必要量
%   (**注:** `'動的LFC容量決定手法'` フォルダに保存される)
%
% # 注意
%
% - スクリプト内で `'cd ..'` や `'cd (フォルダ名)'` が使われており、
%   実行時のカレントディレクトリに依存する部分があります。

function douteki_LFC3(year,month,day,PV_bai)
%% B部門大会からわかる傾きと切片（横軸：最大PV出力，縦軸：必要LFC容量）
% a = 0.0313;
% b = -19.7891;
load('douteki_lfc_ab.mat')
% load(['PV_forecast_',num2str(year),'.mat'])
cd ..
load('new_ave_PV')
load('new_ave_load.mat')
% chose_data(year,month,day)
% global a_day
% PV_f = data_all(a_day,:);
PV_f = new_ave_PV;
L_f = new_ave_load;
L = [];
for t = 1:48
    if ab(t,1)==0
        L = [L;0];
    else
        L = [L;ab(t,1)*PV_f(t)/L_f(t)*100*PV_bai+ab(t,2)]; 
    end
end
L = [L;0;0];
lfc_2 = (L<2)*2;
l_10 = (L>=2).*(L)>=10;
l = (lfc_2+(L>=2).*(L))<10;
lfc_10 = l_10*10;
% figure,plot((lfc_2+((L)>=2).*(L)).*l+lfc_10)
LFC_amount = (lfc_2+((L)>=2).*(L)).*l+lfc_10;
% sec_time_30min
cd('動的LFC容量決定手法')
filename = ['LFC_amount_',num2str(year),num2str(month),num2str(day),'.mat'];
save(filename,'LFC_amount')
cd ..
end