%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load_thermal_constants.m 汽力プラントモデル・GTCCプラントモデルの定数設定
% 【このプログラムで実施すること】
%　・各プラントタイプの設定
%　・設定定数の読込み
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% 定数設定：汽力プラントモデル
% 汽力プラント番号（1〜17）とタイプ番号（1〜6）の関連付け
% 1: 発電機#1(石油#1)
% 2: 発電機#2(石油#2)
% 3: 発電機#3(石油#3)
% 4: 発電機#4(石油#4)
% 5: 発電機#6,7(石炭#1,2）
% 6: 発電機#8(石炭#3）
% 7: 発電機#10(石炭#5）
% 8: 発電機#9(石炭#4）
% 9: 発電機#11(石炭#6）
% 6: 発電機(LNGは使わない）
 TY_ST = [1, 2, 3, 4, 1, 5, 5, 6, 8, 7, 9, 1, 1, 1, 1, 1, 1];

% Excelシートからの読み込み
% -- 定数設定 --
 Data = '定数.xlsx';
% % -- 汽力定数 --
%  St_data = xlsread(Data,'汽力定数','C2:L30');
% % -- 汽力関数 --
%  St_fx1 = xlsread(Data,'汽力関数','A3:T9');
%  St_fx2 = xlsread(Data,'汽力関数','A23:T27');

load('ST.mat')
 % 初期出力の定義
 MW0_ST_OA(1) = 1.0;
 
% タイプ毎の定数をExcelファイルから読み込み
 Gmw_st_ty    = St_data(1,:);   % 定格出力[MW]
 U_mwd_st_ty  = St_data(2,:);   % 出力上限[pu]
 L_mwd_st_ty  = St_data(3,:);   % 出力下限[pu]
 R_mwd_st_ty  = St_data(4,:);   % 出力変化率[pu/min]
 T1_b_st_ty   = St_data(5,:);   % ボイラ発生蒸気時定数[s]
 T2_b_st_ty   = St_data(6,:);   % ボイラ特性時定数[s]
 T3_b_st_ty   = St_data(7,:);   % 圧力制御時定数[s]
 T_t_st_ty    = St_data(8,:);   % 出力制御時定数[s]
 Sw_t_st_ty   = St_data(9,:);   % 出力制御時定数入切
 K_pref_st_ty = St_data(10,:);  % 負荷設定比例ゲイン
 T_pref_st_ty = St_data(11,:);  % 負荷設定積分時定数[s]
 U_pref_st_ty = St_data(12,:);  % 負荷設定上限[pu]
 L_pref_st_ty = St_data(13,:);  % 負荷設定下限[pu]
 Plm_st_ty    = St_data(14,:);  % ガバナフリー幅[pu]
 U_ll_st_ty   = St_data(15,:);  % 負荷制限上限[pu]
 L_ll_st_ty   = St_data(16,:);  % 負荷制限下限[pu]
 R_ll_st_ty   = St_data(17,:);  % 負荷制限変化率[pu/min]
 T_ll_st_ty   = St_data(18,:);  % 負荷制限時定数[s]
 Delta_st_ty  = St_data(19,:);  % 速度調定率[%]
 K_g_st_ty    = St_data(20,:);  % 高圧出力分担率
 T1_g_st_ty   = St_data(21,:);  % スピードリレー時定数[pu]
 T2_g_st_ty   = St_data(22,:);  % 蒸気加減弁サーボ時定数[s]
 T3_g_st_ty   = St_data(23,:);  % 蒸気加減弁サーボ開時間[s]
 T4_g_st_ty   = St_data(24,:);  % 高圧タービン時定数[s]
 T5_g_st_ty   = St_data(25,:);  % 低圧タービン・再熱器時定数[s]
 T6_g_st_ty   = St_data(26,:);  % 蒸気加減弁サーボ閉時間[s]
 U_g_st_ty    = St_data(27,:);  % 蒸気加減弁開度上限[pu]
 L_g_st_ty    = St_data(28,:);  % 蒸気加減弁開度下限[pu]
 G_g_st_ty    = St_data(29,:);  % スピードリレー進み時定数[s]

 Fx_fb_st_ty   = St_fx1(:, 1:2:size(St_fx1,2)-1); % 周波数偏差[Hz]
 Fy_fb_st_ty   = St_fx1(:, 2:2:size(St_fx1,2));   % MWD補正値（=周波数バイアス）[pu]
 Fx_pthd_st_ty = St_fx2(:, 1:2:size(St_fx2,2)-1); % ST出力[pu]
 Fy_pthd_st_ty = St_fx2(:, 2:2:size(St_fx2,2));   % 主蒸気圧力[pu]

% 各プラントについてタイプに応じた定数を代入
 GMW_ST    = Gmw_st_ty(TY_ST);    % 定格出力[MW]
 U_MWD_ST  = U_mwd_st_ty(TY_ST);  % 出力上限[pu]
 L_MWD_ST  = L_mwd_st_ty(TY_ST);  % 出力下限[pu]
 R_MWD_ST  = R_mwd_st_ty(TY_ST);  % 出力変化率[pu/min]
 T1_B_ST   = T1_b_st_ty(TY_ST);   % ボイラ発生蒸気時定数[s]
 T2_B_ST   = T2_b_st_ty(TY_ST);   % ボイラ特性時定数[s]
 T3_B_ST   = T3_b_st_ty(TY_ST);   % 圧力制御時定数[s]
 T_T_ST    = T_t_st_ty(TY_ST);    % 出力制御時定数[s]
 SW_T_ST   = Sw_t_st_ty(TY_ST);   % 出力制御時定数入切
 K_PREF_ST = K_pref_st_ty(TY_ST); % 負荷設定比例ゲイン
 T_PREF_ST = T_pref_st_ty(TY_ST); % 負荷設定積分時定数[s]
 U_PREF_ST = T_pref_st_ty(TY_ST); % 負荷設定上限[pu]
 L_PREF_ST = L_pref_st_ty(TY_ST); % 負荷設定下限[pu]
 PLM_ST    = Plm_st_ty(TY_ST);    % ガバナフリー幅[pu]
 U_LL_ST   = U_ll_st_ty(TY_ST);   % 負荷制限上限[pu]
 L_LL_ST   = L_ll_st_ty(TY_ST);   % 負荷制限下限[pu]
 R_LL_ST   = R_ll_st_ty(TY_ST);   % 負荷制限変化率[pu/min]
 T_LL_ST   = T_ll_st_ty(TY_ST);   % 負荷制限時定数[s]
 DELTA_ST  = Delta_st_ty(TY_ST);  % 速度調定率[%]
 K_G_ST    = K_g_st_ty(TY_ST);    % 高圧出力分担率
 T1_G_ST   = T1_g_st_ty(TY_ST);   % スピードリレー時定数[pu]
 T2_G_ST   = T2_g_st_ty(TY_ST);   % 蒸気加減弁サーボ時定数[s]
 T3_G_ST   = T3_g_st_ty(TY_ST);   % 蒸気加減弁サーボ開時間[s]
 T4_G_ST   = T4_g_st_ty(TY_ST);   % 高圧タービン時定数[s]
 T5_G_ST   = T5_g_st_ty(TY_ST);   % 低圧タービン・再熱器時定数[s]
 T6_G_ST   = T6_g_st_ty(TY_ST);   % 蒸気加減弁サーボ閉時間[s]
 U_G_ST    = U_g_st_ty(TY_ST);    % 蒸気加減弁開度上限[pu]
 L_G_ST    = L_g_st_ty(TY_ST);    % 蒸気加減弁開度下限[pu]
 G_G_ST    = G_g_st_ty(TY_ST);    % スピードリレー進み時定数[s]

 FX_FB_ST   = Fx_fb_st_ty(:,TY_ST);   % 周波数偏差[Hz]
 FY_FB_ST   = Fy_fb_st_ty(:,TY_ST);   % MWD補正値（=周波数バイアス）[pu]
 FX_PTHD_ST = Fx_pthd_st_ty(:,TY_ST); % ST出力[pu]
 FY_PTHD_ST = Fy_pthd_st_ty(:,TY_ST); % 主蒸気圧力[pu]

% %% 水素貯蔵設備用
% a1 = Guplimit('G_up_limit.csv');
% a2 = Guplimit('G_up_plan_limit.csv');
% a3 = Guplimit('G_down_plan_limit.csv');
 %% 定数設定：GTCCプラントモデル
% GTCCプラントモデルの番号（1〜10）とタイプ番号（1,2）の関連付け
% 1: LNG
% 2: LNG+水素専焼 2022.3.18現在はLNGと同じ，燃料費を変えただけ
% 3: 燃料電池
TY_CC = [1, 1, 1, 1, 1, 1, 1, 1, 2, 2];

% Excelシートからの読み込み
% -- GTCC定数 --
%  Cc_data = xlsread(Data,'GTCC定数','C2:D34');
% % -- GTCC関数 --
%  Cc_fx1 = xlsread(Data,'GTCC関数','A4:D9');   % 周波数バイアス
%  Cc_fx2 = xlsread(Data,'GTCC関数','A24:D27'); % 排ガス温度設定値（燃料流量制御用）
%  Cc_fx3 = xlsread(Data,'GTCC関数','A44:D47'); % 排ガス温度設定値（空気流量制御用）
load('CC.mat')
% タイプ毎の定数をExcelファイルから読み込み
 Gmw_cc_ty    = Cc_data(1,:);  % 定格出力[MW]
 U_mwd_cc_ty  = Cc_data(2,:);  % 出力上限[pu]
 L_mwd_cc_ty  = Cc_data(3,:);  % 出力下限[pu]
 R_mwd_cc_ty  = Cc_data(4,:);  % 出力変化率[pu/min]
 Ti_cc_ty     = Cc_data(5,:);  % 大気温度[℃]
 Fgt_cc_ty    = Cc_data(6,:);  % 定格出力時のGT出力分担比
 Tio_cc_ty    = Cc_data(7,:);  % 大気温度設計値[℃]
 Tfo_cc_ty    = Cc_data(8,:);  % 定格出力時のGT入口温度[℃]
 Prc_cc_ty    = Cc_data(9,:);  % 圧縮機圧力比
 Rc_cc_ty     = Cc_data(10,:); % 圧縮部比熱比
 Hc_cc_ty     = Cc_data(11,:); % 圧縮機効率[pu]
 Rt_cc_ty     = Cc_data(12,:); % 燃焼器・タービン部比熱比
 Ht_cc_ty     = Cc_data(13,:); % タービン効率[pu]
 Ep_cc_ty     = Cc_data(14,:); % 総圧力損失[pu]
 T_b_cc_ty    = Cc_data(15,:); % 排熱回収ボイラ一次遅れ時定数[s]
 Delta_cc_ty  = Cc_data(16,:); % 速度調定率[%]
 T_pref_cc_ty = Cc_data(17,:); % 負荷設定積分時定数[s]
 U_pref_cc_ty = Cc_data(18,:); % 負荷設定上限[pu]
 L_pref_cc_ty = Cc_data(19,:); % 負荷設定下限[pu]
 R_pref_cc_ty = Cc_data(20,:); % 負荷設定変化率[pu/min]
 Plm_cc_ty    = Cc_data(21,:); % GF幅[pu]
 T_ll_cc_ty   = Cc_data(22,:); % 負荷制限制御一次遅れ時定数[s]
 T_te_cc_ty   = Cc_data(23,:); % 排ガス温度制御一次遅れ時定数[s]
 K_te_cc_ty   = Cc_data(24,:); % 排ガス温度偏差ゲイン
 T_tem_cc_ty  = Cc_data(25,:); % 排ガス温度計測一次遅れ時定数[s]
 K_igv_cc_ty  = Cc_data(26,:); % IGV開度制御比例ゲイン
 T_igv_cc_ty  = Cc_data(27,:); % IGV開度制御積分時定数[s]
 U_igv_cc_ty  = Cc_data(28,:); % IGV開度上限[pu]
 L_igv_cc_ty  = Cc_data(29,:); % IGV開度下限[pu]
 T_igva_cc_ty = Cc_data(30,:); % IGVアクチュエータ一次遅れ時定数[s]
 T_fuel_cc_ty = Cc_data(31,:); % 燃料系統一次遅れ時定数[s]
 U_fuel_cc_ty = Cc_data(32,:); % 燃料制御信号上限[pu]
 L_fuel_cc_ty = Cc_data(33,:); % 燃料制御信号下限[pu]

 Fx_fb_cc_ty  = Cc_fx1(:, 1:2:size(Cc_fx1,2)-1); % 周波数偏差[Hz]
 Fy_fb_cc_ty  = Cc_fx1(:, 2:2:size(Cc_fx1,2));   % MWD補正値（=周波数バイアス）[pu]
 Fx_te1_cc_ty = Cc_fx2(:, 1:2:size(Cc_fx2,2)-1); % GT出力[pu]
 Fy_te1_cc_ty = Cc_fx2(:, 2:2:size(Cc_fx2,2));   % 排ガス温度設定値（燃料流量制御用）[pu]
 Fx_te2_cc_ty = Cc_fx3(:, 1:2:size(Cc_fx3,2)-1); % GT出力[pu]
 Fy_te2_cc_ty = Cc_fx3(:, 2:2:size(Cc_fx3,2));   % 排ガス温度設定値（空気流量制御用）[pu]

% 定数代入
 GMW_CC      = Gmw_cc_ty(TY_CC);        % 定格出力[MW]
 U_MWD_CC    = U_mwd_cc_ty(TY_CC);      % 出力上限[pu]
 L_MWD_CC    = L_mwd_cc_ty(TY_CC);      % 出力下限[pu]
 R_MWD_CC    = R_mwd_cc_ty(TY_CC);      % 出力変化率[pu/min]
 TI_CC       = Ti_cc_ty(TY_CC)+273.15;  % 大気温度[K]
 FGT_CC      = Fgt_cc_ty(TY_CC);        % 定格出力時のGT出力分担比
 TIR_CC      = Tio_cc_ty(TY_CC)+273.15; % 大気温度設計値[K]
 TFR_CC      = Tfo_cc_ty(TY_CC)+273.15; % 定格出力時のGT入口温度[K]
 PRC_CC      = Prc_cc_ty(TY_CC);        % 圧縮機圧力比
 RC_CC       = Rc_cc_ty(TY_CC);         % 圧縮部比熱比
 HC_CC       = Hc_cc_ty(TY_CC);         % 圧縮機効率[pu]
 RT_CC       = Rt_cc_ty(TY_CC);         % 燃焼器・タービン部比熱比
 HT_CC       = Ht_cc_ty(TY_CC);         % タービン効率[pu]
 EP_CC       = Ep_cc_ty(TY_CC);         % 総圧力損失[pu]
 T_B_CC      = T_b_cc_ty(TY_CC);        % 排熱回収ボイラ一次遅れ時定数[s]
 DELTA_CC    = Delta_cc_ty(TY_CC);      % 速度調定率[%]
 T_PREF_CC   = T_pref_cc_ty(TY_CC);     % 負荷設定積分時定数[s]
 U_PREF_CC   = U_pref_cc_ty(TY_CC);     % 負荷設定上限[pu]
 L_PREF_CC   = L_pref_cc_ty(TY_CC);     % 負荷設定下限[pu]
 R_PREF_CC   = R_pref_cc_ty(TY_CC);     % 負荷設定変化率[pu/min]
 PLM_CC      = Plm_cc_ty(TY_CC);        % GF幅[pu]
 T_LL_CC     = T_ll_cc_ty(TY_CC);       % 負荷制限制御一次遅れ時定数[s]
 T_TE_CC     = T_te_cc_ty(TY_CC);       % 排ガス温度制御一次遅れ時定数[s]
 K_TE_CC     = K_te_cc_ty(TY_CC);       % 排ガス温度偏差ゲイン
 T_TEM_CC    = T_tem_cc_ty(TY_CC);      % 排ガス温度計測一次遅れ時定数[s]
 K_IGV_CC    = K_igv_cc_ty(TY_CC);      % IGV開度制御比例ゲイン
 T_IGV_CC    = T_igv_cc_ty(TY_CC);      % IGV開度制御積分時定数[s]
 U_IGV_CC    = U_igv_cc_ty(TY_CC);      % IGV開度上限[pu]
 L_IGV_CC    = L_igv_cc_ty(TY_CC);      % IGV開度下限[pu]
 T_IGVA_CC   = T_igva_cc_ty(TY_CC);     % IGVアクチュエータ一次遅れ時定数[s]
 T_FUEL_CC   = T_fuel_cc_ty(TY_CC);     % 燃料系統一次遅れ時定数[s]
 U_FUEL_CC   = U_fuel_cc_ty(TY_CC);     % 燃料制御信号上限[pu]
 L_FUEL_CC   = L_fuel_cc_ty(TY_CC);     % 燃料制御信号下限[pu]

 FX_FB_CC  = Fx_fb_cc_ty(:,TY_CC);      % 周波数偏差[Hz]
 FY_FB_CC  = Fy_fb_cc_ty(:,TY_CC);      % MWD補正値（=周波数バイアス）[pu]
 FX_TE1_CC = Fx_te1_cc_ty(:,TY_CC);     % GT出力[pu]
 FY_TE1_CC = Fy_te1_cc_ty(:,TY_CC);     % 排ガス温度設定値（燃料流量制御用）[pu]
 FX_TE2_CC = Fx_te2_cc_ty(:,TY_CC);     % GT出力[pu]
 FY_TE2_CC = Fy_te2_cc_ty(:,TY_CC);     % 排ガス温度設定値（空気流量制御用）[pu]
