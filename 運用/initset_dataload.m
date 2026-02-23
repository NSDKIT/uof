%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% iniset.m シミュレーション時間等の設定、標準データ、発電計画データの読込み
% 【このプログラムで実施すること】
%　・シミュレーション刻み、シミュレーション対象時間の設定
%　・標準データの読込み(Simulink入力ファイルの作成)
%  ・発電計画ツールで生成した予測データの読込み(Simulink入力ファイルの作成)
%  ・発電計画ツールで生成した発電機スペックの読込み(Simulink入力ファイルの作成)
%  ・発電計画ツールで生成した発電機スペックの読込み(EDC計算の初期値設定)
%  ・発電計画ツールで生成した発電機の運転状況の読込み(Simulink入力ファイルの作成)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% シミュレーション刻みの設定
  dtload = 0.1;                   %シミュレーションデータ刻み時間(s)

%% シミュレーション対象時間（0:00:00を1,23:59:59を86400として換算）
% 解析例題1-1および解析例題4
  %stime = 46801;                %開始時刻 13:00:00
  %etime = 57601;                %終了時刻 16:00:00

% 解析例題1-2,解析例題2および解析例題3
  stime = 1;                %開始時刻 00:00:00
  etime = 86401;                %終了時刻 23:30:00

%% 入力ファイル読み込みのための時間ベクトル定義
  ttime = 0:1:88199;              %0～24時の1秒刻みのベクトル
  ttimepre5m = (stime-299):1:(etime+1800-299); %EDC予測用に5分ずらしたベクトル

%シミュレーション時間(3時間)の時系列縦ベクトル作成
  simtimevector = stime:1:etime;
  simtimevector =simtimevector';
  simtime = size(simtimevector,1);

%% 発電計画ツールで作成した予測データに関する入力ファイルの読込み

% 需要予測データの読込み
 load_forecast_input = csvread('Load_Forecast.csv',1,1,[1,1,simtime,1]); 
 load_forecast_input = horzcat(simtimevector,load_forecast_input);
 load_forecast_input=load_forecast_input';

% 太陽光発電予測データの読込み
 PV_Forecast=csvread('PV_Forecast.csv',1,1,[1,1,simtime,1]);
 PV_Forecast = horzcat(simtimevector,PV_Forecast);
 PV_Forecast=PV_Forecast';
 save PV_Forecast.mat PV_Forecast  %Simulink入力ファイル(PV_Forecast.mat)の作成


%% 標準データ（需要・太陽光・風力）の読込み ※1800秒追加箇所

% 需要データの読込み
 load_input=csvread('Load.csv',1,1);
%  load_input=[load_forecast_input(2,1:1800).*ones(2,1800),load_input(1:end-1800,:)']; % 1800秒追加箇所
 load_input=load_input'; % 変更前
 load_input=[ttime;load_input];
 load_input=load_input(:,stime+1:etime+1);
 save load_input.mat load_input  %Simulink入力ファイル(load_input.mat)の作成

% 太陽光発電データの読込み
 PV_Out=csvread('PV_Out.csv',1,1);
%  PV_Out=[PV_Forecast(2,1:1800),PV_Out(1:end-1800)']; % 1800秒追加箇所
 PV_Out=PV_Out'; % 変更前
 PV_Out=[ttime;PV_Out];
 PV_Out=PV_Out(:,stime+1:etime+1);
 save PV_Out.mat PV_Out   %Simulink入力ファイル(PV_Out.mat)の作成 
 
% 風力発電データの読込み
 WT_Out=csvread('WT_Out.csv',1,1);
 WT_Out=WT_Out';
 WT_Out=[ttime;WT_Out];
 WT_Out=WT_Out(:,stime+1:etime+1);
 save WT_Out.mat WT_Out   %Simulink入力ファイル(WT_Out.mat)の作成
 
 %% 水素負荷追加
%  load('mode.mat')
%  if mode == 3
%      load('hydro_rate.mat')
%      load('lfclfc.mat')
%      PVF = PV_Forecast(2,:);
%      if lfc == 100
%          a1=zeros(1,17)';a2=max(PVF)/2;a3=max(PVF)*ones(1,13)';a4=zeros(1,18)';
%          hydro_load=[a1;a2;a3;a2;a4]*hydro_rate;
%          hydro = [];
%          for t = 1:48
%              hydro = [hydro;interp1q([1;1800],[hydro_load(t);hydro_load(t+1)],[1:1800]')];
%          end
%          hydro = [hydro;hydro(end)]';
% %          hydro_other = [hydro(301:end),zeros(1,300)];
%          save hydro.mat hydro
%          hydro = load_input(2,:)+hydro;
% %          hydro_other = load_input(3,:)+hydro_other;
%         load_input(2,:) = hydro;
% %      load_input(3,:) = hydro_other;
%      else
%          hydro = 0;
%      end
%      save load_input.mat load_input  %Simulink入力ファイル(load_input.mat)の作成
%  else
%      hydro = 0;
%      save hydro.mat hydro
%  end
 %%

% 風力発電予測データの読込み
 WT_Forecast = csvread('WT_Forecast.csv',1,1,[1,1,simtime,1]);
 WT_Forecast = horzcat(simtimevector,WT_Forecast);
 WT_Forecast = WT_Forecast';
 save WT_Forecast.mat WT_Forecast  %Simulink入力ファイル(WT_Forecast.mat)の作成

% 自エリアは残余需要の予測データに修正
 load_forecast_input(2,:) = load_forecast_input(2,:) - PV_Forecast(2,:) - WT_Forecast(2,:);
 save load_forecast_input.mat load_forecast_input  %Simulink入力ファイル(load_forecast_input.mat)の作成

% 連系線潮流計画値データの読込み
 Tieline_Base = csvread('Tieline_Base.csv',1,1,[1,1,simtime,1]);
 Tieline_Base = horzcat(simtimevector,Tieline_Base);
 Tieline_Base = Tieline_Base';
 save Tieline_Base.mat Tieline_Base  %Simulink入力ファイル(load_forecast_input.mat)の作成


%% EDC目標出力の作成(5分先の需要・自然変動電源の予測値)

% 需要の予測値（5分先）の読込み
 load_forecast_300s_input = csvread('Load_Forecast.csv',1,1,[1,1,simtime+1800,1]); 
 load_forecast_300s_input=load_forecast_300s_input';
 load_forecast_300s_input =[ttimepre5m;load_forecast_300s_input];
 load_forecast_300s_input=load_forecast_300s_input(:,300:simtime+299);

% 太陽光発電の予測値（5分先）の読込み
 PV_forecast_300s_input = csvread('PV_Forecast.csv',1,1,[1,1,simtime+1800,1]);
 PV_forecast_300s_input=PV_forecast_300s_input';
 PV_forecast_300s_input =[ttimepre5m;PV_forecast_300s_input];
 PV_forecast_300s_input=PV_forecast_300s_input(:,300:simtime+299);

% 風力発電の予測値（5分先）の読込み
 WT_forecast_300s_input = csvread('WT_Forecast.csv',1,1,[1,1,simtime+1800,1]);
 WT_forecast_300s_input=WT_forecast_300s_input';
 WT_forecast_300s_input =[ttimepre5m;WT_forecast_300s_input];
 WT_forecast_300s_input=WT_forecast_300s_input(:,300:simtime+299);

% 自エリアは残余需要の予測データ（5分先）に修正
 load_forecast_300s_input(2,:) = load_forecast_300s_input(2,:) - PV_forecast_300s_input(2,:) - WT_forecast_300s_input(2,:); 
 save load_forecast_300s_input.mat load_forecast_300s_input  %Simulink入力ファイル(load_forecast_300s_input.mat)の作成

%% 発電計画ツールで定義した発電機スペックに関する入力ファイルの読込み

% 発電機の慣性定数データの読込み
 inertia_input=csvread('Inertia.csv',1,1,[1,1,simtime,2]);
 inertia_input = horzcat(simtimevector,inertia_input);
 inertia_input=inertia_input';
 save inertia_input.mat inertia_input %Simulink入力ファイル(inertia_input.mat)の作成

% 発電機(AGC30)の定格出力と最低出力の読込み 
 GMW = csvread('G_up_limit.csv',0,1);
 Gmin = csvread('G_down_limit.csv',0,1);


% 発電機(AGC30)の出力変化速度データの読込み
 G_speed = csvread('G_rate.csv',0,1);
 G_speed = G_speed(:,1);  % EDC計算における入力設定値
 
% 発電機(AGC30)の増分燃料費特性データの読込み
 Cost=csvread('Cost.csv',1,1,[1,1,30,3]);
 G_cost=[Cost(:,3);
        Cost(:,2);
        Cost(:,1)];  % EDC計算における入力設定値

% 発電機(AGC30)の計画上下限値の読込み
 G_up_limit=csvread('G_up_plan_limit.csv',0,1);     % EDC計算における入力設定値
%  G_down_limit=csvread('G_down_plan_limit_time.csv'); % EDC計算における入力設定値
%  save G_down_limit.mat G_down_limit
 G_down_limit=csvread('G_down_plan_limit.csv',0,1); % EDC計算における入力設定値
    
 
%% 発電計画ツールで定義した発電機の運転状況に関する入力ファイルの読込み

% 発電機(AGC30)の計画出力の読込み
 g_out_input=csvread('G_Out.csv',1,1,[1,1,simtime,30]);
 g_out_input = horzcat(simtimevector,g_out_input);
 g_out_input=g_out_input';
 save g_out_input.mat g_out_input %Simulink入力ファイル(g_out_input.mat)の作成

% 固定電源出力データの読込み 
 g_const_out_input=csvread('G_Const_Out.csv',1,1,[1,1,simtime,7]);
 g_const_out_input = horzcat(simtimevector,g_const_out_input);
 g_const_out_input=g_const_out_input';
 save g_const_out_input.mat g_const_out_input  %Simulink入力ファイル(g_const_out_input.mat)の作成

% 固定電源出力の合成
 g_const_out_sum=sum(g_const_out_input(2:8,:));
 g_const_out_sum=g_const_out_sum';
 g_const_out_sum = horzcat(simtimevector,g_const_out_sum);
 g_const_out_sum=g_const_out_sum';
 save g_const_out_sum.mat g_const_out_sum  %Simulink入力ファイル(g_const_out_sum.mat)の作成

% 発電機制御モードデータの読込み
 g_mode_input=csvread('G_Mode.csv',1,1,[1,1,simtime,30]);
 g_mode_input = horzcat(simtimevector,g_mode_input);
 g_mode_input=g_mode_input';
 save g_mode_input.mat g_mode_input  %Simulink入力ファイル(g_mode_input.mat)の作成

