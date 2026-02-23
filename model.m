clear
cd C:\Users\PowerSystemLab\Desktop\01_遐皮ｩｶ雉�譁兔05_螳溯｡後ヵ繧｡繧､繝ｫ\program\蜈ｨ菴灘ｮ溯｡�
% 蠢�隕√↑繝代せ繧定ｿｽ蜉�
addpath(genpath('C:\Users\PowerSystemLab\Desktop\01_遐皮ｩｶ雉�譁兔01_matlab_mytool'))
%% 2018蟷ｴ蠎ｦ譌｢險ｭPV螳ｹ驥�
start_date = datetime(2019, 4, 1);
end_date = datetime(2020, 3, 31);
date_range = start_date:end_date;
date_strings = datestr(date_range, 'yyyymmdd');
save('date_strings.mat','date_strings')
error_ox = 0; % 0:莠域ｸｬ隱､蟾ｮ辟｡�ｼ亥ｮ滓ｸｬ=莠域ｸｬ�ｼ会ｼ�1:莠域ｸｬ隱､蟾ｮ譛会ｼ亥ｮ滓ｸｬ竕�莠域ｸｬ�ｼ�
save('error_ox.mat','error_ox')
% %% 遒ｺ隱堺ｺ矩��
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
meth=1;save('method.mat','meth')
% YYYYMMDD='20190630';
for meth_num = 2
    save('meth_num.mat','meth_num')
% % if error_ox==0 % 莠域ｸｬ隱､蟾ｮ縺後↑縺�繧ｱ繝ｼ繧ｹ縺ｯ�ｼ悟�ｺ蜉帙Ξ繝吶Ν縺ｮ螟ｧ縺阪＆縺ｧ繧ｱ繝ｼ繧ｹ蛻�縺�
% %     YYYYMMDD = ['20190623';'20191022';...
% %         '20190917';'20190905';...
% %         '20191213';'20200116'];
% % elseif error_ox==1 % 莠域ｸｬ隱､蟾ｮ縺後≠繧九こ繝ｼ繧ｹ縺ｯ�ｼ瑚ｪ､蟾ｮ繝ｬ繝吶Ν縺ｮ螟ｧ縺阪＆縺ｧ繧ｱ繝ｼ繧ｹ蛻�縺�
% %     YYYYMMDD=['20190623';'20191213';'20191022';...
% %         '20190917';'20190930';'20190905';...
% %         '20200220';'20200129';'20200116'];
% % end
% if meth_num == 4
%     YYYYMMDD = ['20190630';'20200220';'20191128']; % 28?
% else
%     YYYYMMDD = ['20200220';'20191128']; % 20190828繧りｿｽ蜉�
% end
% YYYYMMDD = '20190630';

% start_date = datetime(2020, 1, 1);
% end_date   = datetime(2020, 3, 31);
% date_range = start_date:end_date;
% YYYYMMDD   = datestr(date_range, 'yyyymmdd');

YYYYMMDD = ['20190828'];

save YYYYMMDD.mat YYYYMMDD
% % 霑ｽ蜉�讀懆ｨｼ %
% sigma_set_PVC=[5,2,4900;2,3,5100;4,3,4900;5,3,5300;5,3,5500];
% save('sigma_set_PVC.mat','sigma_set_PVC')
% for k = 1:size(sigma_set_PVC,1)
% load('sigma_set_PVC.mat')
% for sigma = 2
sigma=2;
    save('sigma.mat','sigma')
    % if sigma==1
    %     D_R=25:30;
    % else
    %     D_R=1:30;
    % end
    save data_set1.mat
    for iii = 1:size(YYYYMMDD,1)
        load('data_set1.mat')
    % for day = 31
    day_l = str2num(YYYYMMDD(iii,7:8));
        if iii == 3
            M_R = 2:5;
        else
            M_R = 1:5;
        end
        
        save data_set2.mat
            for mode = 1 % 1:迚�髱｢, 2:荳｡髱｢譚ｱ, 3:荳｡髱｢隘ｿ, 4:迚�髱｢荳�霆ｸ, 4:荳｡髱｢荳�霆ｸ
                lfc = 8;
                load('data_set2.mat')

            save('lfclfc.mat','lfc')
            save('mode.mat','mode')
            load('sigma.mat')
            %% 蟷ｴ譛域律縺ｮ險ｭ螳壹�ｻ菫晏ｭ�
            %% 繝�繝ｼ繧ｿ驕ｸ謚�
            year_l = str2num(YYYYMMDD(iii,1:4));
            month_l = str2num(YYYYMMDD(iii,5:6));

            load('date_strings.mat')
            YYYY=str2num(date_strings(:,1:4))==year_l;
            MM=str2num(date_strings(:,5:6))==month_l;
            DD=str2num(date_strings(:,7:8))==day_l;
            
            DN=find(YYYY.*MM.*DD);

            save('YMD.mat','year_l','month_l','day_l')
            new_dataload
        %% 繧ｷ繝溘Η繝ｬ繝ｼ繧ｷ繝ｧ繝ｳ螳溯｡碁幕蟋�
           % PVC = 1100+40-120;
%             PVC = 1140-120;
            hantei = 1;
            % while hantei == 1
            %     PVC = PVC+120;
            % if sigma == 3
            %     if mode == 1
            %         PV_R = 5100:4160:13420;
            %     elseif mode == 2
            %         PV_R = 5100:4160:13420;
            %     elseif mode == 3
            %         PV_R = 5100:4160:13420;
            %     elseif mode == 4
            %         PV_R = 5100:4160:13420;
            %     elseif mode == 5
            %         PV_R = 5100:4160:13420;
            %     end
            % elseif sigma == 2
            %     if mode == 1
            %         PV_R = 5100:4160:13420;
            %     elseif mode == 2
            %         PV_R = 5100:4160:13420;
            %     elseif mode == 3
            %         PV_R = 5100:4160:13420;
            %     elseif mode == 4
            %         PV_R = 5100:4160:13420;
            %     elseif mode == 5
            %         PV_R = 5100:4160:13420;
            %     end
            % elseif sigma == 1
            %     if day == 18
            %         if mode==5
            %             PV_R = 13420;
            %         else
            %             PV_R = 5100:4160:13420;
            %         end
            %     else
            %         PV_R = 5100:4160:13420;
            %     end
            % end
            % if meth_num == 4
            %     if iii == 1
            %         PV_R = 2360+420:420:8660;
            %     else
            %         PV_R = 1100:420:8660;
            %     end
            % else
            %     PV_R = 1100:420:8660;
            % end
            save data_set3.mat
            for PVC = 5300
                save('PVC.mat','PVC')
                load('data_set3.mat')

                if year_l==2020
                    y=year_l-1;
                else
                    y=year_l;
                end
                %% 譌｢險ｭPV螳ｹ驥�
                load(['蝓ｺ譛ｬ繝�繝ｼ繧ｿ/PV_base_',num2str(y),'.mat'])
                PV_base=[PV_base(end-2:end,3)',PV_base(1:end-3,3)'];
                %% 繧ｷ繧ｹ繝�繝�蜃ｺ蜉帑ｿよ焚
                load(['蝓ｺ譛ｬ繝�繝ｼ繧ｿ/PR_',num2str(y),'.mat'])
                %% MSM縺ｮ蛟肴焚菫よ焚
                load(['蝓ｺ譛ｬ繝�繝ｼ繧ｿ/MSM_bai_',num2str(y),'.mat'])
                %% 譌･蟆�驥上�ｮ謚ｽ蜃ｺ
                % cd 莠域ｸｬPV蜃ｺ蜉帑ｽ懈��
                load('蝓ｺ譛ｬ繝�繝ｼ繧ｿ/irr_fore_data.mat')

                n_l=[1,mode];

                PVF_30min_al=irr_fore_data(24*((DN-1)-1)+1:24*(DN-1),n_l(1))*MSM_bai(month_l)*PR(month_l)*PV_base(month_l)/1000;
                PVF_30min_new=irr_fore_data(24*((DN-1)-1)+1:24*(DN-1),n_l(2))*MSM_bai(month_l)*PR(month_l)*PV_base(month_l)/1000;
                PV_al=1100;
                PVF_30min=PVF_30min_al*PV_al/PV_base(month_l)+PVF_30min_new*(PVC-PV_al)/PV_base(month_l);
                x = 1:24;xq_1min = 1:1/2:24;
                PVF_30min = [interp1(x,PVF_30min,xq_1min),0,0,0];
                PVF_30min(isnan(PVF_30min))=0;
                save PVF_30min.mat PVF_30min

                % make_PVF_year
                % make_PVF_year_for_agc
                % cd ..
                %% 髴�隕∽ｽ懈��
                % load('YMD.mat');load('PVC.mat')
                load('蝓ｺ譛ｬ繝�繝ｼ繧ｿ/D_1sec.mat')
                load('蝓ｺ譛ｬ繝�繝ｼ繧ｿ/D_30min.mat')
                % cd 髴�隕∝ｮ溽ｸｾ繝ｻ莠域ｸｬ菴懈��
                demand_1sec=D_1sec(DN,:)-500;   % 荳�闊ｬ豌ｴ蜉帛��繧呈ｸ帷ｮ�(-500)
                demand_30min=D_30min(DN,:)-500; % 荳�闊ｬ豌ｴ蜉帛��繧呈ｸ帷ｮ�(-500)
                save demand_30min.mat demand_30min    
                save demand_1sec.mat demand_1sec
                % cd ..
                %% PV菴懈�人oad('蝓ｺ譛ｬ繝�繝ｼ繧ｿ/irr_mea_data.mat')
                  load('蝓ｺ譛ｬ繝�繝ｼ繧ｿ/irr_mea_data.mat')
                    n_l=[1,mode];
    
                    PV_1sec_al=irr_mea_data(86401*(DN-1):86401*DN,n_l(1))*PR(month_l)*PV_base(month_l)/1000;
                    PV_1sec_new=irr_mea_data(86401*(DN-1):86401*DN,n_l(2))*PR(month_l)*PV_base(month_l)/1000;
                    PV_al=1100;
                    PV_1sec=PV_1sec_al*PV_al/PV_base(month_l)+PV_1sec_new*(PVC-PV_al)/PV_base(month_l);
                    
                save PV_1sec.mat PV_1sec

                if DN == 91
                    % 蠢懈�･蜃ｦ鄂ｮ
                    load(['H:\隗｣譫千ｵ先棡\IEEJ_B\data\20190630\method1\PV_',num2str(PVC),'.mat'],'load_input','PVF','PV_real_Output')
                    
                    demand_1sec = [load_input,load_input(end)*ones(1,3599)];
                    save demand_1sec.mat demand_1sec
                    demand_30min = demand_1sec(1:1800:end);
                    save demand_30min.mat demand_30min    

                    PVF_30min = [PVF(1:1800:end),0];
                    save PVF_30min.mat PVF_30min
                    PV_1sec = [nan;PV_real_Output(2,:)'];;
                    save PV_1sec.mat PV_1sec
                end
                %% 逋ｺ髮ｻ襍ｷ蜍募●豁｢險育判縺ｸ縺ｮ譖ｸ縺崎ｾｼ縺ｿ
                % PV莠域ｸｬ,髴�隕∽ｺ域ｸｬ
                lfc = load('lfclfc.mat');
                lfc = lfc.lfc;
                cd UC遶区｡�
                % -- Excel --
%                 if lfc > 10
%                     pvwrite(1,lfc)
%                 else
%                     pvwrite(0,lfc)
%                 end
                % -- matlab --
                % 荳崎ｦ�
                % LFC螳ｹ驥�
                load('../YMD.mat')
                load('../PVC.mat')
%                 load(['../PV_base_',num2str(year),'.mat'])
                %% PV蜃ｺ蜉帙↓繧医▲縺ｦ莠域ｸｬ隱､蟾ｮ繧堤ｮ怜�ｺ縺暦ｼ鍬FC螳ｹ驥上ｒ菴懈��
%                 if lfc == 14
%                     load('sigma.mat')
%                     if sigma >= 4
%                         sigma = sigma -4;
%                         save('sigma.mat','sigma')
%                         statical_machine
%                         sigma = sigma +4;
%                         save('sigma.mat','sigma')
%                     else
%                         %% 讖滓｢ｰ蟄ｦ鄙偵↓繧医ｋLFC螳ｹ驥�
%                         if day == 31
%                             write_LFC(1,5,lfc,5,PVC/PVC_range(1),year,11,1,sigma)
%                         else
%                             write_LFC(1,5,lfc,5,PVC/PVC_range(1),year,month,day,sigma)
%                         end
%                     end
%                 elseif lfc == 13
%                     %% 邱壼ｽ｢髢｢菫ゅ�ｮLFC螳ｹ驥�
%                     cd('莠域ｸｬPV蜃ｺ蜉幄ｪ､蟾ｮ')
%                     douteki_LFC3(year,month,day,PVC/PVC_range(1))
%                     write_LFC(1,5,lfc,5,[],year,month,day)
%                 elseif lfc == 12
%                     %% 邨ｱ險医↓繧医ｋ隱､蟾ｮ縺ｫ蟇ｾ縺吶ｋLFC螳ｹ驥�
%                     SIGMA_get1(2018,1,[],[],PVC/PVC_range(1))
%                     if month < 4
%                         lfc_make_01(year+1,month,day,95,2)
%                     else
%                         lfc_make_01(year,month,day,95,2)
%                     end
%                     write_LFC(1,5,lfc,5,[],year,month,day)
%                 elseif lfc == 11
%                     %% 邨ｶ蟇ｾ隱､蟾ｮ縺ｫ蟇ｾ縺吶ｋLFC螳ｹ驥�
%                     if month < 4
%                         lfc_make_01(year+1,month,day,95,1)
%                     else
%                         lfc_make_01(year,month,day,95,1)
%                     end
%                     write_LFC(1,5,lfc,5,(PVC-PVC_range(1))/20+1,year,month,day)
%                 elseif lfc == 15
%                     load('new_ave_PV.mat')
%                     write_LFC_test(1,5,lfc,5,(PVC-PVC_range(1))/20+1,year,month,day,0,new_ave_PV)
%                 elseif lfc >= 100
%                     %% 譁ｰ逋ｺ髮ｻ讖滓ｧ区��, 邨ｱ險医ｒ菴ｿ逕ｨ
%                     SIGMA_get1(2018,1,[],[],PVC/PVC_range(1))
%                     if month < 4
%                         lfc_make_01(year+1,month,day,95,2)
%                     else
%                         lfc_make_01(year,month,day,95,2)
%                     end
%                     write_LFC(1,5,lfc,5,[],year,month,day)
%                 else
                    % -- Excel --
%                     write_LFC(0,5,lfc,5,(PVC-PV_base(month))/20+1,day)
                    % -- MATLAB --
                    cd('../UC遶区｡�/MATLAB')
                    try
                        new_optimization
                        % easy_optimization
                    catch ME
                    end
                    
                    copyfile('*.csv','../../驕狗畑')
                    cd ../..
                    % for lfc = 1*10 % 319陦檎岼縺ｮend繧呈怏蜉ｹ縺ｫ縺吶ｋ
                    %     save('lfclfc.mat','lfc')
                    if exist('ME')==0
        %                 end
                    % -- Excel --
        %                 movefile('*.csv','../驕狗畑')
        %                 movefile('驕玖ｻ｢蛛懈ｭ｢譎る俣驕募渚.xlsx','../驕狗畑')
        %                 movefile('騾溷ｺｦ驕募渚.xlsx','../驕狗畑')
        %                 movefile('莠亥ｙ蜉幃＆蜿�.xlsx','../驕狗畑')
        %                 cd ..
                 %%
                     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % initset.m 繧ｷ繝溘Η繝ｬ繝ｼ繧ｷ繝ｧ繝ｳ蛻晄悄譚｡莉ｶ險育ｮ� 螳溯｡後�励Ο繧ｰ繝ｩ繝�
                    %% 莉･荳倶ｸ｡蟷ｴ蠎ｦ蜈ｱ騾�
                     cd 驕狗畑
                     make_csv               %Load.csv/PV_Out.csv縺ｮ菴懈��  莉悶お繝ｪ繧｢髴�隕√�ｮ菴懊ｊ譁ｹ
                     clear
                     disp('initset螳溯｡�')
                     initset_dataload        % 繧ｷ繝溘Η繝ｬ繝ｼ繧ｷ繝ｧ繝ｳ譎る俣遲峨�ｮ險ｭ螳壹�∫匱髮ｻ險育判繝�繝ｼ繧ｿ縲∵ｨ呎ｺ悶ョ繝ｼ繧ｿ縺ｮ隱ｭ霎ｼ縺ｿ
                     initset_inertia         % 諷｣諤ｧ繝｢繝�繝ｫ縺ｫ縺翫¢繧玖ｨｭ螳壼�､
                     initset_trfpP           % 騾｣邉ｻ邱壽ｽｮ豬∫ｮ怜�ｺ繝｢繝�繝ｫ縺ｫ縺翫¢繧玖ｨｭ螳壼�､
                     initset_lfc             % LFC繝｢繝�繝ｫ縺ｮ蛻晄悄蛟､險ｭ螳壼�､
                     initset_edc             % EDC繝｢繝�繝ｫ縺ｮ險ｭ螳壼�､縺ｨ蛻晄悄蛟､險育ｮ�
                     initset_thermals        % 豎ｽ蜉帙�励Λ繝ｳ繝医Δ繝�繝ｫ繝ｻGTCC繝励Λ繝ｳ繝医Δ繝�繝ｫ縺ｮ蛻晄悄蛟､險育ｮ�
        %                  initset_conhydros       % 螳夐�滓恕豌ｴ逋ｺ髮ｻ繝励Λ繝ｳ繝医Δ繝�繝ｫ縺ｮ蛻晄悄蛟､險育ｮ�
        %                  initset_vahydros        % 蜿ｯ螟蛾�滓恕豌ｴ逋ｺ髮ｻ讖溘Δ繝�繝ｫ縺ｮ蛻晄悄蛟､險育ｮ�
                     initset_otherarea       % 莉悶お繝ｪ繧｢繝｢繝�繝ｫ縺ｮ蛻晄悄蛟､險ｭ螳�
                    %% 螳滓ｸｬ繝�繝ｼ繧ｿ縺ｨ莠域ｸｬ繝�繝ｼ繧ｿ縺ｮ豈碑ｼ�
                    load('../lfclfc.mat')
                    P_F = struct('PV_Forecast',PV_Forecast);
                    PVF = P_F.PV_Forecast(2,:);
                    L_F = struct('load_forecast_input',load_forecast_input);
                    LOF = L_F.load_forecast_input(2,:);
                    save('FO.mat','PVF','LOF')
                    P_M = struct('PV_Out',PV_Out);
                    PV_MAX = max(P_M.PV_Out(2,:));
                    save('PV_MAX.mat','PV_MAX')
                    % ppp=PV_Out(2,:);
                    % ppp(~isfinite(ppp))=0;
                    % PV_Out(2,:)=ppp*lfc/10; % 陦ｨ險倥�ｯlfc縺�縺鯉ｼ訓V螳溷�ｺ蜉帙�ｮ蜑ｲ蜷医ｒ螟牙喧縺輔○繧九◆繧√↓逕ｨ縺�繧句､画焚縺ｨ縺励※縺�繧具ｼ�2023蟷ｴ8譛�10譌･迴ｾ蝨ｨ�ｼ�
                    lowpass_PV
                    PV_real_Output=PV_Out;
                    save PV_real_Output.mat PV_real_Output
                    %% Simulink縺ｮ螳溯｡�
                    try
                        if lfc >= 100
                            open_system('Hydro_load.slx')
                            sim('Hydro_load.slx')
                        else
                            open_system('AGC30_PVcut.slx')
                            sim('AGC30_PVcut.slx')
                        end
                    catch ME
                    end
                    disp('繧ｷ繝溘Η繝ｬ繝ｼ繧ｷ繝ｧ繝ｳ邨ゆｺ�')
                    M = load('inertia_input.mat');
                    inertia_input = M.inertia_input;
                    FO = load('FO.mat');
                    PVF = FO.PVF;
                    LOF = FO.LOF;
                    G_Out_UC = get_GOUT('G_Out.csv');
                    LFC_up = get_LFC_updown('G_up_plan_limit.csv');
                    LFC_down = get_LFC_updown('G_down_plan_limit.csv');
                    g_c_o_s = struct('g_const_out_sum',g_const_out_sum);
                    g_const_out_sum = g_c_o_s.g_const_out_sum(2,:);
                    %% 蛻ｶ邏�驕募渚縺ｮ蛻､螳�
        %                 onoff_ihan=get_ihan('驕玖ｻ｢蛛懈ｭ｢譎る俣驕募渚.xlsx');
        %                 speed_ihan=get_ihan('騾溷ｺｦ驕募渚.xlsx');
        %                 reserved_ihan=get_ihan('莠亥ｙ蜉幃＆蜿�.xlsx');
        %                 reserved_ihan=reserved_ihan(1:3,:);
                    LFC_t=get_Gupplanlimittime('G_up_plan_limit_time.csv');
                    cd ..
                    load('YMD.mat')
                    load('PVC.mat');
                    load('Reserved_power.mat')
                    
                    %%
                    load('sigma.mat')
                    load('mode.mat')
                    load('meth_num.mat')
                    if mode == 1
                        filename = ['nSigma_',num2str(sigma),'_Method_',num2str(meth_num),'_PVcapacity_',num2str(PVC),'_',num2str(year_l),'-',num2str(month_l),'-',num2str(day_l),'.mat'];
                    elseif mode == 2
                        filename = ['E_Sigma_',num2str(sigma),'_Method_',num2str(meth_num),'_PVcapacity_',num2str(PVC),'_',num2str(year_l),'-',num2str(month_l),'-',num2str(day_l),'.mat'];
                    elseif mode == 3
                        filename = ['W_Sigma_',num2str(sigma),'_Method_',num2str(meth_num),'_PVcapacity_',num2str(PVC),'_',num2str(year_l),'-',num2str(month_l),'-',num2str(day_l),'.mat'];
                    elseif mode == 4
                        filename = ['T_Sigma_',num2str(sigma),'_Method_',num2str(meth_num),'_PVcapacity_',num2str(PVC),'_',num2str(year_l),'-',num2str(month_l),'-',num2str(day_l),'.mat'];
                    elseif mode == 5
                        filename = ['T_V_Sigma_',num2str(sigma),'_Method_',num2str(meth_num),'_PVcapacity_',num2str(PVC),'_',num2str(year_l),'-',num2str(month_l),'-',num2str(day_l),'.mat'];
                    end
                    LFC = load('UC遶区｡�\LFC.mat');
                    % cd E:\02_繝�繝ｼ繧ｿ菫晏ｭ�
                    cd H:\NSD_results
                    inertia_input = inertia_input(2,:);
                    load_forecast_input = load_forecast_input(2,:);
                    load_input = load_input(2,:);
                    PV_Forecast = PV_Forecast(2,:);
                    PV_Out = PV_Out(2,:);
                    load('C:\Users\PowerSystemLab\Desktop\01_遐皮ｩｶ雉�譁兔05_螳溯｡後ヵ繧｡繧､繝ｫ\program\蜈ｨ菴灘ｮ溯｡圭UC遶区｡�\MATLAB\譛�驕ｩ蛹悶ョ繝ｼ繧ｿ繝舌ャ繧ｯ繧｢繝�繝� (譖ｴ譁ｰ)\data_time50.mat')
                    %% 菫晏ｭ�
    %                 dfout(1:300)=0;
                    % AGC30_PVcut model: add PV_real_Output, PV_Surplus
                    save(filename,'PV_CUR','LFC_t','Reserved_power','PV_real_Output','LFC_up','LFC_down','PV_MAX','G_Out_UC','g_const_out_sum','load_forecast_input','PV_Forecast','Oil_Output','Coal_Output','Combine_Output','LOF','PVF','dpout','load_input','dfout','TieLineLoadout','LFC_Output','EDC_Output','PV_Out','LFC','inertia_input')
                    % save(filename,'PV_CUR','LFC_t','Reserved_power','PV_real_Output','PV_Surplus','LFC_up','LFC_down','PV_MAX','G_Out_UC','g_const_out_sum','load_forecast_input','PV_Forecast','Oil_Output','Coal_Output','Combine_Output','LOF','PVF','dpout','load_input','dfout','TieLineLoadout','LFC_Output','EDC_Output','PV_Out','LFC','inertia_input')
                    cd C:\Users\PowerSystemLab\Desktop\01_遐皮ｩｶ雉�譁兔05_螳溯｡後ヵ繧｡繧､繝ｫ\program\蜈ｨ菴灘ｮ溯｡�
    %                 dfout = round((dfout),2);
    %                 F_stay(dfout(3600*4:3600*20))
    %                 global aaa aaaa
    %                 aaa = (aaa>=95);
    %                 aaaa = (aaaa==100);
    %                 hantei = aaa*aaaa;
                    else
                        load(fullfile('UC遶区｡�','MATLAB','譛�驕ｩ蛹悶ョ繝ｼ繧ｿ繝舌ャ繧ｯ繧｢繝�繝� (譖ｴ譁ｰ)',['data_time',num2str(time_out-1),'.mat']))
                        load('lfclfc.mat');
                        load('YMD.mat')
                        load('PVC.mat');
                        load('sigma.mat')
                        load('mode.mat')
                        load('meth_num.mat')
                        if mode == 1
                            filename = ['nSigma_',num2str(sigma),'_Method_',num2str(meth_num),'_PVcapacity_',num2str(PVC),'_',num2str(year_l),'-',num2str(month_l),'-',num2str(day_l),'.mat'];
                        elseif mode == 2
                            filename = ['E_Sigma_',num2str(sigma),'_Method_',num2str(meth_num),'_PVcapacity_',num2str(PVC),'_',num2str(year_l),'-',num2str(month_l),'-',num2str(day_l),'.mat'];
                        elseif mode == 3
                            filename = ['W_Sigma_',num2str(sigma),'_Method_',num2str(meth_num),'_PVcapacity_',num2str(PVC),'_',num2str(year_l),'-',num2str(month_l),'-',num2str(day_l),'.mat'];
                        elseif mode == 4
                            filename = ['T_Sigma_',num2str(sigma),'_Method_',num2str(meth_num),'_PVcapacity_',num2str(PVC),'_',num2str(year_l),'-',num2str(month_l),'-',num2str(day_l),'.mat'];
                        elseif mode == 5
                            filename = ['T_V_Sigma_',num2str(sigma),'_Method_',num2str(meth_num),'_PVcapacity_',num2str(PVC),'_',num2str(year_l),'-',num2str(month_l),'-',num2str(day_l),'.mat'];
                        end
                        % cd E:\02_繝�繝ｼ繧ｿ菫晏ｭ�
                        cd H:\NSD_results
                        % save(filename,'time_out','ME','UC_planning','Balancing_EDC_LFC','EDC_reserved_plus','EDC_reserved_minus','LFC_reserved_up','LFC_reserved_down','PV_CUR','L_C_t')
                        save(filename,'time_out','ME','UC_planning','Balancing_EDC_LFC','EDC_reserved_plus','LFC_reserved_up','LFC_reserved_up','EDC_reserved_plus')
                        cd C:\Users\PowerSystemLab\Desktop\01_遐皮ｩｶ雉�譁兔05_螳溯｡後ヵ繧｡繧､繝ｫ\program\蜈ｨ菴灘ｮ溯｡�
                    end
                    clear
                    % end
                end
            end
        % end
    end
end
% end
% end