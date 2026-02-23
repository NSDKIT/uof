clear;close all
load('../../../method')
if meth == 1
    load('../../../予測PV出力作成/PVF_30min.mat')
    load('../../../需要実績・予測作成/demand_30min.mat')
    
    EDC_reserved_plus=demand_30min'*5/100;
    LFC_reserved_up=demand_30min'*3/100;
else
    load('../../../mode')
    load('../../../PVC')
    mode_act=mode;
    all_data.EDC_5min = 0;
    all_data.edc_5min = 0;
    all_data.LFC_5min_up = 0;
    all_data.LFC_5min_down = 0; 
    all_data.lfc_1min =0;
    all_data.PV_f = 0;

    DRY=0;
    DY=0;
    PV_FYL=0;
    PV_FY=0;
    PV_OUT=0;
    for m_n = 1:2
        if m_n==1
            % 既設PV(＝片面南)でのデータ
            mode=1;
            k=1100/1100;
        elseif m_n==2
            % 導入PVでのデータ
            mode=mode_act;
            k=(PVC-1100)/1100;
        end
        stage0 % データ作成
        DRY=DRY+Demand_real_year;
        DY=DY+Demand_year;
        PV_FYL=PV_FYL+PV_forecast_year_line;
        PV_FY=PV_FY+PV_forecast_year;
        PV_OUT=PV_OUT+PV_Out;
    end

    Demand_real_year=DRY/2;
    Demand_year=DY/2;
    PV_forecast_year_line=PV_FYL;
    PV_forecast_year=PV_FY;
    PV_Out=PV_OUT;
    stage1
    clearvars -except meth Demand_real_year all_data mode_act EDC_5min edc_5min LFC_5min_up LFC_5min_down lfc_1min PV_f PV_Out mode ND_1min ND_5min PVC
    all_data.EDC_5min = all_data.EDC_5min+EDC_5min;
    all_data.edc_5min = all_data.edc_5min+edc_5min;
    all_data.LFC_5min_up = all_data.LFC_5min_up+LFC_5min_up;
    all_data.LFC_5min_down = all_data.LFC_5min_down+LFC_5min_down; 
    all_data.lfc_1min = all_data.lfc_1min+lfc_1min;
    all_data.PV_f = all_data.PV_f+PV_f;
    %     all_data.PV_Out 
    %     all_data.ND_1min 
    %     all_data.ND_5min 
    clearvars -except Demand_real_year all_data PVC meth lfc_1min
    EDC_5min=all_data.EDC_5min;
    edc_5min=all_data.edc_5min;
    LFC_5min_up=all_data.LFC_5min_up;
    LFC_5min_down=all_data.LFC_5min_down; 
    lfc_1min=all_data.lfc_1min;
    PV_f=all_data.PV_f;

    LFC_time_day=reshape(lfc_1min,[86400,size(lfc_1min,1)/86400]);
    if meth == 2
        make_EDC_year
        make_LFC_year
        caluculate_EDC_LFC_year
    elseif meth == 3
        stage2
        make_sigma_EDC
        make_sigma_LFC
        %% 統計解析
        calculate_EDC_LFC
    end
end