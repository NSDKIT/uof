clear
T=60*30;d_T=86400/T;
opt_var=1;eval_day_range=7;
step = 2; % 1: 重要度解析のためのモデル構築， 2: XAIのためのモデル構築

PV_R=5500;

t_s=0;
target_time=t_s*(d_T/24)+1:(24-t_s)*(d_T/24);

year  = 2019;
month = 12;

%% 学習期間
% month = 6  -> D_R = 1:29;
% month = 12 -> D_R = 1:31;
D_R   = 1:31;
%% データセット作成(初回のみ，2回目以降は50～54行目)
file0 = '学習データ（所要調整力）\12月';
%%% 格納用配列 Date_Set %%%
Date_Set.DEMF=[];
Date_Set.PVOF=[];
Date_Set.NEER=[];
Date_Set.RESUSE=[];
Date_Set.RESSEC=[];
Date_Set.DF=[];
rate_min
load('MSM_ALL.mat')
msm_all0 = [];

start_date = datetime(2019, 4, 1);
end_date = datetime(2020, 3, 31);
date_range = start_date:end_date;
date_strings = datestr(date_range, 'yyyymmdd');

YYYY = str2num(date_strings(:,1:4))==year;
MM   = str2num(date_strings(:,5:6))==month;

load('MSM_X.mat')

for PVC = PV_R
    file_PVC='PV_';
    for dd = D_R % 学習・評価：1-29日（23日は周波数が過渡反応しているため除去），テスト：30日
        DD   = str2num(date_strings(:,7:8))==dd;
        DN   = find(YYYY.*MM.*DD);

        msm_all0  = [msm_all0;MSM_ALL(24*(DN-1)+1:24*DN,5:end)];

        % % 6月のみ応急処置
        % msm_all0  = [msm_all0;X(86401*(dd-1)+1:3601:86401*dd,:)];


        % %%% データの読み込み %%%
        % file_dd=[num2str(year),num2str(month),num2str(dd),'.mat'];
        % load(fullfile(file0,[file_PVC,file_dd]));
        % 
        % % PV_real=PV_real_Output(2,:);
        % %%% 変数変更 %%%
        % out_row=size(dfout,1);
        % if out_row==86401
        %     out=0;
        % else
        %     out=1;
        % end
        %     %%% 予備力確保量 %%%
        %     res_sec=sum(Reserved_power(1:49,[1,3])');
        %     res_sec=reshape(res_sec.*ones(1800,49),[],1);
        %     res_sec=res_sec(1:86400);
        %     %%% 予備力利用量 %%%
        %     uc_out=reshape(sum(G_Out_UC(1:86400,[1:4,6:11,18])'),[],1);
        %     real_all_out=reshape(sum([Oil_Output,Coal_Output,Combine_Output]'),[],1);
        %     rao(1:86401)=nan;
        %     rao(1:size(real_all_out,1))=real_all_out;
        %     real_all_out=reshape(rao(1:86400),[],1);
        %     res_use=real_all_out-uc_out;
        %     %%% 残余需要誤差 %%%
        %     pv_cur=reshape(interp1(1:49,PV_CUR(1:49)',1+1/1800:1/1800:50),[],1);
        %     pv_cur=pv_cur(1:86401);
        %     demand=reshape(load_input,[],1);
        %     pv_out=reshape(PV_Out,[],1);
        %     demand_forecast=reshape((PVF+LOF),[],1);
        %     pv_forecast=reshape(PVF-pv_cur',[],1);
        %     net_error=reshape((demand_forecast-pv_forecast)-...
        %         (demand-pv_out),[],1);
        %     net_error=net_error(1:86400);
        %     %%% 周波数偏差 %%%
        %     df(1:86401)=nan;
        %     df(1:size(dfout,1))=dfout;
        %     dfout=reshape(df,[],1);
        % 
        %     if out == 1
        %         demand_forecast(out_row+1:end)=nan;
        %         pv_forecast(out_row+1:end)=nan;
        %         net_error(out_row+1:end)=nan;
        %         res_use(out_row+1:end)=nan;
        %         res_sec(out_row+1:end)=nan;
        %         dfout(out_row+1:end)=nan;
        %     end
        %     dfout(end)=[];
        %     demand_forecast(end)=[];
        %     pv_forecast(end)=[];
        % %%% データまとめ %%%
        % % Date_Set.EAO=[Date_Set.EAO,edc_all_out];
        % % Date_Set.RAO=[Date_Set.RAO,real_all_out];
        % % Date_Set.DEM=[Date_Set.DEM,demand];
        % % Date_Set.PVO=[Date_Set.PVO,pv_out];
        % Date_Set.DEMF   = [Date_Set.DEMF,   demand_forecast];
        % Date_Set.PVOF   = [Date_Set.PVOF,   pv_forecast];
        % Date_Set.NEER   = [Date_Set.NEER,   net_error];
        % Date_Set.RESUSE = [Date_Set.RESUSE, res_use];
        % Date_Set.RESSEC = [Date_Set.RESSEC, res_sec];
        % Date_Set.DF     = [Date_Set.DF,     dfout];
    end
end



t = .5:.5:24;
MSM_ALL0 = zeros(2*size(msm_all0,1),size(msm_all0,2));
for element = 1:size(msm_all0,2)
    original_vector     = msm_all0(:,element)';
    x_original          = linspace(1, 24, size(msm_all0,1));
    x_interp            = linspace(1, 24, size(MSM_ALL0,1));
    MSM_ALL0(:,element) = interp1(x_original, original_vector, x_interp, 'linear');
end
MSM_ALL0(:,end+1) = reshape(ones(1,size(D_R,2)).*t',[],1);

% % load('alldata_allperiod.mat','Date_Set')
load('d.mat')
data1 = d1';
data2 = d2';
data4 = d4';

% data1=Date_Set.DEMF;
% data2=Date_Set.PVOF;
% data3=Date_Set.NEER;
% data4=Date_Set.RESUSE;
% data5=Date_Set.RESSEC;
% data6=Date_Set.DF;
% 
% data1=reshape(data1,1,[]);
% data2=reshape(data2,1,[]);
% data3=reshape(data3,1,[]);
% data4=reshape(data4,1,[]);
% data5=reshape(data5,1,[]);
% data6=reshape(data6,1,[]);
% 
% 1時間値に変更
data1 = data1(1:T:end);
data2 = data2(1:T:end);
% data3=data3(1:T:end);
get_max_lfcuse
data4 = max_values;
% data4=data4(1:T:end);
% data5=data5(1:T:end);
% data6=data6(1:T:end);

Date_Set.DEMF   = data1;
Date_Set.PVOF   = data2;
Date_Set.NEER   = 0; % data3
Date_Set.LFCUSE = data4;
Date_Set.RESSEC = 0; % data5
Date_Set.DF     = 0; % data6
clear data1 data2 data3 data4 data5 data6

%% 時刻断面毎に解析
% X_t = 1:height(msm_all0);
% X_t(86401:86401:end) = [];
% X = msm_all0(X_t,:);
X = MSM_ALL0;

%% 
shapvalue_all = []; 
d_t           = 48; % 1時間値でも5分値でも，height(X)の長さが変わるだけで，1日毎の刻みは48で不変
for t = 1
    % t_x=[t:d_t:height(X)];
    t_x = 1:height(X);
    % t_x=[t:d_t:height(X),t+1:d_t:height(X),...
    %     t+2:d_t:height(X),t+3:d_t:height(X),...
    %     t+4:d_t:height(X),t+5:d_t:height(X)];
    %% 訓練データ
    %%% 気象予測値 %%%
    X1  = reshape(X(t_x,1),[],1);
    X2  = reshape(X(t_x,2),[],1);
    X3  = reshape(X(t_x,3),[],1);
    X4  = reshape(X(t_x,4),[],1);
    X5  = reshape(X(t_x,5),[],1);
    X6  = reshape(X(t_x,6),[],1);
    X7  = reshape(X(t_x,7),[],1);
    X8  = reshape(X(t_x,8),[],1);
    X9  = reshape(X(t_x,9),[],1);
    X10 = reshape(X(t_x,10),[],1);
    X11 = reshape(X(t_x,11),[],1);
    X12 = reshape(X(t_x,12),[],1);

    X_t = reshape(X(t_x,13),[],1);

    %%% 需要予測値，PV予測値，所要調整力 %%%
    DEMF = reshape(Date_Set.DEMF(t_x),[],1);
    PVOF = reshape(Date_Set.PVOF(t_x),[],1);
    % NEER=reshape(Date_Set.NEER(t_x),[],1);
    LFCUSE = reshape(Date_Set.LFCUSE(t_x),[],1);
    % RESSEC=reshape(Date_Set.RESSEC(t_x),[],1);
    % DF=reshape(Date_Set.DF(t_x),[],1);

    %%% 訓練データ：7000個の一様ランダムなサンプルで抽出
    total_rows = height(DEMF)/size(PV_R,2);
    % nn = 1-(total_rows / size(D_R,2)) * eval_day_range / total_rows  ; % サンプル数を指定
    nn = 1;
    samples_train = 1:total_rows*nn;
    for i = 1:size(PV_R,2)-1
        samples_train(i+1,:) = samples_train(i,:)+total_rows;
    end
    samples_train = reshape(samples_train,1,[]);
    % samples_train = [samples_train(2:end),samples_train(1)];
    
    DEMF_train = DEMF(samples_train);
    PVOF_train = PVOF(samples_train);
    % NEER_train=NEER(samples_train);
    LFCUSE_train = LFCUSE(samples_train);
    X1_train  = X1(samples_train);
    X2_train  = X2(samples_train);
    X3_train  = X3(samples_train);
    X4_train  = X4(samples_train);
    X5_train  = X5(samples_train);
    X6_train  = X6(samples_train);
    X7_train  = X7(samples_train);
    X8_train  = X8(samples_train);
    X9_train  = X9(samples_train);
    X10_train = X10(samples_train);
    X11_train = X11(samples_train);
    X12_train = X12(samples_train);
    Xt_train  = X_t(samples_train);
    %% 学習
    if opt_var == 1
        opt_data=LFCUSE_train;
    elseif opt_var == 2
        opt_data=NEER_train;
    end
    opt_data(find(opt_data<0))=0;

    switch step
        case 1
            % 重要度分析のための学習。全てを説明変数とする
            DATA=array2table([DEMF_train,PVOF_train,X1_train,X2_train,X3_train,X4_train,...
                X5_train,X6_train,X7_train,X8_train,X9_train,X11_train,...
                opt_data],...
                'VariableNames',{'DEMF_train','PVOF_train','X1','X2','X3','X4','X5',...
                'X6','X7','X8','X9','X11','opt_data'});
        case 2
            X_t = reshape((.5:.5:24)'.*ones(1,29),[],1);
            load('mdl_December0.mat')
            % load('all.mat','DATA')
            DATA          = gprMdl.X;
            DATA.t        = X_t;
            DATA.opt_data = gprMdl.Y;

            DATA.DEMF_train = [];
            % DATA.PVOF_train = [];
            DATA.X1         = [];
            DATA.X2         = [];
            DATA.X3         = [];
            DATA.X4         = [];
            DATA.X5         = [];
            DATA.X6         = [];
            DATA.X7         = [];
            DATA.X8         = [];
            DATA.X9         = [];
            DATA.X11        = [];


            % % モデル構築のため，説明変数を絞る
            % DATA=array2table([DEMF_train,PVOF_train,X5_train,X7_train,X8_train,X9_train,opt_data],...
            %     'VariableNames',{'DEMF_train','PVOF_train','X5','X7','X8','X9','opt_data'});

            % DATA=array2table([DEMF_train,PVOF_train,X1_train,X2_train,X3_train,X4_train,...
            %     X5_train,X6_train,X7_train,X8_train,X9_train,X11_train,...
            %     opt_data],...
            %     'VariableNames',{'DEMF_train','PVOF_train','X1','X2','X3','X4','X5',...
            %     'X6','X7','X8','X9','X11','opt_data'});

    end
    mdl = fitrgp(DATA,'opt_data','KernelFunction','exponential','Standardize',true);

    switch step
        case 1
            %% 評価
        %%% 評価データ：3000個の一様ランダムなサンプルで抽出
        % 2つの行列を定義
        % matrix1 = t_x;matrix2 = samples_train;    
        % % 共通の要素を見つける
        % common_elements = intersect(matrix1,matrix2);
        % % 共通の要素を両方の行列から除外
        % samples_eval = setdiff(matrix1, common_elements);
        samples_eval = samples_train;
    
        % samples_eval = total_rows*nn+1:total_rows;
        
        DEMF_train   = DEMF(samples_eval);
        PVOF_train   = PVOF(samples_eval);
        LFCUSE_train = LFCUSE(samples_eval);
        % NEER_train=NEER(samples_eval);
        X1_train     = X1(samples_eval);
        X2_train     = X2(samples_eval);
        X3_train     = X3(samples_eval);
        X4_train     = X4(samples_eval);
        X5_train     = X5(samples_eval);
        X6_train     = X6(samples_eval);
        X7_train     = X7(samples_eval);
        X8_train     = X8(samples_eval);
        X9_train     = X9(samples_eval);
        X10_train    = X10(samples_eval);
        X11_train    = X11(samples_eval);
        X12_train    = X12(samples_eval);
        Xt_train     = X_t(samples_eval);
    
        if opt_var == 1
            opt_data=LFCUSE_train;
        elseif opt_var == 2
            opt_data=NEER_train;
        end
        % opt_data(find(opt_data<0))=0;
        % DATA=array2table([PVOF_train,X5_train],...
        %     'VariableNames',{'PVOF_train','X5'});
        DATA=array2table([DEMF_train,PVOF_train,X1_train,X2_train,X3_train,X4_train,...
            X5_train,X6_train,X7_train,X8_train,X9_train,X11_train],...
            'VariableNames',{'DEMF_train','PVOF_train','X1','X2','X3','X4','X5',...
            'X6','X7','X8','X9','X11'});
    
        sjap_values = shapley(mdl,DATA);
        shapvalues_all = [];
        %% 予測
        for j = 1:height(DATA) % 要素番号
            queryPoint = DATA(j,:);
            explainer = fit(sjap_values,queryPoint,'UseParallel',true);
            w = explainer.ShapleyValues(:,2);
            l = table2array(w);
            m = l';
            shapvalues_all = vertcat(shapvalues_all,m);
            yPred0(j)=explainer.Intercept;
        end
        % 解:opt_data
        % 予測:yPred
        
        % save(['shap_values_by_mat_time_',num2str(t),'mat'],'shapvalues_all')
    
        %% 誤差評価
        % SHAP値考慮の予測値
        yResult=opt_data;
        yPred0=yPred0';
        yPred_base=yPred0+sum(shapvalues_all')';
        yPred1=yPred0+shapvalues_all(:,1);
        yPred2=yPred0+shapvalues_all(:,2);
        yPred3=yPred0+shapvalues_all(:,3);
        yPred4=yPred0+shapvalues_all(:,4);
        yPred5=yPred0+shapvalues_all(:,5);
        yPred6=yPred0+shapvalues_all(:,6);
        yPred7=yPred0+shapvalues_all(:,7);
        yPred8=yPred0+shapvalues_all(:,8);
        yPred9=yPred0+shapvalues_all(:,9);
        yPred10=yPred0+shapvalues_all(:,10);
        yPred11=yPred0+shapvalues_all(:,11);
        yPred12=yPred0+shapvalues_all(:,12);
        % yPred13=yPred0+shapvalues_all(:,13);
    
        [yPred, yStd] = predict(mdl, DATA);
    
        figure,plot(opt_data)
        hold on
        plot(yPred_base)
        plot(yPred1);plot(yPred2);plot(yPred3);
        plot(yPred4);plot(yPred5);plot(yPred6);
        plot(yPred7);plot(yPred8);plot(yPred9);
        plot(yPred10);plot(yPred11);plot(yPred12);
        % plot(yPred13)
        plot(yPred)
    
        %% 予測精度
        yResult=reshape(yResult,d_T,[]);yResult=reshape(yResult(target_time,:),[],1);
        yPred_base=reshape(yPred_base,d_T,[]);yPred_base=reshape(yPred_base(target_time,:),[],1);
        yPred1=reshape(yPred1,d_T,[]);yPred1=reshape(yPred1(target_time,:),[],1);
        yPred2=reshape(yPred2,d_T,[]);yPred2=reshape(yPred2(target_time,:),[],1);
        yPred3=reshape(yPred3,d_T,[]);yPred3=reshape(yPred3(target_time,:),[],1);
        yPred4=reshape(yPred4,d_T,[]);yPred4=reshape(yPred4(target_time,:),[],1);
        yPred5=reshape(yPred5,d_T,[]);yPred5=reshape(yPred5(target_time,:),[],1);
        yPred6=reshape(yPred6,d_T,[]);yPred6=reshape(yPred6(target_time,:),[],1);
        yPred7=reshape(yPred7,d_T,[]);yPred7=reshape(yPred7(target_time,:),[],1);
        yPred8=reshape(yPred8,d_T,[]);yPred8=reshape(yPred8(target_time,:),[],1);
        yPred9=reshape(yPred9,d_T,[]);yPred9=reshape(yPred9(target_time,:),[],1);
        yPred10=reshape(yPred10,d_T,[]);yPred10=reshape(yPred10(target_time,:),[],1);
        yPred11=reshape(yPred11,d_T,[]);yPred11=reshape(yPred11(target_time,:),[],1);
        yPred12=reshape(yPred12,d_T,[]);yPred12=reshape(yPred12(target_time,:),[],1);
        % yPred13=reshape(yPred13,d_T,[]);yPred13=reshape(yPred13(target_time,:),[],1);
        yPred=reshape(yPred,d_T,[]);yPred=reshape(yPred(target_time,:),[],1);
        model_pre = [yPred_base,yPred1,yPred2,yPred3,yPred4,...
            yPred5,yPred6,yPred7,yPred8,yPred9,yPred10,...
            yPred11,yPred12,yPred]; % モデルの予測値
        
        % 日間RMSEを計算
        rmse_1day = sqrt(mean((model_pre - yResult).^2));
        figure,plot(rmse_1day,'o-');yline(rmse_1day(1))
        % 日間MAEを計算
        mae_1day = mean(abs(yResult - model_pre));
        figure,plot(mae_1day,'o-');yline(mae_1day(1))
    
        % % 時刻断面RMSEを計算
        % model_pre=reshape(model_pre,size(target_time,2),[]); % ex:1~8列が1日目
        % yResult=reshape(yResult.*ones(height(yResult),11),size(target_time,2),[]);
        % ELE=11;
        % D_E=size(yResult,2)/ELE;
        % for ele = 1:ELE
        %     rmse_time(:,ele)=sqrt(mean((model_pre(:,D_E*(ele-1)+1:D_E*(ele-1)+D_E)'...
        %         -yResult(:,D_E*(ele-1)+1:D_E*(ele-1)+D_E)').^2));
        % end
        % figure,plot(rmse_time)
        case 2
            gprMdl=mdl;
    end
end