%%%%%%%%%%% 設置方法の設定 %%%%%%%%%%%
set=1;

%%%%%%%%%%% MSMの予測日射強度から予測PV出力へ変換 %%%%%%%%%%%
cd('MSM→予測PV出力')
make_PVF
cd ..
  %%% →→→ ここで，予測PV出力（1秒値）は，"PV_forecast_year"%%%%%%%%%%%

%%%%%%%%%%% PV300の実測日射強度から実測PV出力へ変換 %%%%%%%%%%%
cd('PV300→実測PV出力')
load(['PVO_mode',num2str(set),'.mat'])
cd ..
  %%% →→→ ここで，実測PV出力（1秒値）は，"PV_Out"%%%%%%%%%%%

%%%%%%%%%%% PV出力予測誤差（予測値－実測値） %%%%%%%%%%%
PV_error=PV_forecast_year-PV_Out;

    %%%%%%%%%%% (1行 362×86400列)→86400行 362列へ変換
    PV_error=reshape(PV_error,[86400,362]);
    PV_forecast_year=reshape(PV_forecast_year,[86400,362]);
    PV_Out=reshape(PV_Out,[86400,362]);

%%%%%%%%%%% 実行 %%%%%%%%%%%
PV_range=200;        % PV出力幅: 200MW
T_R=6:18;            % 時間帯: 6時から18時
T=3600;              % 時間窓：1時間（3600秒）
mu_sigma=[];         % 正規分布の平均値と標準偏差を収納するための行列
m=0;x=0;             % 決定指標

for pvr=1:ceil(max(max(PV_Out))/PV_range) % 年間最大PV出力まで考慮できる
    PVR_lim=PV_range*pvr;                 % PV出力上限値
    for t = T_R
        m=m+1;
        
        data_error=PV_error(T*(t-1)+1:T*t,:);        % PV出力予測誤差
        data_pvf=PV_forecast_year(T*(t-1)+1:T*t,:);  % 予測PV出力
        ok=(data_pvf<=PVR_lim);                      % PV出力上限値以下かどうか
        data_error=data_error.*ok;                   % 下限値を満たすPV出力予測誤差
        
        jokyo_error=0.1;                             % 除去部分はここで選択
        n=(data_error<jokyo_error).*...
            (data_error>-jokyo_error);
        data_error(find(n==1))=[];
        
        KAKURITUBU_BUNNPU1(1,data_error,'b',0,[],[]) % 正規分布に基づく平均値と標準偏差算出
        figure(12);subplot(ceil(max(max(PV_Out))/PV_range),length(T_R),m)
        hold on;histogram(line_data.data,'Normalization','probability');
        
        g=gca;x=max(x,max(abs(g.XLim)));             % 全てのケースにおける最大のx軸の値を算出
        
        global pd
        mu_sigma=[mu_sigma;[pd.mu,pd.sigma]];
    end
end

m=0;
for pvr=1:ceil(max(max(PV_Out))/PV_range) % 年間最大PV出力まで考慮できる
    for t = T_R
        m=m+1;
        figure(12);subplot(ceil(max(max(PV_Out))/PV_range),length(T_R),m)
        xlim([-x,x])
        if m <= 13
            title([num2str(t),':00',char(10),...
                'μ:',num2str(round(mu_sigma(m,1),1)),...
                ', σ:',num2str(round(mu_sigma(m,2),1))])
        else
            title(['μ:',num2str(round(mu_sigma(m,1),1)),...
                ', σ:',num2str(round(mu_sigma(m,2),1))])
            
        end
        if rem(m,13)==1
            ylabel(['PV出力幅 ',num2str(PV_range*pvr),'MW以下'])
        end
    end
end