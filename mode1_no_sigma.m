%% mode1_no_sigma.m
% # 役割
% `SIGMA_get.m` から呼び出される補助スクリプト。
% 予測PV出力の「大きさ」に応じて誤差データを複数の帯域に分割し、
% それぞれの帯域で確率分布関数(`KAKURITUBU_BUNNPU`)を呼び出して、
% 標準偏差(σ)を計算します。
%
% **注意:** このスクリプトは単体で実行するのではなく、`SIGMA_get.m` (`mode1=1`)の
% ループ処理の中で使用されます。
%
% # 前提条件
%
% `SIGMA_get.m` のワークスペース内に以下の変数が定義されていること。
%   - `year`, `i`, `PVC_bai`, `ERROR`
%
% # 入力(ワークスペースから)
%
% - `PV_forecast_YYYY.mat`: PV予測出力データ
% - `ERROR`: (`SIGMA_get.m`で読み込まれた)予測誤差データ
% - `i`: (`SIGMA_get.m`のループ変数) 時間断面インデックス
% - `PVC_bai`: (`SIGMA_get.m`から渡された) PV導入倍率
%
% # 出力(グローバル変数経由)
%
% - `s_s1`, `s_e1`, `s_s2`, `s_e2`, ...: 各帯域のσの開始点と終了点
%   (`KAKURITUBU_BUNNPU.m` 内の `global sigma_s, sigma_e` を通じて取得)

load(['PV_forecast_',num2str(year),'.mat'])
%% 時間断面での抽出(365日分)
data_all = data_all*PVC_bai;
data = data_all(:,i);
ERROR1 = ERROR*PVC_bai;
E=ERROR1(:,i);
%% 予測PV出力が200以下
a200 = (data<200);
E1=E.*a200;
e1=E1(find(a200==1));
e_l1 = length(e1);
%% 予測PV出力が400以下
a400 = (data<400);
E2=E.*a400;
e2=E2(find(a400==1));
e_l2 = length(e2);
%% 予測PV出力が600以下
a600 = (data<600);
E3=E.*a600;
e3=E3(find(a600==1));
e_l3 = length(e3);
%% 予測PV出力が800以下
a800 = (data<800);
E4=E.*a800;
e4=E4(find(a800==1));
e_l4 = length(e4);
%% 予測PV出力が1000以下
a1000 = (data<1000);
E5=E.*a1000;
e5=E5(find(a1000==1));
e_l5 = length(e5);
%% 予測PV出力が1200以下
a1200 = (data<1200);
E6=E.*a1200;
e6=E6(find(a1200==1));
e_l6 = length(e6);
%% 予測PV出力が1400以下
a1400 = (data<1400);
E7=E.*a1400;
e7=E7(find(a1400==1));
e_l7 = length(e7);
%% 予測PV出力が1000以下
a1600 = (data<1600);
E8=E.*a1600;
e8=E5(find(a1600==1));
e_l8 = length(e8);
%% σ算出
load('time_label.mat')
close all
KAKURITUBU_BUNNPU(1,E1,'b',[-15:0.01:15],[],1)
% o_sfig(2,[-15 15],[],[],[],[],[num2str(time_label(i,:))],'σ\σ-200以下')
global sigma_s sigma_e
s_s1 = sigma_s;
s_e1 = sigma_e;
KAKURITUBU_BUNNPU(2,E2,'b',[-15:0.01:15],[],1)
% o_sfig(2,[-15 15],[],[],[],[],[num2str(time_label(i,:))],'σ\σ-400以下')
global sigma_s sigma_e
s_s2 = sigma_s;
s_e2 = sigma_e;
KAKURITUBU_BUNNPU(3,E3,'b',[-15:0.01:15],[],1)
% o_sfig(2,[-15 15],[],[],[],[],[num2str(time_label(i,:))],'σ\σ-600以下')
global sigma_s sigma_e
s_s3 = sigma_s;
s_e3 = sigma_e;
KAKURITUBU_BUNNPU(4,E4,'b',[-15:0.01:15],[],1)
% o_sfig(2,[-15 15],[],[],[],[],[num2str(time_label(i,:))],'σ\σ-800以下')
global sigma_s sigma_e
s_s4 = sigma_s;
s_e4 = sigma_e;
KAKURITUBU_BUNNPU(5,E5,'b',[-15:0.01:15],[],1)
% o_sfig(2,[-15 15],[],[],[],[],[num2str(time_label(i,:))],'σ\σ-1000以下')
global sigma_s sigma_e
s_s5 = sigma_s;
s_e5 = sigma_e;
KAKURITUBU_BUNNPU(5,E6,'b',[-15:0.01:15],[],1)
% o_sfig(2,[-15 15],[],[],[],[],[num2str(time_label(i,:))],'σ\σ-1000以下')
global sigma_s sigma_e
s_s6 = sigma_s;
s_e6 = sigma_e;
KAKURITUBU_BUNNPU(5,E7,'b',[-15:0.01:15],[],1)
% o_sfig(2,[-15 15],[],[],[],[],[num2str(time_label(i,:))],'σ\σ-1000以下')
global sigma_s sigma_e
s_s7 = sigma_s;
s_e7 = sigma_e;
KAKURITUBU_BUNNPU(5,E8,'b',[-15:0.01:15],[],1)
% o_sfig(2,[-15 15],[],[],[],[],[num2str(time_label(i,:))],'σ\σ-1000以下')
global sigma_s sigma_e
s_s8 = sigma_s;
s_e8 = sigma_e;