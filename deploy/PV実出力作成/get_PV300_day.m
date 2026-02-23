%% 2018蟷ｴ蠎ｦ譌｢險ｭPV螳ｹ驥�
PV_base=[960*ones(1,3),820*ones(1,3),840*ones(1,3),930*ones(1,3)];
%% 繧ｷ繧ｹ繝�繝�蜃ｺ蜉帑ｿよ焚
PR=[0.766479363,0.858951426,0.815903817,...
    0.773548507,0.881116739,0.755877971,...
    0.749511151,0.772063668,0.820792574,...
    0.775614821,0.980114197,1.026405428];
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
%% PV300縺ｮ蜿門ｾ�
cd(['PV300\',num2str(Year),'蟷ｴ蠎ｦ'])
data=get_PV300([num2str(Year),num2str(Month),'.xlsx']);
data=data(2:end,2:end);data(data<=0)=0;
data=data(1440*(day_num-1)+1:1440*day_num,:);
cd ../..
%% 邱ｯ蠎ｦ邨悟ｺｦ縺ｮ蜿門ｾ�
IK = get_ido_keido('ido_keido.xlsx');
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
for area = 1:19
    hantei = max(data(:,area));
    hantei(isnan(hantei))=10^10; % 谺�謳肴律縺ｯ謗帝勁
    if hantei ~= 10^10
        irr = [];
        load('../mode.mat')
        if mode == 1
            MODE = 1;
        elseif mode == 2 || mode == 3
            MODE = 1:3;
        elseif mode == 4
            MODE = [1,4];
        elseif mode == 5
            MODE = [1,5];
        end 
        for m = MODE
            fai = IK(area,1); % 邱ｯ蠎ｦ
            fai = fix(fai)+(fai-fix(fai))*100/60; % 邱ｯ蠎ｦ縺ｮ譖ｴ譁ｰ
            keido = IK(area,2); % 邨悟ｺｦ    
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
            %% Step1: 豌ｴ蟷ｳ髱｢蜈ｨ螟ｩ譌･蟆�驥�
            Hbar = sum(data','omitnan')/19./3600*60; % 豌ｴ蟷ｳ髱｢蜈ｨ螟ｩ譌･蟆�驥充KWh/m2/day]
            h=[];
            for t0=1:24
                h=[h,Hbar(60*t0-30)];
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
                kaku=[90:-(90)/(find(Hbar==max(Hbar))-1):0,0:(90)/(1440-find(Hbar==max(Hbar))-1):90];
                I_d = I_d.*(1+cos(deg2rad(30)))/2;
                I_d(I_d<=0)=0;
                % 蜿榊ｰ�謌仙��
                I_sanran = Hbar.*0.3.*(1-cos(deg2rad(30)))/2;
                I_sanran(I_sanran<=0)=0;
            end           

            I = I_b+I_sanran+I_d;

            x = 1:24;xq_1min = 1/60:1/60:24;v=I;
            I = interp1(x,v,xq_1min);
            I=[zeros(1,60),I(61:end)];

            %% 遏ｭ蜻ｨ譛溷､牙虚謌仙��
            if m == 1
                d0 = (sum(data','omitnan')/19/3600*60)';
                d1 = [];
                for t0 = 1:24
                    d1 = [d1,d0(60*t0)];
                end
                x = 1:24;xq_1min = 1/60:1/60:24;v=d1;
                d1 = interp1(x,v,xq_1min);
                d1=[zeros(1,60),d1(61:end)];
                short_f = (d0-d1');
                save('short_f.mat','short_f')
            end
            I(I<=0)=0;
            irr = [irr,I'];
        end
        load('short_f.mat')
        load('../mode.mat')
        if mode == 1
            irr(:,1)=irr(:,1)+short_f;
            irr(irr<=0)=0;
            irr = irr/19/60*3600;
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
            irr(irr<=0)=0;
            irr = irr/19/60*3600;
        elseif mode == 4 || mode == 5
            if mode == 4
            elseif mode == 3
                irr = [irr(:,1),irr(:,2)+irr(:,3)*0.3];
            end
            %% 60遘貞捉譛溷､牙虚霑ｽ蜉�
            curve=(irr(:,2)./irr(:,1));
            curve(isnan(curve))=0;
            irr(:,1)=irr(:,1)+short_f;
            irr(:,2)=irr(:,2)+short_f.*curve;
            irr(irr<=0)=0;
            irr = irr/19/60*3600;
        end
        %% 縺ｾ縺ｨ繧�
        collect_irr
        IRR.sum = IRR.sum+irr;
    else
    end
end
%% PV髱｢譌･蟆�蠑ｷ蠎ｦ縺九ｉPV蜃ｺ蜉帙∈螟画鋤
load('../mode.mat')
if mode == 1
    PV_1min = IRR.sum*PR(Month)*PV_base(Month)/1000;
else
    PV_1min = IRR.sum(:,2)*PR(Month)*PV_base(Month)/1000;
end
save PV_1min.mat PV_1min