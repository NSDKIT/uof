% -- 時間断面指定 --
    hour = 50;
% -- LFC容量指定 --
	lfc=8;
    lfc=lfc/100;
% -- 予測PV出力，予測需要の読み込み (hour×1 行列) --
    load('../../PVF_30min.mat') % PVF_30min
    load('../../demand_30min.mat') % demand_30min
% -- 定格出力，最小出力の読み込み --
    rate_min
% -- 燃料費係数(a,b,c)の読み込み --
    get_abc
    a_k=abc(:,1);b_k=abc(:,2);c_k=abc(:,3);
    cost_kWh=abc(:,4);
% -- on-time --
    ON_time = 4;OFF_time = 4;
    gen_on = ON_time*ones(1,11); % 1断面: 30分 (ex:1.5時間: 3断面)
    gen_off = OFF_time*ones(1,11); % 1断面: 30分 (ex:1.5時間: 3断面)

    % %% 応急処置
    % gen_on(6)=3;