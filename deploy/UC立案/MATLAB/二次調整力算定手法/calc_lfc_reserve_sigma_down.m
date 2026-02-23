%% 気象解析(統計データ作成)
% -- 時間幅 --
T_R=1:48;T=1;
% 予測PV出力幅
% PVC=1100;
N_gen=5;
PV_r=PVC/N_gen;
% PV_r=200;
PVF_r_low=-PV_r;

LFC5_sigma1=[];LFC5_sigma2=[];LFC5_sigma3=[];

m=0;z=0;
for n=PV_r:PV_r:PVC
    m=m+1;
    
    % 予測PV出力幅の下限値，上限値
%     PVF_r_low=PVF_r_low+PV_r;
%     PVF_r_up=PVF_r_low+PV_r;
    PVF_r_low=0;
    PVF_r_up=n;
    
    % 5分値: 予測PV出力の範囲抽出
    PVF5min_oxl=pvf>=PVF_r_low;
    PVF5min_oxu=pvf<PVF_r_up;
    PVF5min_ox=PVF5min_oxl.*PVF5min_oxu;
    
    LFC5_1sigma_n=[];LFC5_2sigma_n=[];LFC5_3sigma_n=[];
    
    for t = T_R
        if t == 14
            if m == 1
                1;
            end
        end
       %% LFC調整力
        % -- 5分変動(5分窓で最大値と最小値の差，藤田さんの卒論参考) --
        data1=PVF5min_ox(T*(t-1)+1:T*t,:); % 幅に入ってるかのバイナリ変数
        data2=LFC_5min_up(T*(t-1)+1:T*t,:);
        data3=LFC_5min_down(T*(t-1)+1:T*t,:);
        data0_up=data1.*data2;
        data0_up=reshape(data0_up,[1,T*362]);
        data0_down=data1.*data3;
        data0_down=reshape(data0_down,[1,T*362]);
        
        data0=[data0_up,data0_down];
        if sum(data0) ~= 0
            data0(find(data0==0))=[];
        end
        
        %%%%%%%%%%%%%%%%%%形状確認%%%%%%%%%%%%%%%%%%
%         if t == 24 || t == 25 || t == 26  % 時刻断面：11:30,12:30,12:30
%             if m == 2 || m == 3 || m == 4 % PV断面: 2,3,4
%                 z=z+1;
%                 figure(23);hold on
%                 subplot(3,3,z);hist(data0)
% %                 xlim([0,1000]);ylim([0,150])
% %                 for rate = 1
% %                     o_sfig(rate,[0,1000],[0,150],[],'','',['r',num2str(rate)],['動的手法\LFC妥当性\ヒストグラム'])
% %                     o_sfig(rate,[0,1000],[0,150],[],'','',['r',num2str(rate)],['動的手法\LFC妥当性\ヒストグラム'])
% %                 end
%             end
%         end
        
%         KAKURITUBU_BUNNPU1([],data0,'b',1,[],[])
%         global pd
%         LFC5_3sigma=pd.mu+3*pd.sigma; % 99.73
%         LFC5_2sigma=pd.mu+2*pd.sigma; % 95.45+(100-95.45)/2
%         LFC5_1sigma=pd.mu+1*pd.sigma; % 68.27+(100-68.27)/2
        
        
        % 正規分布ではないため，定義集を採用。参考https://www.occto.or.jp/iinkai/chouseiryoku/2016/files/chousei_jukyu_06_04.pdf
%         LFC5_3sigma=prctile(data0,99.73); % 99.73
%         LFC5_2sigma=prctile(data0,97.73); % 95.45+(100-95.45)/2
%         LFC5_1sigma=prctile(data0,84.14); % 68.27+(100-68.27)/2
        
        LFC5_3sigma=prctile(data0,100-99.73); % 99.73
        LFC5_2sigma=prctile(data0,100-97.73); % 95.45+(100-95.45)/2
        LFC5_1sigma=prctile(data0,100-84.14); % 68.27+(100-68.27)/2
        LFC5_1sigma_n=[LFC5_1sigma_n;LFC5_1sigma];
        LFC5_2sigma_n=[LFC5_2sigma_n;LFC5_2sigma];
        LFC5_3sigma_n=[LFC5_3sigma_n;LFC5_3sigma];     
    end
    % 行: 時間断面，列: 予測PV出力幅
    
    LFC5_sigma1=[LFC5_sigma1,LFC5_1sigma_n];
    LFC5_sigma2=[LFC5_sigma2,LFC5_2sigma_n];
    LFC5_sigma3=[LFC5_sigma3,LFC5_3sigma_n];
end
LFC5_sigma1_down=LFC5_sigma1;
LFC5_sigma2_down=LFC5_sigma2;
LFC5_sigma3_down=LFC5_sigma3;