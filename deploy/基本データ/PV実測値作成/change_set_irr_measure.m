irr_hol=data*24/1000;
irr_data=irr_data*24/1000;

for mode = 1:5
    hantei = max(irr_data);
    hantei(isnan(hantei))=10^10; % 谺�謳肴律縺ｯ謗帝勁
    if hantei ~= 10^10
        irr = [];
        if mode == 1
            MODE = 1;
        elseif mode == 2 || mode == 3
            MODE = 1:3;
        elseif mode == 4 || mode == 5
            MODE = [1,4];
        end
        for m = MODE
            %% 閾ｪ蜍戊ｨ育ｮ�
            delta = (360/2/pi)*(0.006918-0.399912*cos(deg2rad(x))+0.070257*sin(deg2rad(x))-...
                0.006758*cos(2*deg2rad(x))+0.000908*sin(2*deg2rad(x))); % 襍､邱ｯ[deg]
            Isc = 1.382; % 螟ｪ髯ｽ螳壽焚[kW/m2]
            omega_s = acos(-tan(deg2rad(fai))*tan(deg2rad(delta))); % 譌･豐｡譎ゅ�ｮ譎りｧ�
            %% Step1: 豌ｴ蟷ｳ髱｢蜈ｨ螟ｩ譌･蟆�驥�
            Hbar = irr_data; % 豌ｴ蟷ｳ髱｢蜈ｨ螟ｩ譌･蟆�驥充KWh/m2/day]
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
                kaku=[90:-(70)/(find(Hbar==max(Hbar))-1):20,20:(70)/(24-find(Hbar==max(Hbar))-1):90];
                I_d = I_d.*(1+cos(deg2rad(kaku)))/2;
                I_d(I_d<=0)=0;
                % 蜿榊ｰ�謌仙��
                I_sanran = Hbar.*0.3.*(1-cos(deg2rad(kaku)))/2;
                I_sanran(I_sanran<=0)=0;
                if mode == 5
                    I_d=I_d*1.3;
                    I_sanran=I_sanran*1.3;
                end
            end

            %% 遏ｭ蜻ｨ譛溷､牙虚謌仙��
            if m == 1
                irr_30min = Hbar; % kW
                x_t = 0:1/3600:24;
                irr_30min=interp1(0:23,irr_30min',x_t,'linear');
                
                irr_30min(isnan(irr_30min))=0;
                short_f = (irr_hol-irr_30min)';
                % short_f = [zeros(3600+1800,1);short_f(1:end-3600-1800)]; % kW
                save('short_f.mat','short_f')
            end

            I = I_b+I_sanran+I_d;
            x_t = 0:1/3600:24;
            I=interp1(0:23,I',x_t,'linear');

            irr = [irr,I'];
        end
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
        irr(irr<=0)=0;
        irr = irr/24*1000;
        %% 縺ｾ縺ｨ繧�
        irr_area(:,mode) = irr(:,end);
    else
    end
end