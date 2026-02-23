close all
clear
load('JuneDataMSM.mat')
load('JuneDataSystem.mat')

t = 1:48;
DATA = [DEMAND,PVOUT,MSM_ALL0(:,[1:9,11]),LFCUSE];
DATA = DATA(sort(reshape(t+[48:48:48*28]',[],1)),:);

R = corrcoef(DATA);

% Calculate MIC
max_bins = 20;  % Consider up to 20 bins for grid
for i = 1:size(DATA,2)
    for j = 1:size(DATA,2)
        mic(i,j) = CalculateMic(DATA(:,i), DATA(:,j), max_bins);
    end
end

figure,plot(abs(R(1:end-1,end)),'bo-')
hold on;plot(mic(1:end-1,end),'ro-')
ylim([0,1])
g = gca;
for rate = 1:5
    o_sfig([rate,1,1],g.XLim,g.YLim,...
        [],[],[],['r',num2str(rate)],...
        fullfile('電学論B','R&MIC'))
end

% figure,scatter(DATA(:,7),DATA(:,end),'o','LineWidth',.01,'MarkerEdgeColor','b','MarkerFaceColor','b');

figure,plot(MSM_ALL0(:,end-1),LFCUSE,'b.','MarkerSize',10);
hold on;plot(MSM_ALL0(:,end-1),PVOUT*1100/5300,'r.','MarkerSize',10);
ylim([0,2000])
xlim([0,1000])
g = gca;
for rate = 1:5
    o_sfig([rate,1,1],g.XLim,g.YLim,...
        [],[],[],['r',num2str(rate)],...
        fullfile('電学論B','IRR-PV&RES'))
end

figure,plot(NETERROR,LFCUSE,'k.','MarkerSize',10);
ylim([0,2000])
xlim([0,2500])
g = gca;
for rate = 1:5
    o_sfig([rate,1,1],g.XLim,g.YLim,...
        [],[],[],['r',num2str(rate)],...
        fullfile('電学論B','NETERROR-RES'))
end

gfigure