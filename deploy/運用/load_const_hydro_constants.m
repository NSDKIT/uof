%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load_const_hydro_constants.m 定速揚水発電プラントモデルの定数設定
% 【このプログラムで実施すること】
%　・プラントタイプの設定
%　・設定定数の読込み
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% 定数設定：定速揚水発電プラントモデル
%　タイプは１番のみだが指定する
 TY_WT = [1, 1];

% Excelシートからの読み込み
% -- 定数設定 --
 Data = '定数.xlsx';
% -- 定速揚水定数 --
 Wt_data = xlsread(Data,'定速揚水定数','C2:D17');
% -- 定速揚水関数 --
 Wt_fx1 = xlsread(Data,'定速揚水関数','A4:D9');

% 定数をExcelファイルから読み込み
 GMW_WT_ty       = Wt_data(1,:);   % 定格出力[MW]
 U_MWD_WT_ty     = Wt_data(2,:);   % 出力上限[pu]
 L_MWD_WT_ty     = Wt_data(3,:);   % 出力下限[pu]
 K_SEQ_WT_ty     = Wt_data(4,:);   % シーケンサゲイン
 K_SD_WT_ty      = Wt_data(5,:);   % 速度垂下率
 KP_PID_WT_ty    = Wt_data(6,:);   % PID比例要素ゲイン
 KI_PID_WT_ty    = Wt_data(7,:);   % PID積分要素ゲイン
 KD_PID_WT_ty    = Wt_data(8,:);   % PID微分要素ゲイン
 TD_PID_WT_ty    = Wt_data(9,:);   % PID微分要素時定数
 K1_CONV_WT_ty   = Wt_data(10,:);  % コンバータゲイン
 T1_CONV_WT_ty   = Wt_data(11,:);  % コンバータ時定数
 K2_SERV_WT_ty   = Wt_data(12,:);  % サーボモータゲイン
 T2_SERV_WT_ty   = Wt_data(13,:);  % サーボモータ時定数
 T3_SERV_WT_ty   = Wt_data(14,:);  % サーボモータ時定数(2次要素)
 P_G_CONV_WT_ty  = Wt_data(15,:);  % ガイド弁開度出力換算係数
 TW_WAY_WT_ty    = Wt_data(16,:);  % 水路特性時定数

FX_FB_WT_ty      = Wt_fx1(:, 1:2:size(Wt_fx1,2)-1);  % 周波数偏差[Hz]
FY_FB_WT_ty      = Wt_fx1(:, 2:2:size(Wt_fx1,2));    % MWD補正値（=周波数バイアス）[pu]

% タイプ別に定数をExcelファイルから読み込み
GMW_WT       = GMW_WT_ty(TY_WT);       % 定格出力[MW]
U_MWD_WT     = U_MWD_WT_ty(TY_WT);     % 出力上限[pu]
L_MWD_WT     = L_MWD_WT_ty(TY_WT);     % 出力下限[pu]
K_SEQ_WT     = K_SEQ_WT_ty(TY_WT);     % シーケンサゲイン
K_SD_WT      = K_SD_WT_ty(TY_WT);      % 速度垂下率
KP_PID_WT    = KP_PID_WT_ty(TY_WT);    % PID比例要素ゲイン
KI_PID_WT    = KI_PID_WT_ty(TY_WT);    % PID積分要素ゲイン
KD_PID_WT    = KD_PID_WT_ty(TY_WT);    % PID微分要素ゲイン
TD_PID_WT    = TD_PID_WT_ty(TY_WT);    % PID微分要素時定数
K1_CONV_WT   = K1_CONV_WT_ty(TY_WT);   % コンバータゲイン
T1_CONV_WT   = T1_CONV_WT_ty(TY_WT);   % コンバータ時定数
K2_SERV_WT   = K2_SERV_WT_ty(TY_WT);   % サーボモータゲイン
T2_SERV_WT   = T2_SERV_WT_ty(TY_WT);   % サーボモータ時定数
T3_SERV_WT   = T3_SERV_WT_ty(TY_WT);   % サーボモータ時定数(2次要素)
P_G_CONV_WT  = P_G_CONV_WT_ty(TY_WT);  % ガイド弁開度出力換算係数
TW_WAY_WT    = TW_WAY_WT_ty(TY_WT);    % 水路特性時定数

FX_FB_WT     = FX_FB_WT_ty(:,TY_WT);   % 周波数偏差[Hz]
FY_FB_WT     = FY_FB_WT_ty(:,TY_WT);   % MWD補正値（=周波数バイアス）[pu]
