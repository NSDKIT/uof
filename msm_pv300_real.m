clear
delete('*.mat')
%%%%%%%%%%%%%%%% 遒ｺ隱堺ｺ矩�� %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % 逋ｺ髮ｻ險育判繝�繝ｼ繝ｫ縺ｯ髢峨§縺ｦ縺�繧九°縲�
% % 豌苓ｱ｡蠎√°繧峨�ｮ繝�繝ｼ繧ｿ(Z__C_RJTD_yyyymmddT9700_MSM_GPV_Rjp_Lsurf_FH16-33_grib2.bin)繧偵ム繧ｦ繝ｳ繝ｭ繝ｼ繝峨＠縺溘°縲�
% % 蜑肴律莠域ｸｬ縺ｯ縲悟燕譌･縺ｮ蛻晄悄譎ょ綾 06:00(UTC)縺ｮ繝�繝ｼ繧ｿ�ｼ薙▽�ｼ域凾髢馴俣髫費ｼ�00~15,16~33,34~39�ｼ会ｼ峨�阪ｒ繝�繧ｦ繝ｳ繝ｭ繝ｼ繝峨��
% % ex) [year month day]=[2018 4 1]繧帝∈謚槭＠縺溷�ｴ蜷�
% %     豌苓ｱ｡蠎√�ｮ繝�繝ｼ繧ｿ縺ｧ縲�2018/4/1 09:00縲降縲�2018/4/3 08:30縲阪∪縺ｧ縺ｮ莠域ｸｬ繝�繝ｼ繧ｿ縺悟ｾ励ｉ繧後ｋ縲�
% %     縲�4/2 00:00~23:30縲阪�ｮ譎る俣蟶ｯ�ｼ後▽縺ｾ繧� 2018/4/2 縺ｮ繧ｷ繝溘Η繝ｬ繝ｼ繧ｷ繝ｧ繝ｳ繧定｡後≧縲�
% %% 繝｢繝ｼ繝蛾∈謚�
% mode = 1; % 1: 蠕捺擂謇区ｳ�
%           % 2: 邱壼ｽ｢謇区ｳ�
%           % 3: 邨ｱ險域焔豕�
%           % 4: 讖滓｢ｰ蟄ｦ鄙呈焔豕�
for day = 2:30
    %% 繝�繝ｼ繧ｿ驕ｸ謚�
    year = 2019;
    month = 6;
    save('YMD.mat','year','month','day')
    for  lfc = 8
        for mode = 1:3
            save('mode.mat','mode')
           %% 蟷ｴ譛域律縺ｮ險ｭ螳壹�ｻ菫晏ｭ�
           %% 繝�繝ｼ繧ｿ驕ｸ謚�
            load('YMD.mat')
            new_dataload
        %% 繧ｷ繝溘Η繝ｬ繝ｼ繧ｷ繝ｧ繝ｳ螳溯｡碁幕蟋�
            for PVC = 1100
                save('PVC.mat','PVC')
                %% 譌･蟆�驥上�ｮ謚ｽ蜃ｺ
                cd 莠域ｸｬPV蜃ｺ蜉帑ｽ懈��
                %% 蟷ｴ譛域律繧帝∈謚�
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        if year == 2018
                            E_D = [31,28,31,30,31,30,31,31,30,31,30,31];
                        elseif year == 2019
                            E_D = [31,29,31,30,31,30,31,31,30,31,30,31];
                        end
                        if day == 1
                            if month == 1
                                Month = 12;
                                Day = 31;
                            else
                                Month = month-1;
                                Day = E_D(month-1);
                            end
                        else
                            Month = month;
                            Day = day-1;
                        end
                        if Month > 3
                            Year = year;
                        else
                            Year = year+1;
                        end
                        %% .bin繝輔ぃ繧､繝ｫ蜿門ｾ�
                        search1
                        %% 蜷�繧ｨ繝ｪ繧｢縺ｮ豌ｴ蟷ｳ髱｢蜈ｨ螟ｩ譌･蟆�驥丞叙蠕�
                        TDBTDB
                        irr_forecast=irr_forecast(2:end,:);
                        data = irr_forecast;
                        %% PV髱｢譌･蟆�驥上∈螟画鋤
                        MSM_change
                        MSM=IRR.sum;
                        save MSM.mat MSM                        
                        load(['../蝓ｺ譛ｬ繝�繝ｼ繧ｿ/PV_base_',num2str(Year),'.mat'])
                        PV_base=[PV_base(end-2:end,3)',PV_base(1:end-3,3)'];
                        PV_base=1100*ones(1,12);
                        %% 繧ｷ繧ｹ繝�繝�蜃ｺ蜉帑ｿよ焚
                        PR=[1,1,1,...
                            1,1,0.718269393,...
                            1,1,1,...
                            1,1,1];
                        load(['../蝓ｺ譛ｬ繝�繝ｼ繧ｿ/PR_',num2str(Year),'.mat'])
                        
                        %% MSM縺ｮ蛟肴焚菫よ焚
                        MSM_bai=[1,1,1,...
                            1,1,1.092537313,...
                            1,1,1,...
                            1,1,1];
                        load(['../蝓ｺ譛ｬ繝�繝ｼ繧ｿ/MSM_bai_',num2str(Year),'.mat'])
                        %% PV髱｢譌･蟆�蠑ｷ蠎ｦ縺九ｉPV莠域ｸｬ蜃ｺ蜉帙∈螟画鋤
                        l=size(IRR.sum);
                        IRR.sum = [IRR.sum;zeros(2,l(2))];
                        load('../PVC.mat')
                        load('../mode.mat')
                        % -- all change --
%                         if mode == 1
                            PVF_30min=IRR.sum*MSM_bai(Month)*PR(Month)*PV_base(Month)/1000;
%                         else
%                             PVF_30min=IRR.sum(:,2)*MSM_bai(Month)*PR(Month)*PV_base(Month)/1000;
%                         end
                        PVF_30min=PVF_30min*PVC/PV_base(Month);
                        clearvars -except PVF_30min PR PV_base
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                cd ..

                %% PV菴懈��
                cd('PV螳溷�ｺ蜉帑ｽ懈��')
                load('../YMD.mat');load('../PVC.mat');
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                %% 2018蟷ｴ蠎ｦ譌｢險ｭPV螳ｹ驥�
%                     load(['../蝓ｺ譛ｬ繝�繝ｼ繧ｿ/PV_base_',num2str(year),'.mat'])
%                     PV_base=[PV_base(end-2:end,3)',PV_base(1:end-3,3)'];
                    %% 繧ｷ繧ｹ繝�繝�蜃ｺ蜉帑ｿよ焚
                    PR=PR;
                    %% 蟷ｴ譛域律繧帝∈謚�
                    Month = month;
                    Day = day;
                    if Month > 3
                        Year = year;
                    else
                        Year = year+1;
                    end
                    % 譌･逡ｪ蜿ｷ
                    clear day month year
                    t_target = datetime(Year,Month,Day);day_num = day(t_target); %隗｣譫仙ｯｾ雎｡譌･縺ｮ譌･莉倡分蜿ｷ繧貞叙蠕�
                    % 譛育分蜿ｷ
                    if Month < 4
                        month_num=Month+9;
                    else
                        month_num=Month-3;
                    end
                    cd PV300\1遘貞�､
                    %% 邱ｯ蠎ｦ邨悟ｺｦ縺ｮ蜿門ｾ�
                    load('ido_keido.mat')
                    IDO = ido;KEIDO = keido;
                    IRR.sum=0;
                    %% 繝代Λ繝｡繝ｼ繧ｿ險ｭ螳�
                    % 蛯ｾ譁懆ｧ定ｨｭ螳壽凾縺ｫ3ﾃ�3驟榊�励ｒ菴懈�舌＠�ｼ後Δ繝ｼ繝峨↓蟇ｾ蠢懊☆繧�(荳�霆ｸ霑ｽ蟆ｾ縺ｯ蛯ｾ譁懆ｧ帝未菫ゅ↑縺�)
                    keisha_kaku = [20;90;90]; % 2陦檎岼縺ｯ荳｡髱｢譚ｱ繝ｻ隘ｿ(m:2,3)
                    % 譁ｹ隗定ｨｭ螳壽凾縺ｫ3ﾃ�3驟榊�励ｒ菴懈�舌＠�ｼ後Δ繝ｼ繝峨↓蟇ｾ蠢懊☆繧�(荳�霆ｸ霑ｽ蟆ｾ縺ｯ譁ｹ隗帝未菫ゅ↑縺�)
                    hougaku = [0;90;270]; % 2陦檎岼縺ｯ荳｡髱｢譚ｱ(m:2)�ｼ�3陦檎岼縺ｯ荳｡髱｢隘ｿ(m:3)
                    % 譎ょ綾譁ｭ髱｢
                    t=[1:24]-0.5;
                    % UTC縺ｫ蟇ｾ縺吶ｋ譎ょｷｮ險ｭ螳壽凾縺ｫ5ﾃ�3驟榊�励ｒ菴懈�舌＠�ｼ後Δ繝ｼ繝峨↓蟇ｾ蠢懊☆繧�
                    jisa = [9*ones(1,4),9-12];
                    data = zeros(86400,17);
                    for area = 1:17
                        %% PV300縺ｮ蜿門ｾ�
                        pv300 = get_PV300_1sec(['area',num2str(area),'\',num2str(Year),'_',num2str(Month),'\day',num2str(Day),'.csv']);
                        data(1:length(pv300),area)=pv300;
                    end
                    data = sum(data')/1000; % W竍談W
                    cd ../..
                    load('../mode.mat')
                    if mode == 1
                        MODE = 1;
                    elseif mode == 2 || mode == 3
                        MODE = 1:3;
                    elseif mode == 4 || mode == 5
                        MODE = [1,4];
                    end
                    load('../PVC.mat')
                    for area = 1:17
                        %% PV300縺ｮ蜿門ｾ�
                        data = zeros(1,86400);
                        pv300 = get_PV300_1sec(['area',num2str(area),'\',num2str(Year),'_',num2str(Month),'\day',num2str(Day),'.csv']);
                        data(1:length(pv300))=pv300*24/1000; % W竍談W竍談Wh
                        data=data(1:86400);
                        irr = [];
                        for m = MODE
                            fai = IDO(area); % 邱ｯ蠎ｦ
                            fai = fix(fai)+(fai-fix(fai))*100/60; % 邱ｯ蠎ｦ縺ｮ譖ｴ譁ｰ
                            keido = KEIDO(area); % 邨悟ｺｦ    
                            keido = fix(keido)+(keido-fix(keido))*100/60; % 邨悟ｺｦ縺ｮ譖ｴ譁ｰ
                            %% 譌･莉倡分蜿ｷ縺ｮ蜿門ｾ�
                            t_target = datetime(Year,Month,Day);
                            day_num = day(t_target,'dayofyear'); %隗｣譫仙ｯｾ雎｡譌･縺ｮ譌･莉倡分蜿ｷ繧貞叙蠕�
                            x = (day_num-1)*360/365; % n: 蜈�譌ｦ繧�1縺ｨ縺励◆蟷ｴ髢捺律莉倥�ｮ騾壹＠逡ｪ蜿ｷ[deg]
                            % 
                            delta = (360/2/pi)*(0.006918-0.399912*cos(deg2rad(x))+0.070257*sin(deg2rad(x))-...
                                0.006758*cos(2*deg2rad(x))+0.000908*sin(2*deg2rad(x))); % 襍､邱ｯ[deg]
                            Isc = 1.382; % 螟ｪ髯ｽ螳壽焚[kW/m2]
                            omega_s = acos(-tan(deg2rad(fai))*tan(deg2rad(delta))); % 譌･豐｡譎ゅ�ｮ譎りｧ�
                            %% Step1: 豌ｴ蟷ｳ髱｢蜈ｨ螟ｩ譌･蟆�驥�(??????)
                            Hbar = data; % 豌ｴ蟷ｳ髱｢蜈ｨ螟ｩ譌･蟆�驥充KWh/m2/day]
                            h=[];
                            for t0=1:24
                                h=[h,Hbar(3600*t0-1800)];
                            end
                            Hbar=h;
                            Eo = 1.00011+0.034221*cos(deg2rad(x))+0.00128*sin(deg2rad(x))+0.000719*cos(2*deg2rad(x))+0.000077*sin(2*deg2rad(x));
                            Ho = 24/pi*Isc*Eo*(omega_s*sin(deg2rad(delta))*sin(deg2rad(fai))+cos(deg2rad(delta))*cos(deg2rad(fai))*sin(omega_s));% 螟ｧ豌怜､匁ｰｴ蟷ｳ髱｢譌･蟆�驥充KWh/m2/day]
                            I_Io = Hbar/Ho;
                            %% Step2: 逶ｴ謨｣蛻�髮｢
                            I_Io1=(I_Io<=0.22);
                            I_Io1=(1-0.9*I_Io).*I_Io1;
                            I_Io2a=(I_Io>0.22);I_Io2b=(I_Io<=0.8);I_Io2=I_Io2a.*I_Io2b;
                            I_Io2=(0.9511-0.1604*I_Io+4.388.*(I_Io.^2)-16.6338.*(I_Io.^3)+12.336.*(I_Io.^4)).*I_Io2;
                            I_Io3=(I_Io>0.8);
                            I_Io3=0.165.*I_Io3;
                            I_Io=I_Io1+I_Io2+I_Io3;
                            I_d=Hbar.*I_Io;
                            I_b=Hbar.*(1-I_Io);
                            %% Step3: 譁憺擇譌･蟆�驥上�ｮ謗ｨ螳�
                            % 逶ｴ驕疲�仙��
                            Et = 0.0172+0.4281.*cos(deg2rad(x))-7.3515.*sin(deg2rad(x))-...
                                3.3495.*cos(2.*deg2rad(x))-9.3619.*sin(2.*deg2rad(x)); % 蝮�譎ょｷｮ[min]
                            Et_omega = Et/60; % 蝮�譎ょｷｮ[hr]
                            omega_1min = -(12-(t)-keido.*24/360+jisa(m)-Et_omega).*15;
                            if m <= 3
                                cos_site = +(sin(deg2rad(fai))*cos(deg2rad(keisha_kaku(m)))-cos(deg2rad(fai))*sin(deg2rad(keisha_kaku(m)))*cos(deg2rad(hougaku(m))))*sin(deg2rad(delta))+...
                                    (cos(deg2rad(fai))*cos(deg2rad(keisha_kaku(m)))+sin(deg2rad(fai))*sin(deg2rad(keisha_kaku(m)))*cos(deg2rad(hougaku(m))))*cos(deg2rad(delta))*cos(deg2rad(omega_1min))+...
                                    cos(deg2rad(delta))*sin(deg2rad(keisha_kaku(m)))*sin(deg2rad(hougaku(m)))*sin(deg2rad(omega_1min));
                            elseif m >= 4
                                cos_site = cos(asin(cos(deg2rad(fai)).*sin(deg2rad(delta))-sin(deg2rad(fai)).*cos(deg2rad(omega_1min)).*cos(deg2rad(delta))));
                            end
                            cos_site_z = +sin(deg2rad(fai)).*sin(deg2rad(delta))+cos(deg2rad(fai)).*cos(deg2rad(delta)).*cos(deg2rad(omega_1min));
                            rbbar = +cos_site./cos_site_z;
                            rbbar(find(round(cos_site_z,2)<=0))=0;
                            if m < 4
                                % 逶ｴ驕疲�仙��
                                I_b = I_b.*rbbar;
                                I_b(I_b<=0)=0;
                                % 謨｣荵ｱ謌仙��
                                I_d = I_d.*(1+cos(deg2rad(keisha_kaku(m))))/2;
                                I_d(I_d<=0)=0;
                                % 蜿榊ｰ�謌仙��
                                I_sanran = Hbar.*0.3*(1-cos(deg2rad(keisha_kaku(m))))/2;
                                I_sanran(I_sanran<=0)=0;
                            else
                                % 逶ｴ驕疲�仙��
                                I_b = I_b.*rbbar;
                                I_b(I_b<=0)=0;
                                % 謨｣荵ｱ謌仙��
                                kaku=[90:-(70)/(min(find(Hbar==max(Hbar)))-1):20,20:(70)/(24-min(find(Hbar==max(Hbar)))-1):90];
                                I_d = I_d.*(1+cos(deg2rad(kaku)))/2;
                                I_d(I_d<=0)=0;
                                % 蜿榊ｰ�謌仙��
                                I_sanran = Hbar.*0.3.*(1-cos(deg2rad(kaku)))/2;
                                I_sanran(I_sanran<=0)=0;
                                load('../mode.mat')
                                if mode == 5
                                    I_d=I_d*1.3;
                                    I_sanran=I_sanran*1.3;
                                end
                            end

                            I = I_b+I_sanran+I_d;

                            x = 1:24;xq_1min = 1/3600:1/3600:24;v=I;
                            I = interp1(x,v,xq_1min);
                            I=[zeros(1,3600),I(3601:end)];
                            I=I*PVC/PV_base(Month);
                            I(I<=0)=0;

                            %% 遏ｭ蜻ｨ譛溷､牙虚謌仙��
                            if m == 1
                                d0 = data; % kW
                                d1 = Hbar; % kW
                                x = 1:24;xq_1min = 1/3600:1/3600:24;v=d1;
                                d1 = interp1(x,v,xq_1min);
                                d1(isnan(d1))=0;
                                d1=[d1(1:end)];
                                short_f = (d0-d1)';
                                short_f = [zeros(3600,1);short_f(1:end-3600)]; % kW
                                save('short_f.mat','short_f')
                            end
                            irr = [irr,I'];
                        end
                        load('short_f.mat')
                        load('../mode.mat')
                        if mode == 1
                            irr(:,1)=irr(:,1)+short_f;
                        elseif mode == 2 || mode == 3
                            if mode == 2
                                irr = [irr(:,1),irr(:,2)*0.7+irr(:,3)];
                            elseif mode == 3
                                irr = [irr(:,1),irr(:,2)+irr(:,3)*0.7];
                            end
                            %% 60遘貞捉譛溷､牙虚霑ｽ蜉�
                            curve=(irr(:,2)./irr(:,1));
                            curve(isnan(curve))=0;
                            irr(:,1)=irr(:,1)+short_f;
                            irr(:,2)=irr(:,2)+short_f.*curve;
                        elseif mode == 4 || mode == 5
                            %% 60遘貞捉譛溷､牙虚霑ｽ蜉�
                            curve=(irr(:,2)./irr(:,1));
                            curve(isnan(curve))=0;
                            irr(:,1)=irr(:,1)+short_f;
                            irr(:,2)=irr(:,2)+short_f.*curve;
                        end
                        irr = irr/24*1000;
                        irr(1:3600*4,:)=0;
                        irr(3600*20:end,:)=0;
                        irr(irr<=0)=0;
                        
                        
                        %% 縺ｾ縺ｨ繧�
                        IRR.sum = IRR.sum+irr;
                    end
                    IRR.sum = IRR.sum/17;
                    
                    PV300=IRR.sum;
                    save PV300.mat PV300
                    
                    if mode == 1
                        PV_1sec = IRR.sum*PR(Month)*PV_base(Month)/1000;
                    else
                        PV_1sec = IRR.sum(:,2)*PR(Month)*PV_base(Month)/1000;
                    end
                    
                    clearvars -except PVF_30min PV_1sec PVC PV_base
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                load('../YMD.mat');load('../PVC.mat');
                Month =month;Day=day;Year=year;
                clear year month day
                %% 蛹鈴匣繧ｨ繝ｪ繧｢PV蜃ｺ蜉帛ｮ滓ｸｬ蛟､縺ｮ謚ｽ蜃ｺ
%                     PV_real=csv_tieline_PV2019('蛹鈴匣繧ｨ繝ｪ繧｢Pv蜃ｺ蜉�2019');
%                     PV_real=table2array(PV_real(2:end,3));
%                     PV_real(isnan(PV_real))=[];
%                     %% 譌･莉倡分蜿ｷ縺ｮ蜿門ｾ�
%                     t_331 = datetime(Year,3,31);dn = day(t_331,'dayofyear'); %3譛�31譌･縺ｮ譌･莉倡分蜿ｷ繧貞叙蠕�
%                     t_target = datetime(Year,Month,Day);dn = day(t_target,'dayofyear')-dn; %隗｣譫仙ｯｾ雎｡譌･縺ｮ譌･莉倡分蜿ｷ繧貞叙蠕�
%                     %% 隗｣譫仙ｯｾ雎｡譌･縺ｮPV螳溽ｸｾ蛟､縺ｮ蜿門ｾ�
%                     Pv_out=PV_real(1440*(dn-1)+1:1440*dn,:)*PVC/PV_base(Month);
                    
%                     clearvars -except MSM PV300 Pv_out Day
                    clearvars -except PVF_30min PV_1sec Pv_out Day Month Year
                cd ..
               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
               load('mode.mat')
               if mode ~= 1
                   inter_86400(PVF_30min(:,2))
               else
                   inter_86400(PVF_30min)
               end
               PVF_30min=data';
%                inter_86400(Pv_out)
%                Pv_out=data';
               load(['蝓ｺ譛ｬ繝�繝ｼ繧ｿ/PV_base_',num2str(Year),'.mat'])
               PV_base=[PV_base(end-2:end,3)',PV_base(1:end-3,3)'];
%                Pv_out=Pv_out*1100/PV_base(Month);
               
               figure(13)
               hold on;subplot(5,7,Day);plot(PVF_30min)
               hold on;plot(PV_1sec)
%                plot(Pv_out)
%                legend({num2str([max(PVF_30min);max(PV_1sec);max(Pv_out)])})
            end
        end
    end
end