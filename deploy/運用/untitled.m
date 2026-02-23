close all
m=0;
for ii=5100:1040:15500
m=m+1;
for i=1:19
    if i==10
        X(i,m)=nan;
    else
        load(['F:\NSD_results\E_Sigma_2_LFC_',num2str(i),'_PVcapacity_',num2str(ii),'_201965.mat'])
        dfout=dfout(3600*5:3600*19);
        X(i,m)=sum(abs(dfout)>.2);
        figure(17);hold on;plot(dfout)
    end
    % figure(5);hold on;plot(PVF-PV_real_Output(2,:));sec_time;xlim([3600*3,3600*9])
    % figure(6);hold on;plot(dfout);sec_time;xlim([3600*3,3600*9])
    % figure(7);hold on;plot(PVF);plot(PV_real_Output(2,:));sec_time;xlim([3600*3,3600*9])
    % gfigure
end
end
% re=sum(Reserved_power(:,[1,3])');
% figure(5);hold on;plot(reshape(re.*ones(1800,50),[1,1800*50]))
% legend
% figure(6);legend
% gfigure
figure,heatmap(X)
colormap(turbo)