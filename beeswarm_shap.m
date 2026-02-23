load('shapvalues_all.mat')
% figure,bar(sum(abs(shapvalues_all))/size(shapvalues_all,1))
% 
% %% yの範囲抽出
% delta=1;
% % パターンの長さ
% patternLength = size(shapvalues_all,2)*delta;
% % リピート回数
% repeats = size(shapvalues_all,1);
% % パターンの生成
% pattern = 1:delta:patternLength;
% % パターンの繰り返し
% x = repmat(pattern, 1, repeats)';
% y=reshape(shapvalues_all',1,[])';
% figure,beeswarm(x,y,'dot_size',.2,'MarkerFaceAlpha',.5,'corral_style','none','sort_style','up');
% g=gca;


% close
%% 重なりを伏せくために一つづつプロット
delta=1;
for i = 1:12
    data=shapvalues_all(:,i);
    % パターンの長さ
    patternLength = size(data,2)*delta;
    % リピート回数
    repeats = size(data,2);
    % パターンの生成
    pattern = 1:delta:patternLength;
    % パターンの繰り返し
    x = repmat(pattern, 1, repeats)';
    
    y=reshape(data',[],1)';

    x=x(randperm(length(y), round(length(y)/10)));
    y=y(randperm(length(y), round(length(y)/10)));
    
    figure,beeswarm(x,y,'dot_size',.2,'MarkerFaceAlpha',.5,'corral_style','none','sort_style','up');

    o_sfig([1,5,1],[.5,1.5],[g.YLim],...
        [],[],[],['r',num2str(i)],fullfile('電学論B',...
        '機械学習','Beeswarm図'))

    close
end