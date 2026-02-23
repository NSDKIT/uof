y=2019;mode=1;
for PVC=[3200,4040,6980]
    %% 既設PV容量
    load(['基本データ/PV_base_',num2str(y),'.mat'])
    PV_base=[PV_base(end-2:end,3)',PV_base(1:end-3,3)'];
    %% システム出力係数
    load(['基本データ/PR_',num2str(y),'.mat'])
    %% MSMの倍数係数
    load(['基本データ/MSM_bai_',num2str(y),'.mat'])
    %% 日射量の抽出
    load('基本データ/D_1sec.mat')
    demand_1sec=D_1sec(:,1:86401);

    load('基本データ/irr_mea_data.mat')
    n_l=[1,mode];
    
    PV_1sec_al=irr_mea_data(:,n_l(1))*0.8*1000/1000;
    PV_1sec_new=irr_mea_data(:,n_l(2))*0.8*1000/1000;
    PV_al=1100;
    PV_1sec=PV_1sec_al*PV_al/PV_base(month_l)+PV_1sec_new*(PVC-PV_al)/PV_base(month_l);
end