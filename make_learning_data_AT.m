clear
%% SHAP値での重要度解析で用いた時と同一のモデル
T=60*30;d_T=86400/T;
opt_var=1;eval_day_range=28;D_R=[1:22,24:29];
PV_R=5100;
t_s=0;target_time=t_s*(d_T/24)+1:(24-t_s)*(d_T/24);
%% データセット作成(初回のみ，2回目以降は50～54行目)
file0='F:\NSD_results';
%%% 格納用配列 Date_Set %%%
Date_Set.DEMF=[];
Date_Set.PVOF=[];
Date_Set.NEER=[];
Date_Set.RESUSE=[];
Date_Set.RESSEC=[];
Date_Set.DF=[];
rate_min
load('MSM_X.mat')
MSM_ALL=[];
for PVC = PV_R
    file_PVC=['Sigma_1_LFC_8_PVcapacity_',num2str(PVC)];
    for dd = D_R % 学習・評価：1-29日（23日は周波数が過渡反応しているため除去），テスト：30日
        t_range=86401*(dd-1)+1:86400*dd;
        MSM_ALL=[MSM_ALL;X(t_range,:)];
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
            res_sec=res_sec(1:86400);
            %%% 予備力利用量 %%%
            uc_out=reshape(sum(G_Out_UC(1:86400,[1:4,6:11,18])'),[],1);
            real_all_out=reshape(sum([Oil_Output,Coal_Output,Combine_Output]'),[],1);
            rao(1:86401)=nan;
            rao(1:size(real_all_out,1))=real_all_out;
            real_all_out=reshape(rao(1:86400),[],1);
            res_use=real_all_out-uc_out;
            %%% 残余需要誤差 %%%
            pv_cur=reshape(interp1(1:49,PV_CUR(1:49)',1+1/1800:1/1800:50),[],1);
            pv_cur=pv_cur(1:86401);
            demand=reshape(load_input,[],1);
            pv_out=reshape(PV_Out,[],1);
            demand_forecast=reshape((PVF+LOF),[],1);
            pv_forecast=reshape(PVF-pv_cur',[],1);
            net_error=reshape((demand_forecast-pv_forecast)-...
                (demand-pv_out),[],1);
            net_error=net_error(1:86400);
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
            dfout(end)=[];
            demand_forecast(end)=[];
            pv_forecast(end)=[];
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
data1=Date_Set.DEMF;
data2=Date_Set.PVOF;
data3=Date_Set.NEER;
data4=Date_Set.RESUSE;
data5=Date_Set.RESSEC;
data6=Date_Set.DF;

data1=reshape(data1,1,[]);
data2=reshape(data2,1,[]);
data3=reshape(data3,1,[]);
data4=reshape(data4,1,[]);
data5=reshape(data5,1,[]);
data6=reshape(data6,1,[]);

% 1時間値に変更
data1=data1(1:T:end);
data2=data2(1:T:end);
data3=data3(1:T:end);
get_max_lfcuse
data4=max_values;
% data4=data4(1:T:end);
data5=data5(1:T:end);
data6=data6(1:T:end);

Date_Set.DEMF=data1;
Date_Set.PVOF=data2;
Date_Set.NEER=data3;
Date_Set.LFCUSE=data4;
Date_Set.RESSEC=data5;
Date_Set.DF=data6;
clear data1 data2 data3 data4 data5 data6
%% 時刻断面毎に解析
X_t=1:height(MSM_ALL);
X_t(86401:86401:end)=[];
X=MSM_ALL(X_t,:);
X=X(1:T:end,:);

%% 
shapvalue_all = []; 
d_t=48; % 1時間値でも5分値でも，height(X)の長さが変わるだけで，1日毎の刻みは48で不変
for t = 1
    % t_x=[t:d_t:height(X)];
    t_x=1:height(X);
    % t_x=[t:d_t:height(X),t+1:d_t:height(X),...
    %     t+2:d_t:height(X),t+3:d_t:height(X),...
    %     t+4:d_t:height(X),t+5:d_t:height(X)];
    %% 訓練データ
    %%% 気象予測値 %%%
    X1=reshape(X(t_x,1),[],1);
    X2=reshape(X(t_x,2),[],1);
    X3=reshape(X(t_x,3),[],1);
    X4=reshape(X(t_x,4),[],1);
    X5=reshape(X(t_x,5),[],1);
    X6=reshape(X(t_x,6),[],1);
    X7=reshape(X(t_x,7),[],1);
    X8=reshape(X(t_x,8),[],1);
    X9=reshape(X(t_x,9),[],1);
    X10=reshape(X(t_x,10),[],1);
    X11=reshape(X(t_x,11),[],1);
    X12=reshape(X(t_x,12),[],1);

    %%% 需要予測値，PV予測値，所要調整力 %%%
    DEMF=reshape(Date_Set.DEMF(t_x),[],1);
    PVOF=reshape(Date_Set.PVOF(t_x),[],1);
    NEER=reshape(Date_Set.NEER(t_x),[],1);
    LFCUSE=reshape(Date_Set.LFCUSE(t_x),[],1);
    RESSEC=reshape(Date_Set.RESSEC(t_x),[],1);
    DF=reshape(Date_Set.DF(t_x),[],1);

    %%% 検証データ %%%
    total_rows=height(DEMF)/size(PV_R,2);
    nn = 1-(total_rows / size(D_R,2)) * eval_day_range / total_rows  ; % サンプル数を指定
    samples_train = 1:total_rows*nn;
    for i = 1:size(PV_R,2)-1
        samples_train(i+1,:)=samples_train(i,:)+total_rows;
    end
    samples_train=reshape(samples_train,1,[]);
    
    DEMF_train=DEMF(samples_train);PVOF_train=PVOF(samples_train);
    NEER_train=NEER(samples_train);LFCUSE_train=LFCUSE(samples_train);
    X1_train=X1(samples_train);X2_train=X2(samples_train);
    X3_train=X3(samples_train);X4_train=X4(samples_train);
    X5_train=X5(samples_train);X6_train=X6(samples_train);
    X7_train=X7(samples_train);X8_train=X8(samples_train);
    X9_train=X9(samples_train);X10_train=X10(samples_train);
    X11_train=X11(samples_train);X12_train=X12(samples_train);
    %% 学習
    if opt_var == 1
        opt_data=LFCUSE_train;
    elseif opt_var == 2
        opt_data=NEER_train;
    end
    opt_data(find(opt_data<0))=0;
    % DATA=array2table([PVOF_train,X10_train,opt_data],...
    %     'VariableNames',{'PVOF','X10','RESUSE'});
    % DATA=array2table([DEMF_train,PVOF_train,opt_data],...
    %     'VariableNames',{'DEMF_train','PVOF_train','RESUSE'});
    DATA=array2table([DEMF_train,PVOF_train,...
        X2_train,X3_train,X4_train,X5_train,...
        X6_train,X10_train,...
        X11_train,opt_data],...
        'VariableNames',{'DEMF_train','PVOF_train',...
        'X2_train','X3_train','X4_train','X5_train',...
        'X6_train','X10_train',...
        'X11_train','RESUSE'});
    gprMdl = fitrgp(DATA,'RESUSE','KernelFunction','exponential','Standardize',true);
    save(['ガウス過程回帰モデル\Mdl2\',num2str(t),'.mat'],'gprMdl')
end