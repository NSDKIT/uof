clear
%% 1秒値からサンプリングで各時刻断面のモデル作成
%% データセット作成(初回のみ，2回目以降は50～54行目)
file0='F:\NSD_results';
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
% for lfc = 1:10
%     file_lfc=['_LFC_',num2str(lfc)];
    for PVC = 5100
        file_PVC=['Sigma_1_LFC_8_PVcapacity_',num2str(PVC)];
        for dd = 1:29 % 学習：1-28日，評価：29,30日
            %%% データの読み込み %%%
            file_dd=['_20196',num2str(dd),'.mat'];
            load(fullfile(file0,[file_PVC,file_dd]));
            PV_real=PV_real_Output(2,:);
            %%% 変数変更 %%%
            out_row=size(dfout,1);
            if out_row==86401
                out=0;
            else
                out=1;
            end
                %%% 予備力確保量 %%%
                res_sec=sum(Reserved_power(1:49,[1,3])');
                res_sec=reshape(res_sec.*ones(1800,49),[],1);
                res_sec=res_sec(1:86401);
                %%% 予備力利用量 %%%
                uc_out=reshape(sum(G_Out_UC(1:86401,[1:4,6:11,18])'),[],1);
                real_all_out=reshape(sum([Oil_Output,Coal_Output,Combine_Output]'),[],1);
                rao(1:86401)=nan;
                rao(1:size(real_all_out,1))=real_all_out;
                real_all_out=reshape(rao,[],1);
                res_use=real_all_out-uc_out;
                %%% 残余需要誤差 %%%
                pv_cur=reshape(interp1(1:49,PV_CUR(1:49)',1+1/1800:1/1800:50),[],1);
                pv_cur=pv_cur(1:86401);
                demand=reshape(load_input,[],1);
                pv_out=reshape(PV_Out,[],1);
                demand_forecast=reshape((PVF+LOF),[],1);
                pv_forecast=reshape(PVF-pv_cur',[],1);
                net_error=reshape((demand_forecast+pv_forecast)-...
                    (demand+pv_out),[],1);
                %%% 周波数偏差 %%%
                df(1:86401)=nan;
                df(1:size(dfout,1))=dfout;
                dfout=reshape(df,[],1);

                if out == 1
                    demand_forecast(out_row+1:end)=nan;
                    pv_forecast(out_row+1:end)=nan;
                    net_error(out_row+1:end)=nan;
                    res_use(out_row+1:end)=nan;
                    res_sec(out_row+1:end)=nan;
                    dfout(out_row+1:end)=nan;
                end
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
% end
% % %% 周波数偏差と相関性調査（発展形：モデル3）
% % figure,plot(reshape(Date_Set.RESSEC,[],1),reshape(Date_Set.DF,[],1),'ko')
% % figure,plot(reshape(Date_Set.RESUSE,[],1),reshape(Date_Set.DF,[],1),'ko')
% % figure,plot(reshape(Date_Set.RESUSE./Date_Set.RESSEC,[],1),reshape(Date_Set.DF,[],1),'ko')
% 
% %% 学習
% data1=Date_Set.DEMF;
% data2=Date_Set.PVOF;
% data3=Date_Set.NEER;
% data4=Date_Set.RESUSE;
% data5=Date_Set.RESSEC;
% data6=Date_Set.DF;
% 
% get_201805_data
% 
% data1=[data1,data1_2018];
% data2=[data2,data2_2018];
% data3=[data3,data3_2018];
% data4=[data4,data4_2018];
% data5=[data5,data5_2018];
% data6=[data6,data6_2018];
% 
% save data1.mat data1;save data2.mat data2;save data3.mat data3;
% save data4.mat data4;save data5.mat data5;save data6.mat data6;

load('data1.mat');data1=reshape(data1(:,1:84),1,[]);
load('data2.mat');data2=reshape(data2(:,1:84),1,[]);
load('data3.mat');data3=reshape(data3(:,1:84),1,[]);
load('data4.mat');data4=reshape(data4(:,1:84),1,[]);
load('data5.mat');data5=reshape(data5(:,1:84),1,[]);
load('data6.mat');data6=reshape(data6(:,1:84),1,[]);

% 周波数の外れ値除去処理：-0.5Hz以下,0.5Hz以上を外れ値として検出
outliers = find(abs(data6)>.5);
% 外れ値の置き換え
data1(outliers)=nan;
data2(outliers)=nan;
data3(outliers)=nan;
data4(outliers)=nan;
data5(outliers)=nan;
data6(outliers)=nan;
% 正規化処理
% [data1,ds1] = mapminmax(data1);
% [data2,ds2] = mapminmax(data2);
% [data3,ds3] = mapminmax(data3);
% [data4,ds4] = mapminmax(data4);
% [data5,ds5] = mapminmax(data5);
% save('ガウス過程回帰モデル\ds.mat','ds1','ds2','ds3','ds4','ds5')
% 行列の整理
data1=reshape(data1,86401,size(data1,2)/86401);
data2=reshape(data2,86401,size(data2,2)/86401);
data3=reshape(data3,86401,size(data3,2)/86401);
data4=reshape(data4,86401,size(data4,2)/86401);
data5=reshape(data5,86401,size(data5,2)/86401);
data6=reshape(data6,86401,size(data6,2)/86401);

Date_Set.DEMF=data1;
Date_Set.PVOF=data2;
Date_Set.NEER=data3;
Date_Set.LFCUSE=data4;
Date_Set.RESSEC=data5;
Date_Set.DF=data6;
clear data1 data2 data3 data4 data5 data6
%% 時刻断面毎に解析
T=1800;
load('MSM_X.mat')
for t = 1:48
    if t == 24
        1;
    end
    %%% 説明可能でないAIの場合 %%%
    % X1=reshape(X(:,1),86401,[]);X1=[reshape(X1(T*(t-1)+1:T*t,:),[],1);reshape(X1(T*(t-1)+1:T*t,:),[],1);reshape(X1(T*(t-1)+1:T*t,:),[],1)];
    X2=reshape(X(:,2),86401,[]);X2=[reshape(X2(T*(t-1)+1:T*t,:),[],1);reshape(X2(T*(t-1)+1:T*t,:),[],1);reshape(X2(T*(t-1)+1:T*t,:),[],1)];
    X3=reshape(X(:,3),86401,[]);X3=[reshape(X3(T*(t-1)+1:T*t,:),[],1);reshape(X3(T*(t-1)+1:T*t,:),[],1);reshape(X3(T*(t-1)+1:T*t,:),[],1)];
    X4=reshape(X(:,4),86401,[]);X4=[reshape(X4(T*(t-1)+1:T*t,:),[],1);reshape(X4(T*(t-1)+1:T*t,:),[],1);reshape(X4(T*(t-1)+1:T*t,:),[],1)];
    X5=reshape(X(:,5),86401,[]);X5=[reshape(X5(T*(t-1)+1:T*t,:),[],1);reshape(X5(T*(t-1)+1:T*t,:),[],1);reshape(X5(T*(t-1)+1:T*t,:),[],1)];
    X6=reshape(X(:,6),86401,[]);X6=[reshape(X6(T*(t-1)+1:T*t,:),[],1);reshape(X6(T*(t-1)+1:T*t,:),[],1);reshape(X6(T*(t-1)+1:T*t,:),[],1)];
ccc    % X7=reshape(X(:,7),86401,[]);X7=[reshape(X7(T*(t-1)+1:T*t,:),[],1);reshape(X7(T*(t-1)+1:T*t,:),[],1);reshape(X7(T*(t-1)+1:T*t,:),[],1)];
    % X8=reshape(X(:,8),86401,[]);X8=[reshape(X8(T*(t-1)+1:T*t,:),[],1);reshape(X8(T*(t-1)+1:T*t,:),[],1);reshape(X8(T*(t-1)+1:T*t,:),[],1)];
    % X9=reshape(X(:,9),86401,[]);X9=[reshape(X9(T*(t-1)+1:T*t,:),[],1);reshape(X9(T*(t-1)+1:T*t,:),[],1);reshape(X9(T*(t-1)+1:T*t,:),[],1)];
    X10=reshape(X(:,10),86401,[]);X10=[reshape(X10(T*(t-1)+1:T*t,:),[],1);reshape(X10(T*(t-1)+1:T*t,:),[],1);reshape(X10(T*(t-1)+1:T*t,:),[],1)];
    X11=reshape(X(:,11),86401,[]);X11=[reshape(X11(T*(t-1)+1:T*t,:),[],1);reshape(X11(T*(t-1)+1:T*t,:),[],1);reshape(X11(T*(t-1)+1:T*t,:),[],1)];
    % X12=reshape(X(:,12),86401,[]);X12=[reshape(X12(T*(t-1)+1:T*t,:),[],1);reshape(X12(T*(t-1)+1:T*t,:),[],1);reshape(X12(T*(t-1)+1:T*t,:),[],1)];

    %%% 対象時刻断面でのデータ抽出
    DEMF=reshape(Date_Set.DEMF(T*(t-1)+1:T*t,:),[],1);
    PVOF=reshape(Date_Set.PVOF(T*(t-1)+1:T*t,:),[],1);
    NEER=reshape(Date_Set.NEER(T*(t-1)+1:T*t,:),[],1);
    LFCUSE=reshape(Date_Set.LFCUSE(T*(t-1)+1:T*t,:),[],1);
    RESSEC=reshape(Date_Set.RESSEC(T*(t-1)+1:T*t,:),[],1);
    DF=reshape(Date_Set.DF(T*(t-1)+1:T*t,:),[],1);

    DEMF(isnan(DEMF))=[];
    PVOF(isnan(PVOF))=[];
    NEER(isnan(NEER))=[];
    LFCUSE(isnan(LFCUSE))=[];
    RESSEC(isnan(RESSEC))=[];
    DF(isnan(DF))=[];
    
    %%% 学習時の計算負荷緩和のために，10000個の一様ランダムなサンプルで抽出
    nn = 10^4; % サンプル数を指定
    min_value = 1;
    max_value = size(DF,1);
    samples = randi([min_value, max_value], 1, nn);
    
    DEMF=DEMF(samples);
    PVOF=PVOF(samples);
    NEER=NEER(samples);
    LFCUSE=LFCUSE(samples);
    RESSEC=RESSEC(samples);
    DF=DF(samples);
    % X1=X1(samples);
    X2=X2(samples);
    X3=X3(samples);
    X4=X4(samples);
    X5=X5(samples);
    X6=X6(samples);
    % X7=X7(samples);
    % X8=X8(samples);
    % X9=X9(samples);
    X10=X10(samples);
    X11=X11(samples);
    % X12=X12(samples);
    
    %%% データの結合 %%%
    % DATA=array2table([DEMF,PVOF,NEER,LFCUSE,RESSEC,DF],...
    %     'VariableNames',{'DEMF','PVOF','NEER','RESUSE','RESSEC','DF'});

    DATA=array2table([X3,X4,X5,X6,X10,LFCUSE],...
        'VariableNames',{'X3','X4','X5','X6','X10','RESUSE'});
    
    %% 学習save
        % %%% モデル1 : 間接型(残余需要の予測誤差を学習)
        % gprMdl = fitrgp([DATA(:,1:2),DATA(:,3)],'NEER','KernelFunction','exponential');
        % save(['ガウス過程回帰モデル\Mdl1\',num2str(t),'.mat'],'gprMdl')
        %%% モデル2 : 直接型(所要LFC容量を学習)
        gprMdl = fitrgp(DATA,'RESUSE','KernelFunction','exponential','Standardize',true);
        % gprMdl = fitrgp([DATA(:,1:2),DATA(:,4)],'RESUSE','KernelFunction','exponential');
        save(['ガウス過程回帰モデル\Mdl2\',num2str(t),'.mat'],'gprMdl')
        % %%% モデル3 : 間接型(確保LFC容量に対する周波数偏差を学習)
        % gprMdl = fitrgp([DATA(:,1:2),DATA(:,4:6)],'DF','KernelFunction','exponential');
        % save(['ガウス過程回帰モデル\Mdl3\',num2str(t),'.mat'],'gprMdl')
end