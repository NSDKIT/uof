clear
load('C:\Users\PowerSystemLab\Desktop\01_研究資料\05_実行ファイル\program\全体実行\UC立案\MATLAB\二次調整力算定手法\機械学習\ガウス過程回帰モデル\解析結果\2019年\6月\30日\XAI/PV_1100.mat','PVF','LOF','load_input','PV_real_Output')
PVF = PVF(1:1800:end-1800);
steps = 86400 / length(PVF);
PVF = repelem(PVF, steps);
LOF = PVF+LOF(1:end-1);
LOF = LOF(1:1800:end);
steps = 86400 / length(LOF);
LOF = repelem(LOF, steps);
load('MSM_30X.mat')
X5=X(1:1800:end,5);X8=X(1:1800:end,8);X9=X(1:1800:end,9);
X5 = repelem(X5, steps);X8 = repelem(X8, steps);X9 = repelem(X9, steps);

figure,plot(LOF);hold on;plot(load_input);sec_time
figure,plot(PVF);hold on;plot(PV_real_Output(2,:));sec_time

% figure
% subplot(411,'Position', [0.1 0.71 0.8 0.2])
% hold on;plot(LOF);plot(load_input)
% sec_time
% subplot(412,'Position', [0.1 0.51 0.8 0.2])
% hold on;plot(PVF);plot(PV_real_Output(2,:))
% sec_time
% subplot(413,'Position', [0.1 0.31 0.8 0.2])
% hold on;plot(X5)
% sec_time
% subplot(414,'Position', [0.1 0.11 0.8 0.2])
% hold on;plot(X8);plot(X9)
% sec_time