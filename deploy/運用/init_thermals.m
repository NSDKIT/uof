%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% init_thermals.m 汽力プラントモデル・GTCCプラントモデルの初期値計算
% 【このプログラムで実施すること】
%　・汽力プラントモデルの初期値計算
%　・GTCCプラントモデルの初期値計算(繰り返し計算)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 汽力プラントモデルの初期値計算

% 変数初期化
 MW0_ST = zeros(1,17);   % 初期出力[MW]
 PTH0_ST = zeros(1,17);  % 主蒸気圧力の初期値[pu]

% iniset_edc.mで等ラムダ法により求めた計画出力を初期値とする
 PG_INIT_ST = PMWD_SCHEDULE(1,2:18)';  % 汽力プラントの初期出力[MW]
 PG_INIT_CC = PMWD_SCHEDULE(1,19:28)'; % GTCCプラントの初期出力[MW]

 for i=1:17
     MW0_ST(i) = max([L_MWD_ST(i), PG_INIT_ST(i)/GMW_ST(i)]);  % 初期出力[pu]
     PTH0_ST(i) = interp1(FX_PTHD_ST(:,i), FY_PTHD_ST(:,i), MW0_ST(i)); % 主蒸気圧力の初期値[pu]
 end

%% 変数初期化：コンバインド
TDR_CC    = TIR_CC.*(1+(PRC_CC.^((RC_CC-1)./RC_CC)-1)./HC_CC);              % 圧縮機出口温度（定格出力時）[K]
PRT_CC    = PRC_CC.*(1-EP_CC);                                              % 圧力損失を考慮したタービン圧力比（定格出力時）
TER_CC    = TFR_CC.*(1-(1-1./PRT_CC.^((RT_CC-1)./RT_CC)).*HT_CC);           % 定格出力時のガスタービン出口温度（排ガス温度）
KGT_CC = FGT_CC./((TFR_CC-TER_CC)-(TDR_CC-TIR_CC));                         % GT出力係数
KST_CC = (1.0-FGT_CC)./TER_CC;                                              % ST出力係数
Td_min_cc  = TIR_CC.*(1+((PRC_CC.*L_IGV_CC).^((RC_CC-1)./RC_CC)-1)./HC_CC); % 空気流量最小値のときの圧縮機出口温度
WF_MIN_CC = L_IGV_CC./(TFR_CC-TDR_CC).*((Td_min_cc-TIR_CC)...
    ./((1-1./(PRT_CC.*L_IGV_CC).^((RT_CC-1)./RT_CC)).*HT_CC)-Td_min_cc);    % GT無負荷時燃料流量

WF0_CC   = 1.0*ones(1, 10);         % 燃料流量初期値[pu]
IGV0_CC  = WF0_CC;                  % IGV開度初期値[pu]
TE0_CC   = zeros(1, 10);            % 排ガス温度初期値[K]
PMST0_CC = zeros(1, 10);            % ST出力初期値[pu]
e_cc     = 1.0e-10;                 % 初期値計算の収束判定閾値
k_cc     = 1.0;                     % 初期値計算の修正係数
iter_max = 100;                     % 最大反復回数（修正係数に応じて変更する）

% 収束計算
for i = 1:10
    Pg_init_cc = max([L_MWD_CC(i), PG_INIT_CC(i)/GMW_CC(i)]);  % i番目のGTCC出力初期値[pu]
    for iter = 1:iter_max
        W0_cc       = IGV0_CC(i)*TIR_CC(i)/TI_CC(i);                                % 空気流量
        xc0_cc      = (PRC_CC(i)*W0_cc)^((RC_CC(i)-1)/RC_CC(i));                    % 圧縮機出口温度算出時の変数
        xt0_cc      = (PRT_CC(i)*W0_cc)^((RT_CC(i)-1)/RT_CC(i));                    % 排ガス温度算出時の変数
        Td0_cc      = TI_CC(i)*(1+(xc0_cc-1)/HC_CC(i));                             % 圧縮機出口温度初期値[K]
        Tf0_cc      = Td0_cc+(TFR_CC(i)-TDR_CC(i))*WF0_CC(i)/W0_cc;                 % ガスタービン入口温度初期値
        TE0_CC(i)   = Tf0_cc*(1-(1-1/xt0_cc)*HT_CC(i));                             % 排ガス温度初期値
        Pmgt0_cc    = KGT_CC(i)*((Tf0_cc-TE0_CC(i))-(Td0_cc-TI_CC(i)))*W0_cc;       % GT出力初期値
        PMST0_CC(i) = KST_CC(i)*TE0_CC(i)*W0_cc;                                    % ST出力初期値
        Pm0_cc      = Pmgt0_cc+PMST0_CC(i);                                         % 軸出力初期値
        Te_ref_cc   = interp1(FX_TE2_CC(:,i), FY_TE2_CC(:,i), Pmgt0_cc/FGT_CC(i));  % 空気流量制御用排ガス温度設定値
        dPm_cc      = Pg_init_cc-Pm0_cc;                                            % 出力偏差
        dTe_cc      = Te_ref_cc-TE0_CC(i)/TER_CC(i);                                % 排ガス温度偏差
        if abs(dPm_cc)<e_cc && abs(dTe_cc)<e_cc
            break
        else
            WF0_CC(i)   = WF0_CC(i)+dPm_cc*k_cc;                              % 燃料流量の修正
            IGV0_CC(i)  = IGV0_CC(i)-dTe_cc*k_cc;                             % IGV開度の修正
        end
    end
    if iter == iter_max
        error('初期値計算が収束しません。：GTCC_A');
    end
    % ===== IGV開度が上下限値を逸脱した場合 =====
    if IGV0_CC(i) < L_IGV_CC(i) || IGV0_CC(i) > U_IGV_CC(i)
        if IGV0_CC(i) < L_IGV_CC(i)   % IGV開度が下限値を下回った場合
            IGV0_CC(i) = L_IGV_CC(i); % IGV開度を下限値に固定
        else                          % IGV開度が上限値を上回った場合
            IGV0_CC(i) = U_IGV_CC(i); % IGV開度を上限値に固定
        end
        W0_cc  = IGV0_CC(i)*TIR_CC(i)/TI_CC(i);             % 空気流量
        xc0_cc = (PRC_CC(i)*W0_cc)^((RC_CC(i)-1)/RC_CC(i)); % 圧縮機出口温度算出時の変数
        xt0_cc = (PRT_CC(i)*W0_cc)^((RT_CC(i)-1)/RT_CC(i)); % 排ガス温度算出時の変数
        Td0_cc = TI_CC(i)*(1+(xc0_cc-1)/HC_CC(i));          % 圧縮機出口温度初期値[K]
        for iter = 1:iter_max
            Tf0_cc      = Td0_cc+(TFR_CC(i)-TDR_CC(i))*WF0_CC(i)/W0_cc;           % ガスタービン入口温度初期値
            TE0_CC(i)   = Tf0_cc*(1-(1-1/xt0_cc)*HT_CC(i));                       % 排ガス温度初期値
            Pmgt0_cc    = KGT_CC(i)*((Tf0_cc-TE0_CC(i))-(Td0_cc-TI_CC(i)))*W0_cc; % GT出力初期値
            PMST0_CC(i) = KST_CC(i)*TE0_CC(i)*W0_cc;                              % ST出力初期値
            Pm0_cc      = Pmgt0_cc+PMST0_CC(i);                                   % 軸出力初期値
            dPm_cc      = Pg_init_cc-Pm0_cc;                                      % 出力偏差
            if abs(dPm_cc) < e_cc
                break
            else
                WF0_CC(i)   = WF0_CC(i)+dPm_cc*k_cc;                              % 燃料流量の修正
            end
        end
    end
    if iter == iter_max
        error('初期値計算が収束しません。：GTCC_B');
    end
    % ===== 排ガス温度が設定値（燃料流量制御用）を上回った場合 =====
    Te_ref_cc = interp1(FX_TE1_CC(:,i), FY_TE1_CC(:,i), Pmgt0_cc/FGT_CC(i));  % 燃料流量制御用排ガス温度設定値
    if Te_ref_cc < TE0_CC(i)/TER_CC(i) % 排ガス温度が設定値を超過した場合
        for iter = 1:iter_max
            Tf0_cc      = Td0_cc+(TFR_CC(i)-TDR_CC(i))*WF0_CC(i)/W0_cc;                 % ガスタービン入口温度初期値
            TE0_CC(i)   = Tf0_cc*(1-(1-1/xt0_cc)*HT_CC(i));                             % 排ガス温度初期値
            Pmgt0_cc    = KGT_CC(i)*((Tf0_cc-TE0_CC(i))-(Td0_cc-TI_CC(i)))*W0_cc;       % GT出力初期値
            PMST0_CC(i) = KST_CC(i)*TE0_CC(i)*W0_cc;                                    % ST出力初期値
            Pm0_cc      = Pmgt0_cc+PMST0_CC(i);                                         % 軸出力初期値
            Te_ref_cc   = interp1(FX_TE1_CC(:,i), FY_TE1_CC(:,i), Pmgt0_cc/FGT_CC(i));  % 燃料流量制御用排ガス温度設定値
            dTe_cc      = Te_ref_cc-TE0_CC(i)/TER_CC(i);                                % 排ガス温度偏差
            if abs(dTe_cc) < e_cc
                break
            else
                WF0_CC(i)   = WF0_CC(i)+dTe_cc*k_cc;                                    % 燃料流量の修正
            end
        end
    end
    if iter == iter_max
        error('初期値計算が収束しません。：GTCC_C');
    end
end

FFCS0_CC = (WF0_CC-WF_MIN_CC)./(1.0-WF_MIN_CC); % 燃料制御信号初期値
