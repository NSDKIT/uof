%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% init_vahydros.m  可変速揚水発電機モデルの初期値計算
% 【このプログラムで実施すること】
%　・可変速揚水発電機モデルの初期値計算
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% 可変速揚水発電機モデルの初期値計算

for i=1:length(TY_VA) % 複数機対応

    % 有効電力指令初期値を発電計画値へ
    PG_INIT_VA(i) = PMWD_EDC0(1,30) / GMW_VA(i); % 有効電力指令（発電・揚水サブシステム内ではPU値）
    
    % 運転モード（発電計画値の正負）に応じた有効電力指令の初期値範囲制約
    
    if (PMWD_EDC0(1,30) >= 0) % 発電運転
        PG_INIT_VA(i) = max(PG_INIT_VA(i), L_MWD_GN_VA(i));
        PG_INIT_VA(i) = min(PG_INIT_VA(i), U_MWD_GN_VA(i));
    else %揚水運転
        PG_INIT_VA(i) = max(PG_INIT_VA(i), L_MWD_PM_VA(i));
        PG_INIT_VA(i) = min(PG_INIT_VA(i), U_MWD_PM_VA(i));
    end
    
    % 発電運転モデル初期値
    
    N_GN_INIT_VA(i) = interp1(FX_N_GN_VA, FY_N_GN_VA, PG_INIT_VA(i), 'linear', 'extrap');
    Y_GN_INIT_VA(i) = interp1(FX_Y_GN_VA, FY_Y_GN_VA, PG_INIT_VA(i), 'linear', 'extrap');
    
    % 揚水運転

    N_PM_INIT_VA(i) = interp1(FX_N_PM_VA, FY_N_PM_VA, PG_INIT_VA(i), 'linear', 'extrap');
    Y_PM_INIT_VA(i) = interp1(FX_Y_PM_VA, FY_Y_PM_VA, PG_INIT_VA(i), 'linear', 'extrap');
    
end

clear i
