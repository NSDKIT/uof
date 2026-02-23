%% 実際の予測誤差を算出
% 対象データ読み込み
load('..\..\..\予測PV出力作成\PVF_30min.mat')
PVF_30min=PVF_30min(1:48);
% EDC
    % 予測PV出力の幅番号
    col=0;
    N_gen=11;
    PV_r=PVC/N_gen;
    PVF_r_low=-PV_r;
    PVF_30min_n=zeros(size(PVF_30min));
    for n=PV_r:PV_r:PVC
        col=col+1;
        PVF_r_low=PVF_r_low+PV_r;
        PVF_r_up=PVF_r_low+PV_r;

        PVF5min_oxl=PVF_30min>=PVF_r_low;
        PVF5min_oxu=PVF_30min<PVF_r_up;

        PVF_30min_n=PVF_30min_n+(PVF5min_oxl.*PVF5min_oxu)*col;
    end

    EDCp_1sigma_plus=[];EDCp_2sigma_plus=[];EDCp_3sigma_plus=[];
    EDCp_1sigma_minus=[];EDCp_2sigma_minus=[];EDCp_3sigma_minus=[];
    for t = T_R
        EDCp_1sigma_plus=[EDCp_1sigma_plus,EDC_sigma1_plus(t,PVF_30min_n(t))];
        EDCp_2sigma_plus=[EDCp_2sigma_plus,EDC_sigma2_plus(t,PVF_30min_n(t))];
        EDCp_3sigma_plus=[EDCp_3sigma_plus,EDC_sigma3_plus(t,PVF_30min_n(t))];
        
        EDCp_1sigma_minus=[EDCp_1sigma_minus,EDC_sigma1_minus(t,PVF_30min_n(t))];
        EDCp_2sigma_minus=[EDCp_2sigma_minus,EDC_sigma2_minus(t,PVF_30min_n(t))];
        EDCp_3sigma_minus=[EDCp_3sigma_minus,EDC_sigma3_minus(t,PVF_30min_n(t))];
    end

%     EDCp_1sigma_plus=EDCp_1sigma_plus.*(PVF_30min>0.5)';
%     EDCp_2sigma_plus=EDCp_2sigma_plus.*(PVF_30min>0.5)';
%     EDCp_3sigma_plus=EDCp_3sigma_plus.*(PVF_30min>0.5)';
%     
%     EDCp_1sigma_minus=EDCp_1sigma_minus.*(PVF_30min>0.5)';
%     EDCp_2sigma_minus=EDCp_2sigma_minus.*(PVF_30min>0.5)';
%     EDCp_3sigma_minus=EDCp_3sigma_minus.*(PVF_30min>0.5)';

% LFC
    % 予測PV出力の幅番号
    col=0;
    N_gen=5;
    PV_r=PVC/N_gen;
    PVF_r_low=-PV_r;
    PVF_30min_n=zeros(size(PVF_30min));
    for n=PV_r:PV_r:PVC
        col=col+1;
        PVF_r_low=PVF_r_low+PV_r;
        PVF_r_up=PVF_r_low+PV_r;

        PVF5min_oxl=PVF_30min>=PVF_r_low;
        PVF5min_oxu=PVF_30min<PVF_r_up;

        PVF_30min_n=PVF_30min_n+(PVF5min_oxl.*PVF5min_oxu)*col;
    end

    % LFC調整力算出
    LFC5p_1sigma_up=[];LFC5p_2sigma_up=[];LFC5p_3sigma_up=[];
    LFC5p_1sigma_down=[];LFC5p_2sigma_down=[];LFC5p_3sigma_down=[];
    for t = T_R
        LFC5p_1sigma_up=[LFC5p_1sigma_up,LFC5_sigma1_up(t,PVF_30min_n(t))];
        LFC5p_2sigma_up=[LFC5p_2sigma_up,LFC5_sigma2_up(t,PVF_30min_n(t))];
        LFC5p_3sigma_up=[LFC5p_3sigma_up,LFC5_sigma3_up(t,PVF_30min_n(t))];
        
        LFC5p_1sigma_down=[LFC5p_1sigma_down,LFC5_sigma1_down(t,PVF_30min_n(t))];
        LFC5p_2sigma_down=[LFC5p_2sigma_down,LFC5_sigma2_down(t,PVF_30min_n(t))];
        LFC5p_3sigma_down=[LFC5p_3sigma_down,LFC5_sigma3_down(t,PVF_30min_n(t))];
    end

% 評価
load('sigma.mat')
if sigma == 1
    EDC_reserved_plus=EDCp_1sigma_plus;EDC_reserved_plus=[EDC_reserved_plus,EDC_reserved_plus(end)*ones(1,2)];EDC_reserved_plus(find(EDC_reserved_plus<0))=0;
    EDC_reserved_minus=EDCp_1sigma_minus;EDC_reserved_minus=[EDC_reserved_minus,EDC_reserved_minus(end)*ones(1,2)];EDC_reserved_minus(find(EDC_reserved_minus<0))=0;
    LFC_reserved_up=LFC5p_1sigma_up;LFC_reserved_up=[LFC_reserved_up,LFC_reserved_up(end)*ones(1,2)];LFC_reserved_up(find(LFC_reserved_up<0))=0;
    LFC_reserved_down=LFC5p_1sigma_down;LFC_reserved_down=[LFC_reserved_down,LFC_reserved_down(end)*ones(1,2)];LFC_reserved_down(find(LFC_reserved_down<0))=0;
elseif sigma == 2
    EDC_reserved_plus=EDCp_2sigma_plus;EDC_reserved_plus=[EDC_reserved_plus,EDC_reserved_plus(end)*ones(1,2)];EDC_reserved_plus(find(EDC_reserved_plus<0))=0;
    EDC_reserved_minus=EDCp_2sigma_minus;EDC_reserved_minus=[EDC_reserved_minus,EDC_reserved_minus(end)*ones(1,2)];EDC_reserved_minus(find(EDC_reserved_minus<0))=0;
    LFC_reserved_up=LFC5p_2sigma_up;LFC_reserved_up=[LFC_reserved_up,LFC_reserved_up(end)*ones(1,2)];LFC_reserved_up(find(LFC_reserved_up<0))=0;
    LFC_reserved_down=LFC5p_2sigma_down;LFC_reserved_down=[LFC_reserved_down,LFC_reserved_down(end)*ones(1,2)];LFC_reserved_down(find(LFC_reserved_down<0))=0;
elseif sigma == 3
    EDC_reserved_plus=EDCp_3sigma_plus;EDC_reserved_plus=[EDC_reserved_plus,EDC_reserved_plus(end)*ones(1,2)];EDC_reserved_plus(find(EDC_reserved_plus<0))=0;
    EDC_reserved_minus=EDCp_3sigma_minus;EDC_reserved_minus=[EDC_reserved_minus,EDC_reserved_minus(end)*ones(1,2)];EDC_reserved_minus(find(EDC_reserved_minus<0))=0;
    LFC_reserved_up=LFC5p_3sigma_up;LFC_reserved_up=[LFC_reserved_up,LFC_reserved_up(end)*ones(1,2)];LFC_reserved_up(find(LFC_reserved_up<0))=0;
    LFC_reserved_down=LFC5p_3sigma_down;LFC_reserved_down=[LFC_reserved_down,LFC_reserved_down(end)*ones(1,2)];LFC_reserved_down(find(LFC_reserved_down<0))=0;
end