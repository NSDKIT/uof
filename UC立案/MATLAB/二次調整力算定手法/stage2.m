% 1秒値から成形して，学習用データに統計処理を行う --
N_t=60*30;
row_low=1:N_t:86400;
row_up=row_low+1800;
% EDC_5min=EDC_5min(row_low,:);
pvf=[];demf=[];
D_R_Y=reshape(Demand_real_year,[86400,size(Demand_real_year,1)/86400]);
for n = 1:length(row_low)
    if row_up(n) == 86401
        pvf=[pvf;max(PV_f(row_low(n):86400,:))];
        demf=[demf;mean(D_R_Y(row_low(n):86400,:))];
    else
        pvf=[pvf;max(PV_f(row_low(n):row_up(n),:))];
        demf=[demf;mean(D_R_Y(row_low(n):row_up(n),:))];
    end
end

% 最大LFC上側調整力=実測値(1秒値)－EDC5分周期誤差
% T=60*5;    % 時間窓5分
% N_t=86400; % 1日の総秒数
% LFC_5min=[];
% for day=1:length(PV_Out)/N_t
%     data_day_5min=ND_5min(N_t*(day-1)+1:N_t*day);
%     data_day_1min=ND_1min(N_t*(day-1)+1:N_t*day);
%     PV_day=[];
%     for t=1:N_t/T
%         flu=max(data_day_1min(T*(t-1)+1:T*t))-max(data_day_5min(T*(t-1)+1:T*t));
%         PV_day=[PV_day,flu];
%     end
%     LFC_5min=[LFC_5min,PV_day'];
% end

% T=60*5;    % 時間窓5分
% N_t=86400; % 1日の総秒数
% LFC_5min=[];
% for day=1:length(PV_Out)/N_t
%     data_day=PV_Out(N_t*(day-1)+1:N_t*day);
%     PV_day=[];
%     for t=1:N_t/T
%         data_t=data_day(T*(t-1)+1:T*t);
%         t_max=min(find(data_t==max(data_t)));
%         t_min=min(find(data_t==min(data_t)));
%         t_devi=t_max-t_min;
%         pn=sign(t_devi);
%         flu=max(data_t)-min(data_t);
%         PV_day=[PV_day,flu*pn];
%     end
%     LFC_5min=[LFC_5min,PV_day'];
% end