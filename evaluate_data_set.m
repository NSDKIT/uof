%% 評価
% PV予測値：PVF_data=;
% 需要予測値：DEMF_data=;
% ex:
% for pvc_rate=5100:4160:13420
% load(['F:\NSD_results\Sigma_1_LFC_8_PVcapacity_',num2str(pvc_rate),'_2019629.mat']);LOF=LOF+PVF;
% DEMF_data=LOF(1:1800:86401);
% PVF_data=PVF(1:1800:86401)-PV_CUR(1:49)';

%%% 設定 %%%
mdl_sel=2; % 1:誤差経由，2:直接，3:周波数偏差経由
big_out=1; % 0:除去ナシ，1:除去アリ

%%% モデルファイル作成 %%%
if mdl_sel == 1
    mdl_file='Mdl1';
elseif mdl_sel == 2
    mdl_file='Mdl2';
elseif mdl_sel == 3
    mdl_file='Mdl3';
end

%%% 外れ値考慮あり/なしファイル作成 %%%
if big_out == 0
    BO_file='外れ値除去ナシ';
elseif big_out == 1
    BO_file='外れ値除去アリ';
end

file_gpr='ガウス過程回帰モデル';

for t = 1:48
    time_file=[num2str(t),'.mat'];
    load(fullfile(file_gpr,mdl_file,time_file))
    % load(fullfile(file_gpr,BO_file,mdl_file,time_file))
    
    % 評価データ作成 ({'DEMF','PVOF','NEER','LFCUSE','DF'})
    if mdl_sel ~= 3
        eva_data = array2table([PVF_data(t),X10(t)],...
            'VariableNames',{'PVOF','X10'});
        % eva_data = array2table([DEMF_data(t),PVF_data(t),X3(t),X4(t),X5(t),X6(t),X10(t),X11(t)],...
        %     'VariableNames',{'DEMF','PVOF','X3','X4','X5','X6','X10','X11'});
        [yPred, yStd] = predict(gprMdl, eva_data);
    elseif mdl_sel == 3
        lfc_assume=(100:3372)'; % MW
        eva_data = array2table(...
            [[DEMF_data(t),PVF_data(t)].*...
            ones(size(lfc_assume,1),2),lfc_assume],...
            'VariableNames',{'DEMF','PVOF','RESSEC'});
        [yPred, yStd] = predict(gprMdl, eva_data);
        figure(84);hold on;plot(yPred+1.96*yStd)
        per_95=yPred+1.96*yStd;
        opt_num=find(per_95==min(per_95));
        yPred=yPred(opt_num);
        yStd=yStd(opt_num);
    end
    YP(t)=yPred;
    YS(t)=yStd;
end
load('..\..\..\..\..\sigma.mat')
RES=YP+sigma*YS;
RES=[RES,RES(end),RES(end)];
% RES=reshape(interp1(1:48,RES,1+1/1800:1/1800:49),[],1);
% figure,plot(RES);hold on;plot(PVF-PV_real_Output(2,:))
% figure(82);hold on;plot(PVF_data);plot(PV_real_Output(2,:))
% end