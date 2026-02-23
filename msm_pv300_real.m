clear
delete('*.mat')
cd C:\Users\PowerSystemLab\Desktop\01_研究資料\05_実行ファイル\program\全体実行
%%%%%%%%%%%%%%%% 確認事項 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % 発電計画ツールは閉じているか。
% % 気象庁からのデータ(Z__C_RJTD_yyyymmddT9700_MSM_GPV_Rjp_Lsurf_FH16-33_grib2.bin)をダウンロードしたか。
% % 前日予測は「前日の初期時刻 06:00(UTC)のデータ３つ（時間間隔（00~15,16~33,34~39））」をダウンロード。
% % ex) [year month day]=[2018 4 1]を選択した場合
% %     気象庁のデータで「2018/4/1 09:00」~「2018/4/3 08:30」までの予測データが得られる。
% %     「4/2 00:00~23:30」の時間帯，つまり 2018/4/2 のシミュレーションを行う。
% %% モード選択
% mode = 1; % 1: 従来手法
%           % 2: 線形手法
%           % 3: 統計手法
%           % 4: 機械学習手法
for day = 2:30
    %% データ選択
    year = 2019;
    month = 6;
    save('YMD.mat','year','month','day')
    for  lfc = 8
        for mode = 1:3
            save('mode.mat','mode')
           %% 年月日の設定・保存
           %% データ選択
            load('YMD.mat')
            new_dataload
        %% シミュレーション実行開始
            for PVC = 1100
                save('PVC.mat','PVC')
                %% 日射量の抽出
                cd 予測PV出力作成
                %% 年月日を選択
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
                        %% .binファイル取得
                        search1
                        %% 各エリアの水平面全天日射量取得
                        TDBTDB
                        irr_forecast=irr_forecast(2:end,:);
                        data = irr_forecast;
                        %% PV面日射量へ変換
                        MSM_change
                        MSM=IRR.sum;
                        save MSM.mat MSM                        
                        load(['../基本データ/PV_base_',num2str(Year),'.mat'])
                        PV_base=[PV_base(end-2:end,3)',PV_base(1:end-3,3)'];
                        PV_base=1100*ones(1,12);
                        %% システム出力係数
                        PR=[1,1,1,...
                            1,1,0.718269393,...
                            1,1,1,...
                            1,1,1];
                        load(['../基本データ/PR_',num2str(Year),'.mat'])
                        
                        %% MSMの倍数係数
                        MSM_bai=[1,1,1,...
                            1,1,1.092537313,...
                            1,1,1,...
                            1,1,1];
                        load(['../基本データ/MSM_bai_',num2str(Year),'.mat'])
                        %% PV面日射強度からPV予測出力へ変換
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

                %% PV作成
                cd('PV実出力作成')
                load('../YMD.mat');load('../PVC.mat');
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                %% 2018年度既設PV容量
%                     load(['../基本データ/PV_base_',num2str(year),'.mat'])
%                     PV_base=[PV_base(end-2:end,3)',PV_base(1:end-3,3)'];
                    %% システム出力係数
                    PR=PR;
                    %% 年月日を選択
                    Month = month;
                    Day = day;
                    if Month > 3
                        Year = year;
                    else
                        Year = year+1;
                    end
                    % 日番号
                    clear day month year
                    t_target = datetime(Year,Month,Day);day_num = day(t_target); %解析対象日の日付番号を取得
                    % 月番号
                    if Month < 4
                        month_num=Month+9;
                    else
                        month_num=Month-3;
                    end
                    cd PV300\1秒値
                    %% 緯度経度の取得
                    load('ido_keido.mat')
                    IDO = ido;KEIDO = keido;
                    IRR.sum=0;
                    %% パラメータ設定
                    % 傾斜角設定時に3×3配列を作成し，モードに対応する(一軸追尾は傾斜角関係なし)
                    keisha_kaku = [20;90;90]; % 2行目は両面東・西(m:2,3)
                    % 方角設定時に3×3配列を作成し，モードに対応する(一軸追尾は方角関係なし)
                    hougaku = [0;90;270]; % 2行目は両面東(m:2)，3行目は両面西(m:3)
                    % 時刻断面
                    t=[1:24]-0.5;
                    % UTCに対する時差設定時に5×3配列を作成し，モードに対応する
                    jisa = [9*ones(1,4),9-12];
                    data = zeros(86400,17);
                    for area = 1:17
                        %% PV300の取得
                        pv300 = get_PV300_1sec(['area',num2str(area),'\',num2str(Year),'_',num2str(Month),'\day',num2str(Day),'.csv']);
                        data(1:length(pv300),area)=pv300;
                    end
                    data = sum(data')/1000; % W⇒kW
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
                        %% PV300の取得
                        data = zeros(1,86400);
                        pv300 = get_PV300_1sec(['area',num2str(area),'\',num2str(Year),'_',num2str(Month),'\day',num2str(Day),'.csv']);
                        data(1:length(pv300))=pv300*24/1000; % W⇒kW⇒kWh
                        data=data(1:86400);
                        irr = [];
                        for m = MODE
                            fai = IDO(area); % 緯度
                            fai = fix(fai)+(fai-fix(fai))*100/60; % 緯度の更新
                            keido = KEIDO(area); % 経度    
                            keido = fix(keido)+(keido-fix(keido))*100/60; % 経度の更新
                            %% 日付番号の取得
                            t_target = datetime(Year,Month,Day);
                            day_num = day(t_target,'dayofyear'); %解析対象日の日付番号を取得
                            x = (day_num-1)*360/365; % n: 元旦を1とした年間日付の通し番号[deg]
                            % 
                            delta = (360/2/pi)*(0.006918-0.399912*cos(deg2rad(x))+0.070257*sin(deg2rad(x))-...
                                0.006758*cos(2*deg2rad(x))+0.000908*sin(2*deg2rad(x))); % 赤緯[deg]
                            Isc = 1.382; % 太陽定数[kW/m2]
                            omega_s = acos(-tan(deg2rad(fai))*tan(deg2rad(delta))); % 日没時の時角
                            %% Step1: 水平面全天日射量(??????)
                            Hbar = data; % 水平面全天日射量[KWh/m2/day]
                            h=[];
                            for t0=1:24
                                h=[h,Hbar(3600*t0-1800)];
                            end
                            Hbar=h;
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
                                kaku=[90:-(70)/(min(find(Hbar==max(Hbar)))-1):20,20:(70)/(24-min(find(Hbar==max(Hbar)))-1):90];
                                I_d = I_d.*(1+cos(deg2rad(kaku)))/2;
                                I_d(I_d<=0)=0;
                                % 反射成分
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

                            %% 短周期変動成分
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
                            %% 60秒周期変動追加
                            curve=(irr(:,2)./irr(:,1));
                            curve(isnan(curve))=0;
                            irr(:,1)=irr(:,1)+short_f;
                            irr(:,2)=irr(:,2)+short_f.*curve;
                        elseif mode == 4 || mode == 5
                            %% 60秒周期変動追加
                            curve=(irr(:,2)./irr(:,1));
                            curve(isnan(curve))=0;
                            irr(:,1)=irr(:,1)+short_f;
                            irr(:,2)=irr(:,2)+short_f.*curve;
                        end
                        irr = irr/24*1000;
                        irr(1:3600*4,:)=0;
                        irr(3600*20:end,:)=0;
                        irr(irr<=0)=0;
                        
                        
                        %% まとめ
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
                %% 北陸エリアPV出力実測値の抽出
%                     PV_real=csv_tieline_PV2019('北陸エリアPv出力2019');
%                     PV_real=table2array(PV_real(2:end,3));
%                     PV_real(isnan(PV_real))=[];
%                     %% 日付番号の取得
%                     t_331 = datetime(Year,3,31);dn = day(t_331,'dayofyear'); %3月31日の日付番号を取得
%                     t_target = datetime(Year,Month,Day);dn = day(t_target,'dayofyear')-dn; %解析対象日の日付番号を取得
%                     %% 解析対象日のPV実績値の取得
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
               load(['基本データ/PV_base_',num2str(Year),'.mat'])
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