
% データセット作成(初回のみ，2回目以降は50～54行目)
file0='E:\03_結果\1month_PV_LFC_parameter';
%%% 格納用配列 Date_Set %%%
% Date_Set.EAO=[];
% Date_Set.RAO=[];
% Date_Set.DEM=[];
% Date_Set.PVO=[];
Date_Set.DEMF=[];
Date_Set.PVOF=[];
Date_Set.NEER=[];
Date_Set.RESUSE=[];
Date_Set.RESSEC=[];
Date_Set.DF=[];
rate_min
for lfc = 10
    file_lfc=['_LFC_',num2str(lfc)];
    for PVC = 820:410*2:3280
        file_PVC=['PVC_',num2str(PVC)];
        for dd = 1:31
            %%% データの読み込み %%%
            file_dd=['_20185',num2str(dd),'.mat'];
            load(fullfile(file0,[file_PVC,file_lfc,file_dd]));
            %%% 変数変更 %%%
            edc_all_out=reshape(sum(EDC_Output'),[],1);
            real_all_out=reshape(sum([O1.data,O2.data,...
                O3.data,O4.data,C1.data,C2.data,C3.data,...
                C4.data,C5.data,C6.data,GTCC.data]'),[],1);
            demand=reshape(dp1.data-B.data,[],1);
            pv_out=reshape(P.data,[],1);
            demand_forecast=reshape((PVF+LOF)'-B.data,[],1);
            pv_forecast=reshape(PVF',[],1);
            net_error=reshape((demand_forecast+pv_forecast)-...
                (demand+pv_out),[],1);
            res_use=reshape(real_all_out-edc_all_out,[],1);          % 使用量（出力データ用）
            res_sec=reshape(sum(Rate_Min(1:11,1))-edc_all_out,[],1); % 確保量（入力データ用）
            dfout=reshape(f1.data,[],1);
            %%% データまとめ %%%
            % Date_Set.EAO=[Date_Set.EAO,edc_all_out];
            % Date_Set.RAO=[Date_Set.RAO,real_all_out];
            % Date_Set.DEM=[Date_Set.DEM,demand];
            % Date_Set.PVO=[Date_Set.PVO,pv_out];
            Date_Set.DEMF=[Date_Set.DEMF,demand_forecast];
            Date_Set.PVOF=[Date_Set.PVOF,pv_forecast];
            Date_Set.NEER=[Date_Set.NEER,net_error];
            Date_Set.RESUSE=[Date_Set.RESUSE,res_use];
            Date_Set.RESSEC=[Date_Set.RESSEC,res_sec];
            Date_Set.DF=[Date_Set.DF,dfout];
        end
    end
end
data1_2018=Date_Set.DEMF;
data2_2018=Date_Set.PVOF;
data3_2018=Date_Set.NEER;
data4_2018=Date_Set.RESUSE;
data5_2018=Date_Set.RESSEC;
data6_2018=Date_Set.DF;