%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load_var_hydro_constants.m 可変速揚水発電機モデルの定数設定
% 【このプログラムで実施すること】
%　・プラントタイプの設定
%　・設定定数の読込み
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 定数設定：可変速揚水発電機モデル
% 1機1タイプだが指定する
 TY_VA = 1;
% Excelシートからの読み込み
% -- 定数設定 --
 Data = '定数.xlsx';
% -- 可変速揚水定数 --
 Va_data = xlsread(Data,'可変速揚水定数','C2:C30');
% -- 可変速揚水関数 --
 Va_f_n_gn = xlsread(Data,'可変速揚水関数（発電）','A4:B8');
 Va_f_y_gn = xlsread(Data,'可変速揚水関数（発電）','A14:B18');
 Va_f_n_pm = xlsread(Data,'可変速揚水関数（揚水）','A4:B8');
 Va_f_y_pm = xlsread(Data,'可変速揚水関数（揚水）','A14:B18');
 Va_f_t_pm = xlsread(Data,'可変速揚水関数（揚水）','A24:B28');

% 定数をExcelファイルから読み込み
 GMW_VA_ty       = Va_data(1,:);  % 定格出力[MW]
 U_MWD_GN_VA_ty  = Va_data(2,:);  % 出力上限（発電）[pu]
 L_MWD_GN_VA_ty  = Va_data(3,:);  % 出力下限（発電）[pu]
 U_MWD_PM_VA_ty  = Va_data(4,:);  % 入力上限（揚水）[pu]
 L_MWD_PM_VA_ty  = Va_data(5,:);  % 入力下限（揚水）[pu]
 RATE_GN_VA_ty   = Va_data(6,:);  % 変化率リミッタ（発電） [pu/s]
 RATE_PM_VA_ty   = Va_data(7,:);  % 変化率リミッタ（揚水） [pu/s]
 K_SD_VA_ty      = Va_data(8,:);  % 速度垂下率
 KP_PID_VA_ty    = Va_data(9,:);  % PID比例要素ゲイン
 KI_PID_VA_ty    = Va_data(10,:); % PID積分要素ゲイン
 KD_PID_VA_ty    = Va_data(11,:); % PID微分要素ゲイン
 TD_PID_VA_ty    = Va_data(12,:); % PID微分要素時定数
 K1_CONV_VA_ty   = Va_data(13,:); % コンバータゲイン
 T1_CONV_VA_ty   = Va_data(14,:); % コンバータ時定数
 K2_SERV_VA_ty   = Va_data(15,:); % サーボモータゲイン
 T2_SERV_VA_ty   = Va_data(16,:); % サーボモータ時定数
 T3_SERV_VA_ty   = Va_data(17,:); % サーボモータ時定数（2次遅れ）
 K_MW_GV_VA_ty   = Va_data(18,:); % ガイドベーン開度出力換算係数
 TW_WAY_VA_ty    = Va_data(19,:); % 水路特性時定数
 M_VA_ty         = Va_data(20,:); % 回転子慣性定数
 T_N_VA_ty       = Va_data(21,:); % 速度指令時定数
 KP_SG_GN_VA_ty  = Va_data(22,:); % 調速機比例要素ゲイン（発電）
 KI_SG_GN_VA_ty  = Va_data(23,:); % 調速機積分要素ゲイン（発電）
 KD_SG_GN_VA_ty  = Va_data(24,:); % 調速機微分要素ゲイン（発電）
 TD_SG_GN_VA_ty  = Va_data(25,:); % 調速機微分要素時定数（発電）
 KP_SG_PM_VA_ty  = Va_data(26,:); % 調速機比例要素ゲイン（揚水）
 KI_SG_PM_VA_ty  = Va_data(27,:); % 調速機積分要素ゲイン（揚水）
 KD_SG_PM_VA_ty  = Va_data(28,:); % 調速機微分要素ゲイン（揚水）
 TD_SG_PM_VA_ty  = Va_data(29,:); % 調速機微分要素時定数（揚水）

% 最適回転速度 関数発生器(発電)
 FX_N_GN_VA_ty = Va_f_n_gn(:,1:2:end); % 有効電力指令[pu]
 FY_N_GN_VA_ty = Va_f_n_gn(:,2:2:end); % 回転速度[pu]

% 最適案内羽根開度 関数発生器(発電)
 FX_Y_GN_VA_ty = Va_f_y_gn(:,1:2:end); % 有効電力指令[pu]
 FY_Y_GN_VA_ty = Va_f_y_gn(:,2:2:end); % 案内羽根開度[pu]

% 最適回転速度 関数発生器(揚水)
 FX_N_PM_VA_ty = Va_f_n_pm(:,1:2:end); % 有効電力指令[pu]
 FY_N_PM_VA_ty = Va_f_n_pm(:,2:2:end); % 回転速度[pu]

% 最適案内羽根開度 関数発生器(揚水)
 FX_Y_PM_VA_ty = Va_f_y_pm(:,1:2:end); % 有効電力指令[pu]
 FY_Y_PM_VA_ty = Va_f_y_pm(:,2:2:end); % 案内羽根開度[pu]

% 水車出力特性(揚水)
 FX_T_PM_VA_ty = Va_f_t_pm(:,1:2:end); % 回転速度[pu]
 FY_T_PM_VA_ty = Va_f_t_pm(:,2:2:end); % 出力[pu]

% タイプ別に定数をExcelファイルから読み込み
GMW_VA       = GMW_VA_ty(TY_VA);  % 定格出力[MW]
U_MWD_GN_VA  = U_MWD_GN_VA_ty(TY_VA);  % 出力上限（発電）[pu]
L_MWD_GN_VA  = L_MWD_GN_VA_ty(TY_VA);  % 出力下限（発電）[pu]
U_MWD_PM_VA  = U_MWD_PM_VA_ty(TY_VA);  % 入力上限（揚水）[pu]
L_MWD_PM_VA  = L_MWD_PM_VA_ty(TY_VA);  % 入力下限（揚水）[pu]
RATE_GN_VA   = RATE_GN_VA_ty(TY_VA);  % 変化率リミッタ（発電） [pu/s]
RATE_PM_VA	 = RATE_PM_VA_ty(TY_VA);  % 変化率リミッタ（揚水） [pu/s]
K_SD_VA      = K_SD_VA_ty(TY_VA);  % 速度垂下率
KP_PID_VA    = KP_PID_VA_ty(TY_VA);  % PID比例要素ゲイン
KI_PID_VA    = KI_PID_VA_ty(TY_VA); % PID積分要素ゲイン
KD_PID_VA    = KD_PID_VA_ty(TY_VA); % PID微分要素ゲイン
TD_PID_VA    = TD_PID_VA_ty(TY_VA); % PID微分要素時定数
K1_CONV_VA   = K1_CONV_VA_ty(TY_VA); % コンバータゲイン
T1_CONV_VA   = T1_CONV_VA_ty(TY_VA); % コンバータ時定数
K2_SERV_VA   = K2_SERV_VA_ty(TY_VA); % サーボモータゲイン
T2_SERV_VA   = T2_SERV_VA_ty(TY_VA); % サーボモータ時定数
T3_SERV_VA   = T3_SERV_VA_ty(TY_VA); % サーボモータ時定数（2次遅れ）
K_MW_GV_VA   = K_MW_GV_VA_ty(TY_VA); % ガイドベーン開度出力換算係数
TW_WAY_VA    = TW_WAY_VA_ty(TY_VA); % 水路特性時定数
M_VA         = M_VA_ty(TY_VA); % 回転子慣性定数
T_N_VA       = T_N_VA_ty(TY_VA); % 速度指令時定数
KP_SG_GN_VA  = KP_SG_GN_VA_ty(TY_VA); % 調速機比例要素ゲイン（発電）
KI_SG_GN_VA  = KI_SG_GN_VA_ty(TY_VA); % 調速機積分要素ゲイン（発電）
KD_SG_GN_VA  = KD_SG_GN_VA_ty(TY_VA); % 調速機微分要素ゲイン（発電）
TD_SG_GN_VA  = TD_SG_GN_VA_ty(TY_VA); % 調速機微分要素時定数（発電）
KP_SG_PM_VA  = KP_SG_PM_VA_ty(TY_VA); % 調速機比例要素ゲイン（揚水）
KI_SG_PM_VA  = KI_SG_PM_VA_ty(TY_VA); % 調速機積分要素ゲイン（揚水）
KD_SG_PM_VA  = KD_SG_PM_VA_ty(TY_VA); % 調速機微分要素ゲイン（揚水）
TD_SG_PM_VA  = TD_SG_PM_VA_ty(TY_VA); % 調速機微分要素時定数（揚水）

% 最適回転速度 関数発生器(発電)
FX_N_GN_VA = FX_N_GN_VA_ty(:,TY_VA); % 有効電力指令[pu]
FY_N_GN_VA = FY_N_GN_VA_ty(:,TY_VA); % 回転速度[pu]

% 最適案内羽根開度 関数発生器(発電)
FX_Y_GN_VA = FX_Y_GN_VA_ty(:,TY_VA); % 有効電力指令[pu]
FY_Y_GN_VA = FY_Y_GN_VA_ty(:,TY_VA); % 案内羽根開度[pu]

% 最適回転速度 関数発生器(揚水)
FX_N_PM_VA = FX_N_PM_VA_ty(:,TY_VA); % 有効電力指令[pu]
FY_N_PM_VA = FY_N_PM_VA_ty(:,TY_VA); % 回転速度[pu]

% 最適案内羽根開度 関数発生器(揚水)
FX_Y_PM_VA = FX_Y_PM_VA_ty(:,TY_VA); % 有効電力指令[pu]
FY_Y_PM_VA = FY_Y_PM_VA_ty(:,TY_VA); % 案内羽根開度[pu]

% 水車出力特性(揚水)
FX_T_PM_VA = FX_T_PM_VA_ty(:,TY_VA); % 回転速度[pu]
FY_T_PM_VA = FY_T_PM_VA_ty(:,TY_VA); % 出力[pu]

clear Data Va_data
clear -regexp Va_f_.*
clear -regexp .*_VA_ty
