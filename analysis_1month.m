close all
ML=0;
one_time=86401;
one_time_30min=49;
X_Oil=nan(86401,4);
X_Coal=nan(86401,6);
X_Combine=nan(86401,1);
X_dfout=nan(86401,1);
D_FRE=[];
for dd=1:30
    load(['F:\NSD_results\Sigma_1_LFC_8_PVcapacity_5100_20196',num2str(dd),'.mat'])
    
    PV_real=PV_real_Output(2,:);


    
    X_Oil(1:size(Oil_Output,1),...
        1:size(Oil_Output,2))=...
        Oil_Output(1:size(Oil_Output,1),...
        1:size(Oil_Output,2));
    X_Coal(1:size(Coal_Output,1),...
        1:size(Coal_Output,2))=...
        Coal_Output(1:size(Coal_Output,1),...
        1:size(Coal_Output,2));
    X_Combine(1:size(Combine_Output,1),...
        1:size(Combine_Output,2))=...
        Combine_Output(1:size(Combine_Output,1),...
        1:size(Combine_Output,2));
    X_dfout(1:size(dfout,1),...
        1:size(dfout,2))=...
        dfout(1:size(dfout,1),...
        1:size(dfout,2));
    
    Oil_Output=X_Oil;
    Coal_Output=X_Coal;
    Combine_Output=X_Combine;
    dfout=X_dfout;
    
    % 実運用断面
    time_start=one_time*(dd-1)+1;
    t=time_start:time_start+one_time-1;

    figure(10);hold on
    plot(t,PVF);plot(t,PV_real)

    % figure(1);hold on
    % area(t,sum([sum(Oil_Output')',sum(Coal_Output')',Combine_Output,PV_real',PV_Surplus',TieLineLoadout]'),'FaceColor','k','FaceAlpha',.5)
    % area(t,sum([sum(Oil_Output')',sum(Coal_Output')',Combine_Output,PV_real',PV_Surplus']'),'FaceColor','b','FaceAlpha',.5)
    % area(t,sum([sum(Oil_Output')',sum(Coal_Output')',Combine_Output,PV_real']'),'FaceColor','g','FaceAlpha',.5)
    % area(t,sum([sum(Oil_Output')',sum(Coal_Output')',PV_real']'),'FaceColor','y','FaceAlpha',.5)
    % area(t,sum([sum(Oil_Output')',PV_real']'),'FaceColor','k','FaceAlpha',.5)
    % area(t,PV_real,'FaceColor','r','FaceAlpha',.5)
    % plot(t,load_input,'k','LineWidth',2)
    % ML=max([ML,load_input]);
    % 
    % % 系統周波数偏差
    % figure(2);hold on
    % dfout(1:3600)=0;
    % dfout(end-3601:end)=0;
    % plot(t,dfout)
    % D_FRE(t)=dfout;
    % 
    % figure(21);hold on
    % bar(dd,length(find(abs(dfout)>.2))./length(dfout)*100)
    % 
    % % 予測誤差と調整力幅
    % rate_ERR_RES=(PVF-PV_real_Output(2,:))./[sum(Reserved_power(1,[1,3]));reshape(sum(Reserved_power(1:48,[1,3])').*ones(1800,48),[],1)]';
    % if isempty(find(rate_ERR_RES>1))==0
    %     line_color='r';
    % elseif isempty(find(rate_ERR_RES>1))==1
    %     line_color='k';
    % end
    % figure(3);hold on
    % plot(t,rate_ERR_RES,'Color',line_color)
    % % plot(t,(PVF-PV_real_Output(2,:))./LOF*100)
    % % plot(t,[sum(Reserved_power(1,[1,3]));reshape(sum(Reserved_power(1:48,[1,3])').*ones(1800,48),[],1)]./LOF'*100)
    % 
    % % 計画断面
    % time_start=one_time_30min*(dd-1)+1;
    % t=time_start:time_start+one_time_30min-1;
    % 
    % figure(4);hold on
    % bar(t,[PVF(1:1800:86401)',G_Out_UC([1:1800:86401],[1:4,6:11,18])],1,'stacked')
    % D_F=PVF+LOF;plot(t,D_F(1:1800:86401),'k','LineWidth',2)
end
figure(2);yline(.2);yline(-.2);gfigure

% 1カ月の逸脱確立
length(find(abs(D_FRE)>.2))./length(D_FRE)*100