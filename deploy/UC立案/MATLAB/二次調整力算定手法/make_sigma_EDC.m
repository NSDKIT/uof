%% 気象解析(統計データ作成)
% -- 時間幅 --
T_R=1:48;T=1;
% 予測PV出力幅
% PVC=1100;
N_gen=11;
PV_r=PVC/N_gen;
% PV_r=200;
PVF_r_low=-PV_r;


EDC_sigma1_plus=[];EDC_sigma2_plus=[];EDC_sigma3_plus=[];
EDC_sigma1_minus=[];EDC_sigma2_minus=[];EDC_sigma3_minus=[];
m=0;z=0;x=0;
%%% 格納用 %%%
EDC_struct = struct('data', cell(size(T_R,2),N_gen, 1));
x_max=max(abs(max(EDC_5min,[],'all')),abs(min(EDC_5min,[],'all')));
xr=[-x_max,x_max];

for n=PV_r:PV_r:PVC
    m=m+1;
    
    % 予測PV出力幅の下限値，上限値
%     PVF_r_low=PVF_r_low+PV_r;
%     PVF_r_up=PVF_r_low+PV_r;
    PVF_r_low=PVF_r_low+PV_r;
    PVF_r_up=n;
    
    % 5分値: 予測PV出力の範囲抽出
    PVF5min_oxl=pvf>=PVF_r_low;
    PVF5min_oxu=pvf<PVF_r_up;
    PVF5min_ox=PVF5min_oxl.*PVF5min_oxu;
    
    EDC_1sigma_n_plus=[];EDC_2sigma_n_plus=[];EDC_3sigma_n_plus=[];
    EDC_1sigma_n_minus=[];EDC_2sigma_n_minus=[];EDC_3sigma_n_minus=[];
    for t = T_R
       %% EDC調整力
        % 幅に入ってるかのバイナリ変数
        data1=PVF5min_ox(T*(t-1)+1:T*t,:);
        % EDC調整力用の5分値予測誤差
        data2=EDC_5min(T*(t-1)+1:T*t,:);
        % 年間データ
        data0=data1.*data2;
        data0=reshape(data0,[1,T*361]);
        
        EDC_struct(t, m, 1).data = [data1;data2];

        data0(find(data1==0))=[];
        data0_plus=data0;
        data0_minus=data0;
        %% surplus assume to peak cuts, so collect onlu plus errro value.
%         data0_plus(data0_plus<-0.01)=[];
        if isempty(data0_plus) == 1
            data0_plus=0;
        end

        %% subplot
        % if mod(m, 2) == 1 && mod(t, 2) == 1
        %     z=z+1;
        %     figure(62)
        %     subplot(round(size(PV_r:PV_r:PVC,2)/2),...
        %         round(size(T_R,2)/2),z)
        %     hold on;hist(data0);xlim(xr)
        % end
        if mod(t, 2) == 1
            z=z+1;
            figure(62)
            subplot(2,12,z)
            hold on;
            hist(data2);xlim(xr)
            ylim([0,250])
        end

%         % 正規分布ではないため，定義集を採用。参考https://www.occto.or.jp/iinkai/chouseiryoku/2016/files/chousei_jukyu_06_04.pdf
        EDC_3sigma_plus=prctile(data0_plus,99.73+(100-99.73)/2); % 99.73+(100-99.73)/2
        EDC_2sigma_plus=prctile(data0_plus,95.45+(100-95.45)/2); % 95.45+(100-95.45)/2
        EDC_1sigma_plus=prctile(data0_plus,68.27+(100-68.27)/2); % 68.27+(100-68.27)/2
        
        EDC_1sigma_n_plus=[EDC_1sigma_n_plus;EDC_1sigma_plus];
        EDC_2sigma_n_plus=[EDC_2sigma_n_plus;EDC_2sigma_plus];
        EDC_3sigma_n_plus=[EDC_3sigma_n_plus;EDC_3sigma_plus];
        
        %% negative value collect.
        data0_minus(data0_minus>0.01)=[];
        data0_minus=abs(data0_minus);
        if isempty(data0_minus) == 1
            data0_minus=0;
        end
        %         % 正規分布ではないため，定義集を採用。参考https://www.occto.or.jp/iinkai/chouseiryoku/2016/files/chousei_jukyu_06_04.pdf
        EDC_3sigma_minus=prctile(data0_minus,99.73); % 99.73
        EDC_2sigma_minus=prctile(data0_minus,95.45); % 95.45+(100-95.45)/2
        EDC_1sigma_minus=prctile(data0_minus,68.27); % 68.27+(100-68.27)/2
        
        EDC_1sigma_n_minus=[EDC_1sigma_n_minus;EDC_1sigma_minus];
        EDC_2sigma_n_minus=[EDC_2sigma_n_minus;EDC_2sigma_minus];
        EDC_3sigma_n_minus=[EDC_3sigma_n_minus;EDC_3sigma_minus];
    end
    % 行: 時間断面，列: 予測PV出力幅
    EDC_sigma1_plus=[EDC_sigma1_plus,EDC_1sigma_n_plus];
    EDC_sigma2_plus=[EDC_sigma2_plus,EDC_2sigma_n_plus];
    EDC_sigma3_plus=[EDC_sigma3_plus,EDC_3sigma_n_plus];
    
    EDC_sigma1_minus=[EDC_sigma1_minus,EDC_1sigma_n_minus];
    EDC_sigma2_minus=[EDC_sigma2_minus,EDC_2sigma_n_minus];
    EDC_sigma3_minus=[EDC_sigma3_minus,EDC_3sigma_n_minus];
end
