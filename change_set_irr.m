irr_data=irr_data*24/1000;
for mode = 1:5
    hantei = max(irr_data);
    hantei(isnan(hantei))=10^10; % 欠損日は排除
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
            %% 自動計算
            delta = (360/2/pi)*(0.006918-0.399912*cos(deg2rad(x))+0.070257*sin(deg2rad(x))-...
                0.006758*cos(2*deg2rad(x))+0.000908*sin(2*deg2rad(x))); % 赤緯[deg]
            Isc = 1.382; % 太陽定数[kW/m2]
            omega_s = acos(-tan(deg2rad(fai))*tan(deg2rad(delta))); % 日没時の時角
            %% Step1: 水平面全天日射量
            Hbar = irr_data; % 水平面全天日射量[KWh/m2/day]
            Eo = 1.00011+0.034221*cos(deg2rad(x))+0.00128*sin(deg2rad(x))+0.000719*cos(2*deg2rad(x))+0.000077*sin(2*deg2rad(x));
            Ho = 24/pi*Isc*Eo*(omega_s*sin(deg2rad(delta))*sin(deg2rad(fai))+cos(deg2rad(delta))*cos(deg2rad(fai))*sin(omega_s));% 大気外水平面日射量[KWh/m2/day]
            I_Io = Hbar/Ho;
            %% Step2: 直散分離
            I_Io1=(I_Io<=0.22);
            I_Io1=(1-0.9*I_Io).*I_Io1;
            I_Io2a=(I_Io>0.22);I_Io2b=(I_Io<=0.8);I_Io2=I_Io2a.*I_Io2b;
            I_Io2=(0.9511-0.1604*I_Io+4.388.*(I_Io.^2)-16.6338.*(I_Io.^3)+12.336.*(I_Io.^4)).*I_Io2;
            I_Io3=(I_Io>0.8);
            I_Io3=0.165.*I_Io3;
            I_Io=I_Io1+I_Io2+I_Io3;
            I_d=Hbar.*I_Io;
            I_b=Hbar.*(1-I_Io);
            %% Step3: 斜面日射量の推定
            % 直達成分
            Et = 0.0172+0.4281.*cos(deg2rad(x))-7.3515.*sin(deg2rad(x))-...
                3.3495.*cos(2.*deg2rad(x))-9.3619.*sin(2.*deg2rad(x)); % 均時差[min]
            Et_omega = Et/60; % 均時差[hr]
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
                % 直達成分
                I_b = I_b.*rbbar;
                I_b(I_b<=0)=0;
                % 散乱成分
                I_d = I_d.*(1+cos(deg2rad(keisha_kaku(m))))/2;
                I_d(I_d<=0)=0;
                % 反射成分
                I_sanran = Hbar.*0.3*(1-cos(deg2rad(keisha_kaku(m))))/2;
                I_sanran(I_sanran<=0)=0;
            else
                % 直達成分
                I_b = I_b.*rbbar;
                I_b(I_b<=0)=0;
                % 散乱成分
                kaku=[90:-(70)/(find(Hbar==max(Hbar))-1):20,20:(70)/(24-find(Hbar==max(Hbar))-1):90];
                I_d = I_d.*(1+cos(deg2rad(kaku)))/2;
                I_d(I_d<=0)=0;
                % 反射成分
                I_sanran = Hbar.*0.3.*(1-cos(deg2rad(kaku)))/2;
                I_sanran(I_sanran<=0)=0;
                if mode == 5
                    I_d=I_d*1.3;
                    I_sanran=I_sanran*1.3;
                end
            end           

            I = I_b+I_sanran+I_d;

            irr = [irr,I'];
        end
        if mode == 1
            irr(:,1)=irr(:,1);
        elseif mode == 2 || mode == 3
            if mode == 2
                irr = irr(:,2)*0.7+irr(:,3);
            elseif mode == 3
                irr = irr(:,2)+irr(:,3)*0.7;
            end
        elseif mode == 4 || mode == 5
            irr = irr(:,2);
        end
        irr(irr<=0)=0;
        irr = irr/24*1000;
        %% まとめ
        irr_area(:,mode) = irr;
    else
    end
end