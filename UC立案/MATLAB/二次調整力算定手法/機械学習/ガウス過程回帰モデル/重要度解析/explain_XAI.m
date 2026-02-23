load('notXAI_shapvalues.mat')
load('yPred0.mat')
load('mdl.mat')
load('DATA.mat')
close all
%% 誤差評価
% SHAP値考慮の予測値
yResult=opt_data;
yPred1=yPred0+shapvalues_all(:,1);    % 需要
yPred2=yPred0+shapvalues_all(:,2);    % PV
yPred3=yPred0+shapvalues_all(:,3);    % 海面更生気圧
yPred4=yPred0+shapvalues_all(:,4);    % 地上気圧
yPred5=yPred0+shapvalues_all(:,5);    % 東西風速
yPred6=yPred0+shapvalues_all(:,6);    % 南北風速
yPred7=yPred0+shapvalues_all(:,7);    % 気温
yPred8=yPred0+shapvalues_all(:,8);    % 相対湿度
yPred9=yPred0+shapvalues_all(:,9);    % 下層雲量
yPred10=yPred0+shapvalues_all(:,10);  % 中層雲量
yPred11=yPred0+shapvalues_all(:,11);  % 上層雲量
yPred12=yPred0+shapvalues_all(:,12);  % 降水量

[yPred, yStd] = predict(mdl, DATA);

figure,plot(opt_data)
hold on
plot(yPred0)
plot(yPred1);plot(yPred2);plot(yPred3);
plot(yPred4);plot(yPred5);plot(yPred6);
plot(yPred7);plot(yPred8);plot(yPred9);
plot(yPred10);plot(yPred11);plot(yPred12);
plot(yPred)

%% 予測精度
yResult=reshape(yResult,d_T,[]);yResult=reshape(yResult(target_time,:),[],1);
yPred0=reshape(yPred0,d_T,[]);yPred0=reshape(yPred0(target_time,:),[],1);
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
yPred=reshape(yPred,d_T,[]);yPred=reshape(yPred(target_time,:),[],1);
model_pre = [yPred0,yPred1,yPred2,yPred3,yPred4,...
    yPred5,yPred6,yPred7,yPred8,yPred9,yPred10,...
    yPred11,yPred12,yPred]; % モデルの予測値

% 日間RMSEを計算
rmse_1day = sqrt(mean((model_pre - yResult).^2));
figure,plot(rmse_1day,'o-');yline(rmse_1day(1))
xticks(1:15)
xticklabels({'基準','需要','PV','海面気圧','地上気圧','東西風速','南北風速','気温','相対湿度','下層雲量','中層雲量','上層雲量','降水量','全部'})
% 日間RMSEを計算
mae_1day = mean(abs(yResult - model_pre));
figure,plot(mae_1day,'o-');yline(mae_1day(1))
xticks(1:15)
xticklabels({'基準','需要','PV','海面気圧','地上気圧','東西風速','南北風速','気温','相対湿度','下層雲量','中層雲量','上層雲量','降水量','全部'})

%% waterfall
base=mae_1day(1);
all=mae_1day(end);
w_mae=[base,mae_1day(2:end-1)-base,all];

filename = 'waterfall.xlsx'; % Excelファイル名
writematrix(w_mae, filename);

gfigure