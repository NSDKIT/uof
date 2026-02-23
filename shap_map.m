close all
% load('alldata_allperiod.mat')
% % cmap = [
% %     0.9333    0.6471    0.6471;  % ソフトレッド
% %     0.9333    0.7333    0.5843;  % ソフトオレンジ
% %     0.9333    0.9333    0.5843;  % ソフトイエロー
% %     0.6471    0.9333    0.5843;  % ソフトライム
% %     0.5843    0.9333    0.6471;  % ソフトグリーン
% %     0.5020    0.9333    0.7333;  % ソフトミント
% %     0.5020    0.7529    0.9333;  % ソフトブルー
% %     0.6471    0.6471    0.9333;  % ソフトパープル
% %     0.7529    0.5020    0.9333;  % ソフトパープル
% %     0.9333    0.5020    0.9333;  % ソフトマゼンタ
% %     0.9333    0.6471    0.7843;  % ソフトピンク
% %     0.9333    0.8000    0.6510   % ソフトペッパーミント
% % ];
% 
% 12色のRGB値生成
numColors = 6;

% HSV色空間での均等な色相を選択
hsvColors = [(0:numColors-1)'/numColors, 0.7 * ones(numColors, 2)];

% HSVからRGBに変換
cmap = hsv2rgb(hsvColors);


% 
% 
% figure
% ba = bar(shapvalues_all,1,'stacked','FaceColor','flat');
% for i = 1:12
%     ba(i).CData = cmap(i,:);
% end
% legend([{'feature1'},{'feature2'},{'feature3'},...
%     {'feature4'},{'feature5'},{'feature6'},...
%     {'feature7'},{'feature8'},{'feature9'},...
%     {'feature10'},{'feature11'},{'feature12'}])
% sec_time_30min(28)
% xticklabels('')
% 
% hold on
% plot(yResult-yPred0,'r:','LineWidth',4.5)
% plot(sum(shapvalues_all')','k','LineWidth',1.5)
% yline(0,'k','LineWidth',1.5)
% g=gca;
% vi_yl=yPred0(1)+g.YLim(1);
% vi_ylr=round(vi_yl,-2);
% re_yl=g.YLim(1)+vi_ylr-vi_yl;
% re_yh=g.YLim(2)+vi_ylr-vi_yl;
% yr=re_yl:200:re_yh+200;
% ne_posi=find(sign(yr)==-1);
% po_posi=find(sign(yr)==1);
% yr_ti=horzcat(yr(ne_posi),0,yr(po_posi));
% yr_la=vi_ylr:200:vi_ylr+200*(size(yr,2)-1);
% yr_la=horzcat(yr_la(ne_posi),yPred0(1),yr_la(po_posi));
% yticks(yr_ti)
% yticklabels(yr_la)
% 
% % model_pre = [yPred0,yPred1,yPred2,yPred3,yPred4,...
% %     yPred5,yPred6,yPred7,yPred8,yPred9,yPred10,...
% %     yPred11,yPred12,yPred_base]; % モデルの予測値
% % model_pre(1)-model_pre(2)
% % % 日間MAEを計算
% % mae_1day = mean(abs(yResult - model_pre));
% % figure,plot(mae_1day,'o-');yline(mae_1day(1))
% 
% % 現在の軸を取得
% ax = gca;
% % 新しいフィギュアを作成
% newFig = figure;
% % 複製するオブジェクトを指定して複製
% newAx = copyobj(ax, newFig);
% % 新しいフィギュアで複製されたグラフを表示
% figure(newFig);
% i=4;xlim([48*(i-1)+1,48*(i+2)])
% g=gca;
% for rate = 1:5
%     o_sfig([rate,1,1],g.XLim,g.YLim,[],[],[],['r',num2str(rate)],'電学論B/時系列SHAP')
% end

load('shapvalues_all.mat','shapvalues_all')
%% 貢献力
sign_ans=(sign(sum(shapvalues_all')'));
sign_feature=(sign(shapvalues_all));
sign_feature=sign_feature.*sign_ans;
shapvalues_all=abs(shapvalues_all).*sign_feature;
shap_sum=sum(shapvalues_all);
figure,bar(shap_sum)
g=gca;
for rate = 1:5
    o_sfig([rate,1,1],g.XLim,g.YLim,[],[],[],['r',num2str(rate)],'電学論B/貢献力')
end

%% 貢献度
impact_rate=sign_feature;
% impact_rate=sign_feature==1;
impact_rate=sum(impact_rate)/size(impact_rate,1)*100;
figure,bar(impact_rate)
g=gca;
for rate = 1:5
    o_sfig([rate,1,1],g.XLim,g.YLim,[],[],[],['r',num2str(rate)],'電学論B/貢献度')
end

% figure,bar(sum(shapvalues_all)./sum(shapvalues_all,'all')*100)
figure;hold on
for i = 1:size(impact_rate,2)
    % scatter(impact_rate(i),shap_sum(i),'LineWidth',6,'MarkerEdgeColor',cmap(i,:),'MarkerFaceColor',cmap(i,:));
    if i <= 6
        plot(impact_rate(i),shap_sum(i),'.','MarkerSize',30,'Color',cmap(i,:));
    else
        plot(impact_rate(i),shap_sum(i),'pentagram','MarkerSize',10,'MarkerEdgeColor',cmap(i-6,:),'MarkerFaceColor',cmap(i-6,:));
    end
end

xlim([-20,100])
xline(mean(impact_rate))
yline(mean(shap_sum))
yline(0)
g = gca;
ylim([-10^5,2.5*10^5])
g = gca;
for rate = 1:5
    o_sfig([rate,1,1],g.XLim,g.YLim,[],[],[],['r',num2str(rate)],'電学論B/貢献率-貢献度')
end

gfigure