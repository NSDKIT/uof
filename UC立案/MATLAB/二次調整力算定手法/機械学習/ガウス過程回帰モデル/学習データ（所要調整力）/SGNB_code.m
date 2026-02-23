PVC = 3620;
p=pwd;

load(['H:\解析結果\IEEJ_B\data\20200220\TimeX\LearningPeriod_December\method4\PV_',num2str(PVC),'.mat'])
lfc1=load_input(1:1800:end-1)*0.08;
lfc2 = load_input(1:1800:end-1)*0.1+PV_Forecast(1:1800:end-1)*.25;
lfc3 = column_means+2*column_variances;
lfc4 = sum(Reserved_power(1:48,[2,4])');
d_uc_out = sum(G_Out_UC(1:86401,:)');
d_op_out = sum([Oil_Output,Coal_Output,Combine_Output]');
d_lfc_use = d_op_out - d_uc_out;
data = lfc1;
data_repeated = repmat(data, 1800, 1);
lfc1 = reshape(data_repeated, 1, []);
data = lfc2;
data_repeated = repmat(data, 1800, 1);
lfc2 = reshape(data_repeated, 1, []);
data = lfc3;
data_repeated = repmat(data, 1800, 1);
lfc3 = reshape(data_repeated, 1, []);
data = lfc4;
data_repeated = repmat(data, 1800, 1);
lfc4 = reshape(data_repeated, 1, []);
figure,plot(lfc1);hold on;plot(lfc2);plot(lfc3);plot(lfc4);plot(d_lfc_use)
cd 'C:\Users\PowerSystemLab\Documents\FromDesktop\01_研究資料\01_matlab_mytool'
sec_time(1)
legend({'需要×8%','需要×10%+PV出力×25%','統計手法','機械学習','利用量'})
cd(p)
title(['学習期間2019/12，統計解析期間2019/12，図示している日は2020/2/20, PV',num2str(PVC),'MW'])