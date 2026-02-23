T=60*5;N_t=86400;
PV_5min=[];
for day=1:length(PV_Out)/N_t
    data_day=PV_Out(N_t*(day-1)+1:N_t*day);
    PV_day=[];
    for t=1:N_t/T
        data_t=data_day(T*(t-1)+1:T*t);
        t_max=min(find(data_t==max(data_t)));
        t_min=min(find(data_t==min(data_t)));
        t_devi=t_max-t_min;
        pn=sign(t_devi);
        flu=max(data_t)-min(data_t);
        PV_day=[PV_day,flu*pn];
    end
    PV_5min=[PV_5min,PV_day'];
end
    
    
% every 6 times

%% 気象解析(統計データ作成)
% -- 時間幅 --
T_R=1:48;T=6;
% 予測PV出力幅
PVC=1100;
N_gen=11;
PV_r=PVC/N_gen;
% PV_r=200;
PVF_r_low=-PV_r;
sigma1=[];sigma2=[];sigma3=[];
sigma1_sec=[];sigma2_sec=[];sigma3_sec=[];
MU=[];sigma1_flu=[];sigma2_flu=[];sigma3_flu=[];sigma_max_sec=[];
MU_sea=[];sigma1_flu_sea=[];sigma2_flu_sea=[];sigma3_flu_sea=[];

m=0;
for n=PV_r:PV_r:PVC
    m=m+1;
    
    PVF_r_low=PVF_r_low+PV_r;
    PVF_r_up=PVF_r_low+PV_r;
    
    PVF_ox_low=pvf>=PVF_r_low;
    PVF_ox_up=pvf<PVF_r_up;

    
    sigma1_n=[];sigma2_n=[];sigma3_n=[];
    MU=[];sigma1_flu=[];sigma2_flu=[];sigma3_flu=[];sigma_max=[];
    for t = T_R
        data1=PVF_ox_low(T*(t-1)+1:T*t,:);
        data2=PVF_ox_up(T*(t-1)+1:T*t,:);
        data3=PV_5min(T*(t-1)+1:T*t,:);
        data0=data1.*data2.*data3;
        data0(find(data0<0))=[];
        if m == 8
            if t == 24
                1;
            end
        end
        if sum(data0) ~= 0
            data0(find(data0<=10))=[];
        end
        % 正規分布ではないため，参考https://www.occto.or.jp/iinkai/chouseiryoku/2016/files/chousei_jukyu_06_04.pdf
        % 定義集でもこれが採用されている
        per_3sigma=prctile(data0,99.73); % 99.73
        per_2sigma=prctile(data0,97.73); % 95.45+(100-95.45)/2
        per_1sigma=prctile(data0,84.14); % 68.27+(100-68.27)/2
        sigma1_n=[sigma1_n;per_1sigma];
        sigma2_n=[sigma2_n;per_2sigma];
        sigma3_n=[sigma3_n;per_3sigma];
        
        
    end
    % 行: 時間断面，列: 予測PV出力幅
    sigma1=[sigma1,sigma1_n];
    sigma2=[sigma2,sigma2_n];
    sigma3=[sigma3,sigma3_n];
end

%% 実際の予測誤差を算出
% 対象データ読み込み
load(['E:\02_データ保存\Sigma_0_LFC_8_PVcapacity_',num2str(PVC),'_201868.mat'],'PVF','PV_real_Output')
PVF_30min=PVF(1);
for t = T_R
    PVF_30min=[PVF_30min,PVF(1800*t)];
end
PVF_30min=PVF_30min(1:end-1)';

% 誤差算出
col=0;
PVF_r_low=-PV_r;
PVF_30min=PVF_30min;
PVF_30min_n=zeros(size(PVF_30min));
for n=PV_r:PV_r:PVC
    col=col+1;
    PVF_r_low=PVF_r_low+PV_r;
    PVF_r_up=PVF_r_low+PV_r;
    
    PVF_ox_low=PVF_30min>=PVF_r_low;
    PVF_ox_up=PVF_30min<PVF_r_up;
    
    PVF_30min_n=PVF_30min_n+(PVF_ox_low.*PVF_ox_up)*col;
end

PVerr_1sigma=[];PVerr_2sigma=[];PVerr_3sigma=[];PVerr_max_lfc=[];
PVerr_1sigma_lfc=[];PVerr_2sigma_lfc=[];PVerr_3sigma_lfc=[];
for t = T_R
    if t == 23
        1;
    end
    PVerr_1sigma=[PVerr_1sigma,sigma1(t,PVF_30min_n(t))];
    PVerr_2sigma=[PVerr_2sigma,sigma2(t,PVF_30min_n(t))];
    PVerr_3sigma=[PVerr_3sigma,sigma3(t,PVF_30min_n(t))];
end

PVerr_1sigma=PVerr_1sigma.*(PVF_30min>0.5)';
PVerr_2sigma=PVerr_2sigma.*(PVF_30min>0.5)';
PVerr_3sigma=PVerr_3sigma.*(PVF_30min>0.5)';

% 評価
    % 二次②
    % 誤差推定値
    figure,bar(PVerr_1sigma,1)
    sec_time_30min

    % シミュレーション後のみOK
    % 予測PV出力，誤差幅，実測値
    x = 1/1800:1:length(PVF_30min);
    v = PVF_30min;
    xq = 1/1800:1/1800:length(PVF_30min);
    PVF_1sec = interp1(x,v,xq);

    error2=PVF_30min-PVerr_1sigma';
    x = 1/1800:1:length(error2);
    v = error2;
    xq = 1/1800:1/1800:length(error2);
    error2_1sec = interp1(x,v,xq);
    
    newcolors = [1 1 1;0 1 0];
    Y = [error2_1sec',(PVF_1sec-error2_1sec)'];
    figure,area(1:86400,Y)
    colororder(newcolors)
    hold on
    plot(PVF_1sec,'k','LineWidth',2)
    plot(error2_1sec,'g','LineWidth',2)
    plot(PV_real_Output(2,:),'r','LineWidth',2)
    ga=gca;ylim([0,ga.YLim(2)])
    sec_time
    
gfigure