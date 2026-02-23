%% 気象解析(統計データ作成)
% -- 時間幅 --
T_R=1:48;T=1;
% 予測PV出力幅
% PVC=1100;
N_gen=5;
PV_r=PVC/N_gen;
% PV_r=200;
PVF_r_low=-PV_r;

LFC5_sigma1_up=[];LFC5_sigma2_up=[];LFC5_sigma3_up=[];
LFC5_sigma1_down=[];LFC5_sigma2_down=[];LFC5_sigma3_down=[];
m=0;z=0;x=0;

%%% 格納用 %%%
LFC_struct = struct('data', cell(size(T_R,2),N_gen, 1));
x_max=max(abs(max(LFC_5min_up,[],'all')),abs(min(LFC_5min_down,[],'all')));
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
    
    LFC5_1sigma_n_up=[];LFC5_2sigma_n_up=[];LFC5_3sigma_n_up=[];
    LFC5_1sigma_n_down=[];LFC5_2sigma_n_down=[];LFC5_3sigma_n_down=[];
    for t = T_R
       %% LFC調整力
        % -- 5分変動(5分窓で最大値と最小値の差，藤田さんの卒論参考) --
        data1=PVF5min_ox(T*(t-1)+1:T*t,:); % 幅に入ってるかのバイナリ変数
        data2=LFC_5min_up(T*(t-1)+1:T*t,:);
        data3=LFC_5min_down(T*(t-1)+1:T*t,:);
        data0_up=data1.*data2;
        data0_up=reshape(data0_up,[1,T*361]);
        data0_up(find(data1==0))=[];
        data0_down=data1.*data3;
        data0_down=reshape(data0_down,[1,T*361]);
        data0_down(find(data1==0))=[];
        
        data0_up=[data0_up,data0_down];
%         data0_up=abs(data0_up);
        data0_down=abs(data0_down);

        learn_ox=data1.*ones(1800,size(data1,2));
        learn_data=LFC_time_day(1800*(t-1)+1:1800*t,:);
        LFC_struct(t, m, 1).data = [learn_ox;learn_data];
        
        if isempty(data0_up) == 1
            data0_up=0;
        end
        if isempty(data0_down) == 1
            data0_down=0;
        end

        %% subplot
        % if mod(t, 2) == 1
        %     z=z+1;
        %     figure(63)
        %     subplot(size(PV_r:PV_r:PVC,2),...
        %         round(size(T_R,2)/2),z)
        %     hold on;hist([data0_up,data0_down]);xlim(xr)
        % end
        if mod(t, 2) == 1
            z=z+1;
            figure(63)
            subplot(4,6,z)
            hold on;
            hist([data2,data3]);xlim(xr)
        end
        
%         % 正規分布ではないため，定義集を採用。参考https://www.occto.or.jp/iinkai/chouseiryoku/2016/files/chousei_jukyu_06_04.pdf
        LFC5_3sigma_up=prctile(data0_up,99.73+(100-99.73)/2); % 99.73+(100-99.73)/2
        LFC5_2sigma_up=prctile(data0_up,95.45+(100-95.45)/2); % 95.45+(100-95.45)/2
        LFC5_1sigma_up=prctile(data0_up,68.27+(100-68.27)/2); % 68.27+(100-68.27)/2
        LFC5_1sigma_n_up=[LFC5_1sigma_n_up;LFC5_1sigma_up];
        LFC5_2sigma_n_up=[LFC5_2sigma_n_up;LFC5_2sigma_up];
        LFC5_3sigma_n_up=[LFC5_3sigma_n_up;LFC5_3sigma_up];
        
        LFC5_3sigma_down=prctile(data0_down,99.73); % 99.73
        LFC5_2sigma_down=prctile(data0_down,95.45); % 95.45+(100-95.45)/2
        LFC5_1sigma_down=prctile(data0_down,68.27); % 68.27+(100-68.27)/2
        LFC5_1sigma_n_down=[LFC5_1sigma_n_down;LFC5_1sigma_down];
        LFC5_2sigma_n_down=[LFC5_2sigma_n_down;LFC5_2sigma_down];
        LFC5_3sigma_n_down=[LFC5_3sigma_n_down;LFC5_3sigma_down];
    end
    % 行: 時間断面，列: 予測PV出力幅
    LFC5_sigma1_up=[LFC5_sigma1_up,LFC5_1sigma_n_up];
    LFC5_sigma2_up=[LFC5_sigma2_up,LFC5_2sigma_n_up];
    LFC5_sigma3_up=[LFC5_sigma3_up,LFC5_3sigma_n_up];
    
    LFC5_sigma1_down=[LFC5_sigma1_down,LFC5_1sigma_n_down];
    LFC5_sigma2_down=[LFC5_sigma2_down,LFC5_2sigma_n_down];
    LFC5_sigma3_down=[LFC5_sigma3_down,LFC5_3sigma_n_down];
end