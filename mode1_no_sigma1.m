%% mode1_no_sigma1.m
% # 役割
% `SIGMA_get1.m` から呼び出される補助スクリプト。
% `mode1_no_sigma.m` と同様に、予測PV出力の大きさに基づいて誤差を帯域分割し、
% それぞれの帯域でσ(標準偏差)を計算します。
% こちらは分割する帯域がより細かく、計算方法も若干異なります。
%
% **注意:** このスクリプトは単体で実行するのではなく、`SIGMA_get1.m` (`mode1=1`)の
% ループ処理の中で使用されます。
%
% # 前提条件
%
% `SIGMA_get1.m` のワークスペース内に以下の変数が定義されていること。
%   - `year`, `i`, `PVC_bai`, `ERROR`, `PVC`
%
% # 入力(ワークスペースから)
%
% - `PV_forecast_YYYY.mat`: PV予測出力データ
% - `PVC.mat`: PVの設備容量データ
% - `ERROR`: 予測誤差データ
% - `i`: 時間断面インデックス
% - `PVC_bai`: PV導入倍率
%
% # 出力(グローバル変数経由)
%
% - `s1`, `s2`, `s3`, ...: 各帯域で計算されたσの値 (`KAKURITUBU_BUNNPU1.m` 内の `global pd` を通じて取得)
% - `e1`, `e2`, `e3`, ...: 各帯域に分割された誤差データ。(これらは`SIGMA_get1.m`によって`.mat`ファイルに保存される)

load(['PV_forecast_',num2str(year),'.mat']);load('PVC.mat')
%% 時間断面での抽出(365日分)
data_all = data_all*PVC_bai;
data = data_all(:,i);global a_day
chose_data(2018,6,30);sp2=a_day;su1=a_day+1;
chose_data(2018,9,30);su2=a_day;au1=a_day+1;
chose_data(2018,12,31);au2=a_day;wi1=a_day+1;wi2=365;
% ERROR1 = [ERROR(1:sp2,:)*PVC/820;ERROR(su1:su2,:)*PVC/840;ERROR(au1:au2,:)*PVC/930;ERROR(wi1:wi2,:)*PVC/960];
% data = [data(1:sp2)*PVC/820;data(su1:su2)*PVC/840;data(au1:au2)*PVC/930;data(wi1:wi2)*PVC/960];
E=ERROR(:,i)*PVC_bai;E(find(E==Inf))=0;E(find(E==nan))=0;
PV_kubun = PVC/5;
%% 予測PV出力が200以下
a200 = (data<PV_kubun);
E1=E.*a200;
e1=E1(find(a200==1));
e_l1 = length(e1);
%% 予測PV出力が400以下
a400_1 = (data<(PV_kubun*2));
a400_2 = (data>=PV_kubun);
a400 = a400_1.*a400_2;
E2=E.*a400;
e2=E2(find(a400==1));
e_l2 = length(e2);
%% 予測PV出力が600以下
a600_1 = (data<(PV_kubun*3));
a600_2 = (data>(PV_kubun*2));
a600 = a600_1.*a600_2;
E3=E.*a600;
e3=E3(find(a600==1));
e_l3 = length(e3);
%% 予測PV出力が800以下
a800_1 = (data<(PV_kubun*4));
a800_2 = (data>=(PV_kubun*3));
a800 = a800_1.*a800_2;
E4=E.*a800;
e4=E4(find(a800==1));
e_l4 = length(e4);
%% 予測PV出力が1000以下
a1000_1 = (data<(PV_kubun*5));
a1000_2 = (data>=(PV_kubun*4));
a1000 = a1000_1.*a1000_2;
E5=E.*a1000;
e5=E5(find(a1000==1));
e_l5 = length(e5);
%% 予測PV出力が1200以下
a1200_1 = (data<(PV_kubun*6));
a1200_2 = (data>=(PV_kubun*5));
a1200 = a1200_1.*a1200_2;
E6=E.*a1200;
e6=E6(find(a1200==1));
e_l6 = length(e6);
%% 予測PV出力が1400以下
a1400_1 = (data<(PV_kubun*7));
a1400_2 = (data>=(PV_kubun*6));
a1400 = a1400_1.*a1400_2;
E7=E.*a1400;
e7=E7(find(a1400==1));
e_l7 = length(e7);
%% 予測PV出力が1000以下
a1600_1 = (data<(PV_kubun*8));
a1600_2 = (data>(PV_kubun*7));
a1600 = a1600_1.*a1600_2;
E8=E.*a1600;
e8=E8(find(a1600==1));
e_l8 = length(e8);
a1800_1 = (data<(PV_kubun*9));
a1800_2 = (data>(PV_kubun*8));
a1800 = a1800_1.*a1800_2;
E9=E.*a1800;
e9=E9(find(a1800==1));
e_l9 = length(e9);
a2000_1 = (data<(PV_kubun*10));
a2000_2 = (data>(PV_kubun*9));
a2000 = a2000_1.*a2000_2;
E10=E.*a2000;
e10=E10(find(a2000==1));
e_l10 = length(e10);
%% 
l = [e_l1,e_l2,e_l3,e_l4,e_l5,e_l6,e_l7,e_l8,e_l9,e_l10];
%% σ算出
global s1 s2 s3 s4 s5 s6 s7 s8 s9 s10
load('time_label.mat')
close all
if isempty(e1) == 1
    mu = 0;
    sigma = 0;
    s1 = 0;
elseif size(e1) == 1
    mu = 0;
    sigma = 0;
    s1 = 0;
else
    KAKURITUBU_BUNNPU1(1,e1,'b',[-15:0.01:15],[],1)
    global pd
    mu=pd.mu;
    sigma=pd.sigma;
    s1 = max([abs(mu+sigma),abs(mu-sigma)]);
end
% o_sfig(2,[-15 15],[],[],[],[],[num2str(time_label(i,:))],'σ\σ-200以下')
%%
if isempty(e2) == 1
    mu = 0;
    sigma = 0;
    s2 = 0;
elseif size(e2) == 1
    mu = 0;
    sigma = 0;
    s2 = 0;
else
    KAKURITUBU_BUNNPU1(1,e2,'b',[-15:0.01:15],[],1)
    global pd
    mu=pd.mu;
    sigma=pd.sigma;
    s2 = max([abs(mu+sigma),abs(mu-sigma)]);
end
% o_sfig(2,[-15 15],[],[],[],[],[num2str(time_label(i,:))],'σ\σ-400以下')
%% 
if isempty(e3) == 1
    mu = 0;
    sigma = 0;
    s3 = 0;
elseif size(e3) == 1
    mu = 0;
    sigma = 0;
    s3 = 0;
else
    KAKURITUBU_BUNNPU1(1,e3,'b',[-15:0.01:15],[],1)
    global pd
    mu=pd.mu;
    sigma=pd.sigma;
    s3 = max([abs(mu+sigma),abs(mu-sigma)]);
end
% o_sfig(2,[-15 15],[],[],[],[],[num2str(time_label(i,:))],'σ\σ-600以下')
%% 
if isempty(e4) == 1
    mu = 0;
    sigma = 0;
    s4 = 0;
elseif size(e4) == 1
    mu = 0;
    sigma = 0;
    s4 = 0;
else
    KAKURITUBU_BUNNPU1(1,e4,'b',[-15:0.01:15],[],1)
    global pd
    mu=pd.mu;
    sigma=pd.sigma;
    s4 = max([abs(mu+sigma),abs(mu-sigma)]);
end
% o_sfig(2,[-15 15],[],[],[],[],[num2str(time_label(i,:))],'σ\σ-800以下')
%% 
if isempty(e5) == 1
    mu = 0;
    sigma = 0;
    s5 = 0;
elseif size(e5) == 1
    mu = 0;
    sigma = 0;
    s5 = 0;
else
    KAKURITUBU_BUNNPU1(1,e5,'b',[-15:0.01:15],[],1)
    global pd
    mu=pd.mu;
    sigma=pd.sigma;
    s5 = max([abs(mu+sigma),abs(mu-sigma)]);
end
% o_sfig(2,[-15 15],[],[],[],[],[num2str(time_label(i,:))],'σ\σ-1000以下')
%% 
if isempty(e6) == 1
    mu = 0;
    sigma = 0;
    s6 = 0;
elseif size(e6) == 1
    mu = 0;
    sigma = 0;
    s6 = 0;
else
    KAKURITUBU_BUNNPU1(1,e6,'b',[-15:0.01:15],[],1)
    global pd
    mu=pd.mu;
    sigma=pd.sigma;
    s6 = max([abs(mu+sigma),abs(mu-sigma)]);
end
% o_sfig(2,[-15 15],[],[],[],[],[num2str(time_label(i,:))],'σ\σ-1000以下')
%% 
if isempty(e7) == 1
    mu = 0;
    sigma = 0;
    s7 = 0;
elseif size(e7) == 1
    mu = 0;
    sigma = 0;
    s7 = 0;
else
    KAKURITUBU_BUNNPU1(1,e7,'b',[-15:0.01:15],[],1)
    global pd
    mu=pd.mu;
    sigma=pd.sigma;
    s7 = max([abs(mu+sigma),abs(mu-sigma)]);
end
% o_sfig(2,[-15 15],[],[],[],[],[num2str(time_label(i,:))],'σ\σ-1000以下')
%% 
if isempty(e8) == 1
    mu = 0;
    sigma = 0;
    s8 = 0;
elseif size(e8) == 1
    mu = 0;
    sigma = 0;
    s8 = 0;
else
    KAKURITUBU_BUNNPU1(1,e8,'b',[-15:0.01:15],[],1)
    global pd
    mu=pd.mu;
    sigma=pd.sigma;
    s8 = max([abs(mu+sigma),abs(mu-sigma)]);
end
% o_sfig(2,[-15 15],[],[],[],[],[num2str(time_label(i,:))],'σ\σ-1000以下')
%% 
if isempty(e9) == 1
    mu = 0;
    sigma = 0;
    s9 = 0;
elseif size(e9) == 1
    mu = 0;
    sigma = 0;
    s9 = 0;
else
    KAKURITUBU_BUNNPU1(1,e9,'b',[-15:0.01:15],[],1)
    global pd
    mu=pd.mu;
    sigma=pd.sigma;
    s9 = max([abs(mu+sigma),abs(mu-sigma)]);
end
%% 
if isempty(e10) == 1
    mu = 0;
    sigma = 0;
    s10 = 0;
elseif size(e10) == 1
    mu = 0;
    sigma = 0;
    s10 = 0;
else
    KAKURITUBU_BUNNPU1(1,e10,'b',[-15:0.01:15],[],1)
    global pd
    mu=pd.mu;
    sigma=pd.sigma;
    s10 = max([abs(mu+sigma),abs(mu-sigma)]);
end