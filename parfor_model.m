clear
cd C:\Users\PowerSystemLab\Desktop\01_遐皮ｩｶ雉�譁兔05_螳溯｡後ヵ繧｡繧､繝ｫ\program\蜈ｨ菴灘ｮ溯｡�

data_set = struct();
data_set.meth=1;
data_set.pv_ox = 1;
data_set.start_time = '00'; % 蛻晄悄譎ょ綾 JST1 = T1 + 9h 
                            % T1 = '00' : 蛻晄悄譎ょ綾 蜑肴律9:00 螢ｲ雋ｷ逕ｨ
                            % T2 = '06' : 蛻晄悄譎ょ綾 蜑肴律15:00 蜀崎ｨ育判
data_set.sigma = 2;
data_set.rm_pv = .25; % 隱ｿ謨ｴ蜉�:PV蜃ｺ蜉帙↓蟇ｾ縺吶ｋ蜑ｲ蜷�
data_set.rm_de = .10; % 隱ｿ謨ｴ蜉�:髴�隕√↓蟇ｾ縺吶ｋ蜑ｲ蜷�
data_set.pv_set = 1;
data_set.RES_lfc=1/6;
data_set.RES_edc=5/6;

data_set.PV_R = 1100:2000:11100; % 

%% 譌･譎よュ蝣ｱ菴懈��
data_set.YYYY = 2019;
data_set.MM = 7;
data_set.DD = 6;

start_date = datetime(data_set.YYYY, 4, 1);
end_date = datetime(data_set.YYYY+1, 3, 31);
date_range = start_date:end_date;
date_strings = datestr(date_range, 'yyyymmdd');

YYYY=str2num(date_strings(:,1:4))==data_set.YYYY;
MM=str2num(date_strings(:,5:6))==data_set.MM;
DD=str2num(date_strings(:,7:8))==data_set.DD;

data_set.DN=find(YYYY.*MM.*DD);
clear start_date end_date date_range date_strings YYYY MM DD

%% 譌｢險ｭPV螳ｹ驥�
load(['蝓ｺ譛ｬ繝�繝ｼ繧ｿ/PV_base_',num2str(data_set.YYYY),'.mat'])
data_set.PV_base=[PV_base(end-2:end,3)',PV_base(1:end-3,3)'];
%% 繧ｷ繧ｹ繝�繝�蜃ｺ蜉帑ｿよ焚
load(['蝓ｺ譛ｬ繝�繝ｼ繧ｿ/PR_',num2str(data_set.YYYY),'.mat'])
data_set.PR=PR;
%% MSM縺ｮ蛟肴焚菫よ焚
load(['蝓ｺ譛ｬ繝�繝ｼ繧ｿ/MSM_bai_',num2str(data_set.YYYY),'.mat'])
data_set.MSM_bai=MSM_bai;

%% 莠域ｸｬ譌･蟆�驥�
load('irr_fore_data.mat')
data_set.irr_fore_data=irr_fore_data;
%% 螳滓ｸｬ譌･蟆�驥�
load('irr_mea_data.mat')
data_set.irr_mea_data=irr_mea_data;
%% 莠域ｸｬ繝ｻ螳滓ｸｬ髴�隕�
load('D_1sec.mat');load('D_30min.mat')
data_set.D_1sec=D_1sec;
data_set.D_30min=D_30min;

data_set.x_t=0:.5:23;
data_set.T_30min=24;
data_set.T_1sec=86401;

%% UC遶区｡域凾縺ｮ蠢�隕√ョ繝ｼ繧ｿ
data_set.Rate_Min = [250,40;250,75;500,75;250,35;250,60;250,60;500,100+40;700,140+40;500,100+40;700,140+40;425,178+40;388 130];
data_set.end_hour=50;
data_set.abc=[316,4.6,0.00105;200,5,0.00005;200,5,0.00005;316,4.6,0.00105;40,2,0.0002;40,2,0.0002;120,1.5,0.00018;182,1.3,0.00016;120,1.5,0.00018;182,1.3,0.00016;80,2.3,0.0015]*5000;

data_set.Output_max=[250,250,500,250,250,250,500,700,500,700,425];
data_set.cost_kWh=(data_set.abc(:,1)+data_set.abc(:,2).*data_set.Output_max'+data_set.abc(:,3).*data_set.Output_max'.^2)./data_set.Output_max';
data_set.a_k=data_set.abc(:,1);
data_set.b_k=data_set.abc(:,2);
data_set.c_k=data_set.abc(:,3);
data_set.ON_time = 4;
data_set.OFF_time = 4;
data_set.gen_on = data_set.ON_time*ones(1,11); % 1譁ｭ髱｢: 30蛻� (ex:1.5譎る俣: 3譁ｭ髱｢)
data_set.gen_off = data_set.OFF_time*ones(1,11); % 1譁ｭ髱｢: 30蛻� (ex:1.5譎る俣: 3譁ｭ髱｢)
data_set.kk=0;
data_set.aaa=1;

%% 繧ｷ繝溘Η繝ｬ繝ｼ繧ｷ繝ｧ繝ｳ螳溯｡碁幕蟋�
clearvars -except data_set
for mode = 3:5
for PVC = data_set.PV_R
    %% PV莠域ｸｬ
    data_set.irr_fore_al=data_set.irr_fore_data(data_set.T_30min*(data_set.DN-1)+1:data_set.T_30min*data_set.DN,1);
    data_set.irr_fore_al=interp1(0:length(data_set.irr_fore_al)-1,data_set.irr_fore_al',data_set.x_t,'linear');
    data_set.irr_fore_new=data_set.irr_fore_data(data_set.T_30min*(data_set.DN-1)+1:data_set.T_30min*data_set.DN,mode);
    data_set.irr_fore_new=interp1(0:length(data_set.irr_fore_new)-1,data_set.irr_fore_new',data_set.x_t,'linear');
    
    data_set.irr_fore = [[data_set.irr_fore_al',data_set.irr_fore_new'];zeros(3,2)];
    if mode == 1
        data_set.n_l=[1,1];
    else
        data_set.n_l=[1,2];
    end
    
    data_set.k_PV=data_set.MSM_bai(data_set.MM)*data_set.PR(data_set.MM)*data_set.PV_base(data_set.MM)/1000;
    data_set.PVF_30min_al=data_set.irr_fore(:,data_set.n_l(1))*data_set.k_PV;
    data_set.PVF_30min_new=data_set.irr_fore(:,data_set.n_l(2))*data_set.k_PV;
    data_set.PV_al=1100;
    data_set.PVF_30min=data_set.PVF_30min_al*data_set.PV_al/data_set.PV_base(data_set.MM)+data_set.PVF_30min_new*(PVC-data_set.PV_al)/data_set.PV_base(data_set.MM);
    %% PV螳滓ｸｬ
    data_set.irr_mea_al=data_set.irr_mea_data(data_set.T_1sec*(data_set.DN-1)+1:data_set.T_1sec*data_set.DN,1);
    data_set.irr_mea_new=data_set.irr_mea_data(data_set.T_1sec*(data_set.DN-1)+1:data_set.T_1sec*data_set.DN,mode);
    
    data_set.irr_mea = [data_set.irr_mea_al,data_set.irr_mea_new];
    if mode == 1
        data_set.n_l=[1,1];
    else
        data_set.n_l=[1,2];
    end
    
    data_set.k_PV=data_set.MSM_bai(data_set.MM)*data_set.PR(data_set.MM)*data_set.PV_base(data_set.MM)/1000;
    data_set.PVF_30min_al=data_set.irr_mea(:,data_set.n_l(1))*data_set.k_PV;
    data_set.PVF_30min_new=data_set.irr_mea(:,data_set.n_l(2))*data_set.k_PV;
    data_set.PV_al=1100;
    data_set.PVO_30min=data_set.PVF_30min_al*data_set.PV_al/data_set.PV_base(data_set.MM)+data_set.PVF_30min_new*(PVC-data_set.PV_al)/data_set.PV_base(data_set.MM);
    data_set.PVO_30min(isnan(data_set.PVO_30min))=0;
    %% 髴�隕∽ｽ懈��
    data_set.demand_1sec=data_set.D_1sec(data_set.DN,:)';
    data_set.demand_30min=data_set.D_30min(data_set.DN,:)';
    %% 逋ｺ髮ｻ襍ｷ蜍募●豁｢險育判縺ｸ縺ｮ譖ｸ縺崎ｾｼ縺ｿ
    cd('UC遶区｡�/MATLAB')
    try
        delete((['譛�驕ｩ蛹悶ョ繝ｼ繧ｿ繝舌ャ繧ｯ繧｢繝�繝� (譖ｴ譁ｰ)\data_time*']))
        delete((['譛�驕ｩ蛹悶ョ繝ｼ繧ｿ繝舌ャ繧ｯ繧｢繝�繝� (譖ｴ譁ｰ)\out_time*']))
    %% 邂怜�ｺ
    data_set.RES=data_set.demand_30min*data_set.rm_de+data_set.PVF_30min*data_set.rm_pv;
    %% 驟榊��
    data_set.EDC_reserved_plus=data_set.RES*data_set.RES_edc;
    data_set.LFC_reserved_up=data_set.RES*data_set.RES_lfc;
    %% LFC+EDC隱ｿ謨ｴ蜉帙′邉ｻ邨ｱ縺ｮ險ｱ螳ｹ隱ｿ謨ｴ蜉帷ｯ�蝗ｲ繧定ｶ�縺医◆蛻�縺ｯ髯､蜴ｻ
    data_set.System_lfc_max=sum(data_set.Rate_Min(7:11,1)-data_set.Rate_Min(7:11,2));
    data_set.LFC_reduce=(data_set.System_lfc_max-data_set.LFC_reserved_up).*(data_set.LFC_reserved_up>=data_set.System_lfc_max);
    data_set.LFC_reserved_up=data_set.LFC_reserved_up+data_set.LFC_reduce;
    data_set.System_reserve_max=sum(data_set.Rate_Min(1:11,1)-data_set.Rate_Min(1:11,2));
    data_set.System_reserve_need=data_set.EDC_reserved_plus+data_set.LFC_reserved_up;
    data_set.EDC_reduce=(data_set.System_reserve_max-data_set.System_reserve_need).*(data_set.System_reserve_need>=data_set.System_reserve_max);
    data_set.EDC_reserved_plus=data_set.EDC_reserved_plus+data_set.EDC_reduce;
    %% 蠢�隕√ョ繝ｼ繧ｿ縺ｮ菴懈�撰ｼ瑚ｪｭ縺ｿ霎ｼ縺ｿ(莉ｻ諢�)
% -- 遨ｺ陦悟�嶺ｽ懈�� --
    % UC_planning = []; % 譛�驕ｩ隗｣菫晏ｭ倩｡悟��
    % Balancing_EDC_LFC = [];
    % cost_t = [];PV_CUR=[];TieLine_Output=[];L_C_t=[];Reserved_power=[];time0=0;
    %%%%% 譛�驕ｩ蛹夜幕蟋� %%%%%
    time=0;
    a=[];
    edc_out=zeros(1,50);

    out_inf=struct();
    make_opt_data=struct();
    OPT_ANS=struct();

    while time < data_set.end_hour
    time=time+1;
    if time~=1
        % 蜑肴凾蛻ｻ繝�繝ｼ繧ｿ縺ｮ蜿門ｾ�
        % load(['譛�驕ｩ蛹悶ョ繝ｼ繧ｿ繝舌ャ繧ｯ繧｢繝�繝� (譖ｴ譁ｰ)\data_time',num2str(time-1),'.mat'])
    else
        data_set.on_time=zeros(1,11);
        data_set.off_time =zeros(1,11);
    end
    % ass_data
    %%%%% 邨�縺ｿ蜷医ｏ縺帑ｽ懈�� %%%%%
    data_set.G_ox=[];
    for n=1:11
        aa=nchoosek(1:11,n);
        s=size(aa);
        for m = 1:s(1)
            g_ox=zeros(1,11);
            g_ox(1,aa(m,:))=1;
            data_set.G_ox=[data_set.G_ox;g_ox];
        end
    end
    if data_set.kk ~= 0
        % load((['譛�驕ｩ蛹悶ョ繝ｼ繧ｿ繝舌ャ繧ｯ繧｢繝�繝� (譖ｴ譁ｰ)\out_time',num2str(time_out),'.mat']))
    else
        % -- 譎ょ綾髢薙〒縺ｮ蠑輔″邯壹″縺ｫ蠢�隕√↑繝�繝ｼ繧ｿ莉･螟悶�ｯ髯､蜴ｻ(髢句ｧ区凾縺ｨ蜷後§迥ｶ諷九↓縺吶ｋ) --
        % clearvars -except ...
        %     PV_CUR Balancing_EDC_LFC G_ox time0...
        %     edc_out edc_surplus Reserved_power...
        %     hantei_off_time a p time data_set.end_hour...
        %     UC_planning on_time off_time cost_t...
        %     lfc a_k b_k c_k gen_on gen_off...
        %     demand_30min PVF_30min Rate_Min...
        %     EDC_reserved_plus EDC_reserved_minus...
        %     LFC_reserved_up LFC_reserved_down...
        %     L_C_t cost_kWh kk G_r_ox aaa ME on_time_pre off_time_pre TieLine_Output
    end
    
    data_set.on_time_pre=data_set.on_time;
    data_set.off_time_pre=data_set.off_time;
    %%%%%%% 襍ｷ蜍募●豁｢邯ｭ謖∵凾髢灘宛邏�繧呈ｺ�縺溘☆縺�? %%%%%%%
    if time == 1
        data_set.hantei_on_time = ones(1,11);     % 髱樒ｨｼ蜒肴ｩ溘�ｯ蟇ｾ雎｡螟悶□縺九ｉ1�ｼ檎ｨｼ蜒肴ｩ溘�ｯ蛻ｶ邏�繧呈ｺ�縺溘＠縺ｦ繧後�ｰ1
        data_set.hantei_off_time = ones(1,11);    % 髱槫●豁｢讖溘�ｯ蟇ｾ雎｡螟悶□縺九ｉ1�ｼ悟●豁｢讖溘�ｯ蛻ｶ邏�繧呈ｺ�縺溘＠縺ｦ繧後�ｰ1
    else
    if isempty(a) ~= 0
        data_set.pre_on = (data_set.UC_planning(time-1,:)~=0); % 蜑肴凾蛻ｻ譁ｭ髱｢縺ｧ縺ｮ襍ｷ蜍慕憾諷九�ｮ遒ｺ隱�
        data_set.pre_off = data_set.pre_on==0;                                 % 蜑肴凾蛻ｻ譁ｭ髱｢縺ｧ縺ｮ蛛懈ｭ｢迥ｶ諷九�ｮ遒ｺ隱�
        % -- 襍ｷ蜍慕ｶｭ謖∵凾髢灘宛邏�縺ｮ蟇ｾ雎｡逋ｺ髮ｻ讖� --
        data_set.on_const_gen = (data_set.pre_on~=0);
        data_set.on_time = (data_set.on_time+data_set.pre_on).*data_set.pre_on;
        % -- 蛛懈ｭ｢邯ｭ謖∵凾髢灘宛邏�縺ｮ蟇ｾ雎｡逋ｺ髮ｻ讖� --
        data_set.off_const_gen = (data_set.pre_off~=0);
        data_set.off_time = (data_set.off_time+data_set.pre_off).*data_set.pre_off;
    end
    data_set.hantei_on_time = (data_set.on_time==0)+(data_set.on_time>=data_set.gen_on);     % 髱樒ｨｼ蜒肴ｩ溘�ｯ蟇ｾ雎｡螟悶□縺九ｉ1�ｼ檎ｨｼ蜒肴ｩ溘�ｯ蛻ｶ邏�繧呈ｺ�縺溘＠縺ｦ繧後�ｰ1
    data_set.hantei_off_time = (data_set.off_time==0)+(data_set.off_time>=data_set.gen_off); % 髱槫●豁｢讖溘�ｯ蟇ｾ雎｡螟悶□縺九ｉ1�ｼ悟●豁｢讖溘�ｯ蛻ｶ邏�繧呈ｺ�縺溘＠縺ｦ繧後�ｰ1
    end
    
    %%%%% 譛�驕ｩ蛹夜幕蟋� %%%%%
    data_set.hantei = 1;
    data_set.mm=0;

    %% 蛛懈ｭ｢蠢�鬆育匱髮ｻ讖�
    data_set.hantei_a=find(data_set.hantei_off_time==0);
    data_set.ok_num = 0;
    for i = data_set.hantei_a
        data_set.ok_num=data_set.ok_num+(data_set.G_ox(:,i)==1);% 荳�縺､縺ｧ繧�1縺後≠縺｣縺溘ｉ繝�繝｡
    end
    data_set.G_ox(find(data_set.ok_num~=0),:)=[];

    %% 襍ｷ蜍募ｿ�鬆育匱髮ｻ讖�
    data_set.hantei_a=find(data_set.hantei_on_time==0); % 襍ｷ蜍輔＠縺ｪ縺�縺ｨ縺�縺代↑縺�
    data_set.ok_num = 1;
    for i = data_set.hantei_a
        data_set.ok_num=data_set.ok_num.*(data_set.G_ox(:,i)==1);% 荳�縺､縺ｧ繧�0縺後≠縺｣縺溘ｉ繝�繝｡
    end
    data_set.G_ox(find(data_set.ok_num==0),:)=[];

    %% LFC逋ｺ髮ｻ讖溷ｿ�縺�1讖溯ｵｷ蜍�
    data_set.LFC_on_off=sum(data_set.G_ox(:,7:11)');
    data_set.ok_num=find(data_set.LFC_on_off==0);
    data_set.G_ox(data_set.ok_num,:)=[];
    
    % P=[];PV_cur=[];Fval=[];Flag=[];
    % balancing_EDC_LFC=[];B=[];m=0;TLO=[];
    if data_set.kk ~= 0
        %% 繝輔ぅ繝ｼ繝峨ヰ繝�繧ｯ繧ｱ繝ｼ繧ｹ�ｼ郁ｪｿ謨ｴ蜉帙′遒ｺ菫昴〒縺阪↑縺�迥ｶ諷九ｒ蝗樣∩縺吶ｋ縺溘ａ縺ｫ�ｼ悟燕譎ょ綾縺ｫ謌ｻ縺｣縺ｦ蜃ｺ蜉帷憾諷九ｒ螟峨∴縺ｦ譛�驕ｩ蛹門ｮ滓命�ｼ�
        P0=[];PV_cur0=[];Fval0=[];Flag0=[];
        balancing_EDC_LFC0=[];B0=[];m0=0;
        
        %%%% 遞ｼ蜒榊庄閭ｽ縺ｪ逋ｺ髮ｻ讖溘�ｮ蜈ｨ邨�縺ｿ蜷医ｏ縺� %%%%
        L=0;
        for h=1:length(data_set.G_r_ox)
            data_set.s=size(nchoosek(data_set.G_r_ox,h));
            L=L+data_set.s(1);
        end
        data_set.L=L;
        data_set.Z=nan(data_set.L,length(data_set.G_r_ox));
        data_set.h_end=0;
        for h=1:length(data_set.G_r_ox)
            data_set.s=size(nchoosek(data_set.G_r_ox,h));
            kumi=nchoosek(data_set.G_r_ox,h);
            for hh=1:data_set.s(1)
                data_set.hhh=data_set.h_end+hh;
                data_set.Z(data_set.hhh,1:length(kumi(hh,:)))=kumi(hh,:);
            end
            data_set.h_end=data_set.hhh;
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        data_set.m=0;
        %%%% 蜷�邨�縺ｿ蜷医ｏ縺帙〒縺ｮ譛�驕ｩ蛹� %%%%
        for g=1:length(data_set.Z)
            data_set.gg=data_set.Z(g,:);
            data_set.gg(isnan(data_set.gg))=[];
            data_set.g_select=[];
            for g0 = data_set.gg
                %%%% 8 vs 10 %%%%
                if g0 == 8
                    if isempty(find(data_set.G_r_ox==10)) == 0
                        %%%% 10縺悟性縺ｾ繧後ｋ蝣ｴ蜷� %%%%
                        g1=g0;
                    else
                        %%%% 10縺悟性縺ｾ繧後↑縺�蝣ｴ蜷� %%%%
                        g1=[g0,10];
                    end
                end

                if g0 == 10
                    if isempty(find(data_set.G_r_ox==8)) == 0
                        %%%% 8縺悟性縺ｾ繧後ｋ蝣ｴ蜷� %%%%
                        g1=g0;
                    else
                        %%%% 8縺悟性縺ｾ繧後↑縺�蝣ｴ蜷� %%%%
                        g1=[g0,8];
                    end
                end

                %%%% 7 vs 9 %%%%
                if g0 == 7
                    if isempty(find(data_set.G_r_ox==9)) == 0
                        %%%% 9縺悟性縺ｾ繧後ｋ蝣ｴ蜷� %%%%
                        g1=g0;
                    else
                        %%%% 9縺悟性縺ｾ繧後↑縺�蝣ｴ蜷� %%%%
                        g1=[g0,9];
                    end
                end

                if g0 == 9
                    if isempty(find(data_set.G_r_ox==7)) == 0
                        %%%% 7縺悟性縺ｾ繧後ｋ蝣ｴ蜷� %%%%
                        g1=g0;
                    else
                        %%%% 7縺悟性縺ｾ繧後↑縺�蝣ｴ蜷� %%%%
                        g1=[g0,7];
                    end
                end

                %%%% 5 vs 6 %%%%
                if g0 == 5
                    if isempty(find(data_set.G_r_ox==6)) == 0
                        %%%% 6縺悟性縺ｾ繧後ｋ蝣ｴ蜷� %%%%
                        g1=g0;
                    else
                        %%%% 6縺悟性縺ｾ繧後↑縺�蝣ｴ蜷� %%%%
                        g1=[g0,6];
                    end
                end

                if g0 == 6
                    if isempty(find(data_set.G_r_ox==5)) == 0
                        %%%% 5縺悟性縺ｾ繧後ｋ蝣ｴ蜷� %%%%
                        g1=g0;
                    else
                        %%%% 5縺悟性縺ｾ繧後↑縺�蝣ｴ蜷� %%%%
                        g1=[g0,5];
                    end
                end
                
                if g0 == 2
                    if isempty(find(data_set.G_r_ox==3)) == 0
                        %%%% 5縺悟性縺ｾ繧後ｋ蝣ｴ蜷� %%%%
                        g1=g0;
                    else
                        %%%% 5縺悟性縺ｾ繧後↑縺�蝣ｴ蜷� %%%%
                        g1=[g0,3];
                    end
                end
                
                if g0 == 3
                    if isempty(find(data_set.G_r_ox==2)) == 0
                        %%%% 5縺悟性縺ｾ繧後ｋ蝣ｴ蜷� %%%%
                        g1=g0;
                    else
                        %%%% 5縺悟性縺ｾ繧後↑縺�蝣ｴ蜷� %%%%
                        g1=[g0,2];
                    end
                end
                
                if g0 == 1 || g0 == 4 || g0 == 11
                    g1=g0;
                end
                
                data_set.g_select(length(data_set.g_select)+1:length(data_set.g_select)+length(g1))=g1;
            end
            for g_num = data_set.G_on
                data_set.G_ox(find(data_set.G_ox(:,g_num)==0),:)=[];
            end
            for g_num = data_set.g_select
                data_set.G_ox(find(data_set.G_ox(:,g_num)==0),:)=[];
            end
            
        %% 豁｣蟶ｸ繧ｱ繝ｼ繧ｹ(execute_UC.m)
        % I=[];
        data_set.P=[];
        data_set.PV_cur=[];
        data_set.Fval=[];
        data_set.Flag=[];
        data_set.balancing_EDC_LFC=[];
        data_set.B=[];
        for i = 1:size(data_set.G_ox,1)
            data_set.m=data_set.m+1;
    %% 逶ｮ逧�髢｢謨ｰ
    data_set.BC_t=data_set.EDC_reserved_plus(time)+data_set.LFC_reserved_up(time);
    data_set.ND_t=-data_set.demand_30min(time)+data_set.PVF_30min(time);
    data_set.fun = @(p)((data_set.a_k(1)/p(1)*p(1)+data_set.b_k(1)*p(1)+data_set.c_k(1)*p(1)^2)+...
        (data_set.a_k(2)/p(2)*p(2)+data_set.b_k(2)*p(2)+data_set.c_k(2)*p(2)^2)+...
        (data_set.a_k(3)/p(3)*p(3)+data_set.b_k(3)*p(3)+data_set.c_k(3)*p(3)^2)+...
        (data_set.a_k(4)/p(4)*p(4)+data_set.b_k(4)*p(4)+data_set.c_k(4)*p(4)^2)+...
        (data_set.a_k(5)/p(5)*p(5)+data_set.b_k(5)*p(5)+data_set.c_k(5)*p(5)^2)+...
        (data_set.a_k(6)/p(6)*p(6)+data_set.b_k(6)*p(6)+data_set.c_k(6)*p(6)^2)+...
        (data_set.a_k(7)/p(7)*p(7)+data_set.b_k(7)*p(7)+data_set.c_k(7)*p(7)^2)+...
        (data_set.a_k(8)/p(8)*p(8)+data_set.b_k(8)*p(8)+data_set.c_k(8)*p(8)^2)+...
        (data_set.a_k(9)/p(9)*p(9)+data_set.b_k(9)*p(9)+data_set.c_k(9)*p(9)^2)+...
        (data_set.a_k(10)/p(10)*p(10)+data_set.b_k(10)*p(10)+data_set.c_k(10)*p(10)^2)+...
        (data_set.a_k(11)/p(11)*p(11)+data_set.b_k(11)*p(11)+data_set.c_k(11)*p(11)^2));
    % -- 蛻晄悄轤ｹ --
    data_set.x0 = zeros(1,11);
    data_set.output_speed=[3;3;12.5;3;5;5;15;28;10;28;20]*30;
%% 蛻ｶ邏�譚｡莉ｶ
data_set.Const_Out = [0,0,0,0,0,0,0];
% -- 髴�邨ｦ繝舌Λ繝ｳ繧ｹ蛻ｶ邏� --
    data_set.Aeq = data_set.G_ox(i,:); % 遏ｳ豐ｹ4讖滂ｼ檎浹轤ｭ6讖滂ｼ鍬NG1讖�
    data_set.beq = data_set.demand_30min(time)-data_set.PVF_30min(time)-sum(data_set.Const_Out);
% -- EDC隱ｿ謨ｴ蜉帶椛蛻ｶ蛻ｶ邏� --
    data_set.LFC_capacity_t=round(data_set.LFC_reserved_up(time),1);
    data_set.EDC_capacity_t=round(data_set.EDC_reserved_plus(time),1);
% -- 莠梧ｬ｡隱ｿ謨ｴ蜉帷｢ｺ菫晏宛邏� --
   % -- 蜷�譎ょ綾縺ｮ謇�隕∽ｺ梧ｬ｡隱ｿ謨ｴ蜉帙�ｮ邂怜�ｺ (n:隕∫ｴ�逡ｪ蜿ｷ)--
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % [邉ｻ邨ｱ縺ｧ縺ｮ謇�隕∽ｺ梧ｬ｡竭�(n=1),蜷ЛFC讖溘�ｮ謇�隕∽ｺ梧ｬ｡竭�螳ｹ驥従
data_set.Not_LFC_gen=[];
data_set.LFC_gen=7:11;
data_set.LFC_gen=data_set.LFC_gen.*(data_set.Aeq(data_set.LFC_gen)==1);
data_set.LFC_gen(data_set.LFC_gen==0)=[];
data_set.LFC_capacity = [data_set.LFC_capacity_t;zeros(11,1)];
data_set.LFC_capacity(data_set.LFC_gen+1)=data_set.LFC_capacity_t*data_set.output_speed(data_set.LFC_gen,1)/sum(data_set.output_speed(data_set.LFC_gen,1)); % 蜃ｺ蜉帛､牙喧騾溷ｺｦ豈皮紫縺ｫ蠢懊§縺ｦ蛻�驟�

data_set.remain_lfc=data_set.Rate_Min(1:11,1)-data_set.Rate_Min(1:11,2)-data_set.LFC_capacity(2:end);
data_set.remain_lfc=reshape(data_set.remain_lfc,[11,1]);
data_set.lfc_outnum=find(data_set.remain_lfc<0);
data_set.lfc_haibunn_hantei=1;
while isempty(data_set.lfc_outnum)==0
    data_set.LFC_gen = setdiff(data_set.LFC_gen, data_set.lfc_outnum);
    if isempty(data_set.LFC_gen) == 1
        if sum(abs(fix(data_set.remain_lfc))) == 0
            data_set.lfc_haibunn_hantei=1;
        else
            data_set.lfc_haibunn_hantei=0;
        end
        data_set.lfc_outnum=[];
    else
        data_set.LFC_capacity(data_set.lfc_outnum+1)=data_set.LFC_capacity(data_set.lfc_outnum+1)+data_set.remain_lfc(data_set.lfc_outnum); % 謠蝉ｾ帑ｸ榊庄縺ｪ驟榊��驥上ｒ髯､蜴ｻ
        data_set.remain_lfc=sum(data_set.remain_lfc(data_set.lfc_outnum));
        data_set.LFC_capacity(data_set.LFC_gen+1)=data_set.LFC_capacity(data_set.LFC_gen+1)-data_set.remain_lfc*data_set.output_speed(data_set.LFC_gen,1)/sum(data_set.output_speed(data_set.LFC_gen,1)); % 蜃ｺ蜉帛､牙喧騾溷ｺｦ豈皮紫縺ｫ蠢懊§縺ｦ蛻�驟�
        data_set.remain_lfc=data_set.Rate_Min(1:11,1)-data_set.Rate_Min(1:11,2)-data_set.LFC_capacity(2:end);
        data_set.lfc_outnum=find(data_set.remain_lfc<0);
    end
end
% -- 蜷�逋ｺ髮ｻ讖溘�ｮ莠梧ｬ｡竭�逕ｨ螳壽�ｼ蜃ｺ蜉幢ｼ�(髱朖FC讖�:0,LFC讖�:螳壽�ｼ蜃ｺ蜉�)
data_set.LFC_rated = data_set.Rate_Min(1:11,1).*[zeros(6,1);ones(5,1)];
data_set.LFC_rated = [sum(data_set.LFC_rated.*data_set.Aeq');data_set.LFC_rated]; % 蜈ｨLFC讖溘�ｮ蜷郁ｨ亥ｮ壽�ｼ蜃ｺ蜉帙ｒ霑ｽ蜉�

% -- 邉ｻ邨ｱ縺ｧ縺ｮ莠梧ｬ｡竭�遒ｺ菫晏宛邏� --
data_set.A_l0 = [zeros(1,6),ones(1,5)];
data_set.b_l0 = -(data_set.LFC_capacity(1)-data_set.LFC_rated(1));
% -- 髱朖FC讖溘�ｮ莠梧ｬ｡竭�遒ｺ菫晏宛邏� --
data_set.A_l1 = zeros(6,11);
data_set.b_l1 = -data_set.LFC_capacity(2:7);
data_set.b_l1 = data_set.Rate_Min(1:6,1);
% -- LFC讖溘�ｮ莠梧ｬ｡竭�遒ｺ菫晏宛邏� --
data_set.A_l2 = [zeros(1,6),1,zeros(1,4)];       % 遏ｳ轤ｭ3蜿ｷ讖�
data_set.b_l2 = -(data_set.LFC_capacity(8)-data_set.LFC_rated(8));
data_set.A_l3 = [zeros(1,7),1,zeros(1,3)];       % 遏ｳ轤ｭ4蜿ｷ讖�
data_set.b_l3 = -(data_set.LFC_capacity(9)-data_set.LFC_rated(9));
data_set.A_l4 = [zeros(1,8),1,zeros(1,2)];       % 遏ｳ轤ｭ5蜿ｷ讖�
data_set.b_l4 = -(data_set.LFC_capacity(10)-data_set.LFC_rated(10));
data_set.A_l5 = [zeros(1,9),1,zeros(1,1)];       % 遏ｳ轤ｭ6蜿ｷ讖�
data_set.b_l5 = -(data_set.LFC_capacity(11)-data_set.LFC_rated(11));
data_set.A_l6 = [zeros(1,10),1];                 % LNG讖�
data_set.b_l6 = -(data_set.LFC_capacity(12)-data_set.LFC_rated(12));
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   data_set.b_lfc=vertcat(data_set.b_l0,data_set.b_l1,data_set.b_l2,data_set.b_l3,data_set.b_l4,data_set.b_l5,data_set.b_l6);
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   data_set.cost_rate=[];data_set.EDC_gen=1:11; % EDC讖溘�ｯ蜈ｨ縺ｦ
data_set.cost_k=data_set.cost_kWh(data_set.EDC_gen,1);
for k= data_set.EDC_gen
    d=data_set.cost_k;
    d(k)=[];
    data_set.cost_rate=[data_set.cost_rate,sum(d)/sum(data_set.cost_k)];
end

%% 荳翫£莉｣
% [邉ｻ邨ｱ縺ｧ縺ｮ謇�隕∽ｺ梧ｬ｡竭�(n=1),蜷ЕDC讖溘�ｮ謇�隕∽ｺ梧ｬ｡竭�螳ｹ驥従
data_set.EDC_gen=data_set.EDC_gen.*(data_set.Aeq(data_set.EDC_gen)==1);
data_set.EDC_gen(data_set.EDC_gen==0)=[];
data_set.EDC_capacity = [data_set.EDC_capacity_t;zeros(11,1)];
data_set.EDC_capacity(data_set.EDC_gen+1)=data_set.EDC_capacity_t*data_set.cost_rate(data_set.EDC_gen)'/sum(data_set.cost_rate(data_set.EDC_gen)); % 繧ｳ繧ｹ繝域ｯ皮紫縺ｫ蠢懊§縺ｦ蛻�驟�

% -- 蜷�逋ｺ髮ｻ讖溘�ｮ莠梧ｬ｡竭�逕ｨ螳壽�ｼ蜃ｺ蜉幢ｼ�(髱昿DC讖�:0,EDC讖�:螳壽�ｼ蜃ｺ蜉�)
data_set.EDC_rated = [data_set.Rate_Min(1:6,1);data_set.b_l2;data_set.b_l3;data_set.b_l4;data_set.b_l5;data_set.b_l6];
data_set.EDC_rated = [sum(data_set.EDC_rated.*data_set.Aeq');data_set.EDC_rated]; % 蜈ｨEDC讖溘�ｮ蜷郁ｨ亥ｮ壽�ｼ蜃ｺ蜉帙ｒ霑ｽ蜉�

data_set.remain_edc=data_set.EDC_rated(2:end)-data_set.Rate_Min(1:11,2)-data_set.EDC_capacity(2:end);
data_set.remain_edc=reshape(data_set.remain_edc,[11,1]);
data_set.edc_outnum=find(data_set.remain_edc<0);
data_set.edc_haibunn_hantei=1;
while isempty(data_set.edc_outnum)==0
    data_set.EDC_gen = setdiff(data_set.EDC_gen, data_set.edc_outnum);
    if isempty(data_set.EDC_gen) == 1
        if sum(abs(fix(data_set.remain_edc))) == 0
            data_set.edc_haibunn_hantei=1;
        else
            data_set.edc_haibunn_hantei=0;
        end
        data_set.edc_outnum=[];
    else
        data_set.EDC_capacity(data_set.edc_outnum+1)=data_set.EDC_capacity(data_set.edc_outnum+1)+data_set.remain_edc(data_set.edc_outnum); % 謠蝉ｾ帑ｸ榊庄縺ｪ驟榊��驥上ｒ髯､蜴ｻ
        data_set.remain_edc=sum(data_set.remain_edc(data_set.edc_outnum));
        data_set.EDC_capacity(data_set.EDC_gen+1)=data_set.EDC_capacity(data_set.EDC_gen+1)-data_set.remain_edc*data_set.cost_rate(data_set.EDC_gen)'/sum(data_set.cost_rate(data_set.EDC_gen)); % 繧ｳ繧ｹ繝域ｯ皮紫縺ｫ蠢懊§縺ｦ蛻�驟�
        data_set.remain_edc=data_set.EDC_rated(2:end)-data_set.Rate_Min(1:11,2)-data_set.EDC_capacity(2:end);
        data_set.edc_outnum=find(data_set.remain_edc<0);
    end
end
% -- 邉ｻ邨ｱ縺ｧ縺ｮ莠梧ｬ｡竭｡遒ｺ菫晏宛邏� --
data_set.A_e0 = ones(1,11);
data_set.b_e0 = -(data_set.EDC_capacity(1)-data_set.EDC_rated(1));
% -- EDC讖溘�ｮ莠梧ｬ｡竭｡遒ｺ菫晏宛邏� --
data_set.A_e1=[1,zeros(1,10)];
data_set.b_e1=-(data_set.EDC_capacity(2)-data_set.EDC_rated(2));
data_set.A_e2=[zeros(1,1),1,zeros(1,9)];
data_set.b_e2=-(data_set.EDC_capacity(3)-data_set.EDC_rated(3));
data_set.A_e3=[zeros(1,2),1,zeros(1,8)];
data_set.b_e3=-(data_set.EDC_capacity(4)-data_set.EDC_rated(4));
data_set.A_e4=[zeros(1,3),1,zeros(1,7)];
data_set.b_e4=-(data_set.EDC_capacity(5)-data_set.EDC_rated(5));
data_set.A_e5=[zeros(1,4),1,zeros(1,6)];
data_set.b_e5=-(data_set.EDC_capacity(6)-data_set.EDC_rated(6));
data_set.A_e6=[zeros(1,5),1,zeros(1,5)];
data_set.b_e6=-(data_set.EDC_capacity(7)-data_set.EDC_rated(7));
data_set.A_e7=[zeros(1,6),1,zeros(1,4)];
data_set.b_e7=-(data_set.EDC_capacity(8)-data_set.EDC_rated(8));
data_set.A_e8=[zeros(1,7),1,zeros(1,3)];
data_set.b_e8=-(data_set.EDC_capacity(9)-data_set.EDC_rated(9));
data_set.A_e9=[zeros(1,8),1,zeros(1,2)];
data_set.b_e9=-(data_set.EDC_capacity(10)-data_set.EDC_rated(10));
data_set.A_e10=[zeros(1,9),1,zeros(1,1)];
data_set.b_e10=-(data_set.EDC_capacity(11)-data_set.EDC_rated(11));
data_set.A_e11=[zeros(1,10),1];
data_set.b_e11=-(data_set.EDC_capacity(12)-data_set.EDC_rated(12));

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% -- 逋ｺ髮ｻ讖溷�ｺ蜉帑ｸ贋ｸ矩剞蛻ｶ邏� --
    data_set.ub0 = data_set.Rate_Min(1:11,1);
    data_set.lb0 = data_set.Rate_Min(1:11,2).*data_set.Aeq';

% -- 逋ｺ髮ｻ讖溷�ｺ蜉帛､牙喧騾溷ｺｦ荳贋ｸ矩剞蛻ｶ邏� --
    % 譎ょ綾譁ｭ髱｢2莉･髯阪�ｯ蜑阪�ｮ譛�驕ｩ隗｣縺ｫ萓晏ｭ�
    if time == 1
        data_set.ub1 = data_set.ub0;
        data_set.lb1 = data_set.lb0;
    else
        data_set.ub1 = data_set.UC_planning(time-1,:)'+data_set.output_speed;
        data_set.lb1 = data_set.UC_planning(time-1,:)'-data_set.output_speed;
    end
    
% -- LFC螳ｹ驥冗｢ｺ菫晏宛邏�繧呈ｺ�縺溘☆縺ｹ縺丞ｿ�隕√↑蛻ｶ邏� (蛻昴ａ縺ｯ�ｼ檎匱髮ｻ讖溷�ｺ蜉帑ｸ贋ｸ矩剞蛻ｶ邏�縺ｫ縺吶ｋ) --
    data_set.ub2 = data_set.ub0;
    data_set.lb2 = zeros(11,1);
% -- 襍ｷ蜍慕ｶｭ謖∵凾髢灘宛邏�繧呈ｺ�縺溘☆縺ｹ縺丞ｿ�隕√↑蛻ｶ邏� (蛻昴ａ縺ｯ�ｼ檎匱髮ｻ讖溷�ｺ蜉帑ｸ贋ｸ矩剞蛻ｶ邏�縺ｫ縺吶ｋ) --
    data_set.ub3 = data_set.ub0;
    data_set.lb3 = zeros(11,1);
% -- 蛛懈ｭ｢邯ｭ謖∵凾髢灘宛邏�繧呈ｺ�縺溘☆縺ｹ縺丞ｿ�隕√↑蛻ｶ邏� (蛻昴ａ縺ｯ�ｼ檎匱髮ｻ讖溷�ｺ蜉帑ｸ贋ｸ矩剞蛻ｶ邏�縺ｫ縺吶ｋ) --
    data_set.ub4 = data_set.ub0;
    data_set.lb4 = zeros(11,1);

    data_set.ub5=vertcat(data_set.b_e1,data_set.b_e2,data_set.b_e3,data_set.b_e4,data_set.b_e5,...
        data_set.b_e6,data_set.b_e7,data_set.b_e8,data_set.b_e9,data_set.b_e10,data_set.b_e11);
    
    data_set.ub=horzcat(data_set.ub0,data_set.ub1,data_set.ub2,data_set.ub3,data_set.ub4,data_set.ub5);
    data_set.lb=horzcat(data_set.lb0,data_set.lb1,data_set.lb2,data_set.lb3,data_set.lb4);

    data_set.lb=max(data_set.lb')';                                       % 荳矩剞蛻ｶ邏�:譛�螟ｧ荳矩剞繧貞叙繧�
    data_set.lb(find(data_set.lb<data_set.Rate_Min(1:11,2)))=...
        (data_set.Rate_Min(find(data_set.lb<data_set.Rate_Min(1:11,2)),2)).*...
        data_set.Aeq(find(data_set.lb<data_set.Rate_Min(1:11,2)))';
    data_set.ub=min(data_set.ub')';                                       % 荳企剞蛻ｶ邏�:譛�蟆丈ｸ企剞繧貞叙繧�



    data_set.A=[];data_set.b=[];

%% 菫晏ｭ�
data_set.sikiiatai2=sum(data_set.ub(find(data_set.Aeq)));
    if data_set.EDC_capacity_t>=0 && round(data_set.sikiiatai2,1)>=round(data_set.beq,1) && data_set.lfc_haibunn_hantei==1 && data_set.edc_haibunn_hantei==1
        data_set.lb_sum=sum(data_set.lb.*data_set.Aeq');
        if data_set.lb_sum<=data_set.beq
            data_set.delta_lb=ones(11,1).*(10^-3);
        elseif data_set.lb_sum>data_set.beq
            
            data_set.fun = @(p)((data_set.a_k(1)/p(1)*p(1)+data_set.b_k(1)*p(1)+data_set.c_k(1)*p(1)^2)+...
                (data_set.a_k(2)/p(2)*p(2)+data_set.b_k(2)*p(2)+data_set.c_k(2)*p(2)^2)+...
                (data_set.a_k(3)/p(3)*p(3)+data_set.b_k(3)*p(3)+data_set.c_k(3)*p(3)^2)+...
                (data_set.a_k(4)/p(4)*p(4)+data_set.b_k(4)*p(4)+data_set.c_k(4)*p(4)^2)+...
                (data_set.a_k(5)/p(5)*p(5)+data_set.b_k(5)*p(5)+data_set.c_k(5)*p(5)^2)+...
                (data_set.a_k(6)/p(6)*p(6)+data_set.b_k(6)*p(6)+data_set.c_k(6)*p(6)^2)+...
                (data_set.a_k(7)/p(7)*p(7)+data_set.b_k(7)*p(7)+data_set.c_k(7)*p(7)^2)+...
                (data_set.a_k(8)/p(8)*p(8)+data_set.b_k(8)*p(8)+data_set.c_k(8)*p(8)^2)+...
                (data_set.a_k(9)/p(9)*p(9)+data_set.b_k(9)*p(9)+data_set.c_k(9)*p(9)^2)+...
                (data_set.a_k(10)/p(10)*p(10)+data_set.b_k(10)*p(10)+data_set.c_k(10)*p(10)^2)+...
                (data_set.a_k(11)/p(11)*p(11)+data_set.b_k(11)*p(11)+data_set.c_k(11)*p(11)^2)+...
                -p(12)*8000*(1+0.5)); % PV謚大宛驥�=PV雋ｷ蜿紋ｾ｡譬ｼ(1+ﾎｱ)ﾃ猶V謚大宛驥�=8000(1+0.5)ﾃ用(12)
                % PV雋ｷ蜿紋ｾ｡譬ｼ8000蜀�/MWh, 縺九ｓ縺溘ｓ蝗ｺ螳壻ｾ｡譬ｼ繝励Λ繝ｳ�ｼ�https://www.rikuden.co.jp/koteikaitori/kaitorimenu.html�ｼ�
                data_set.x0(12)=0;
                data_set.Aeq(12)=1;
                data_set.lb(12)=-inf;
                data_set.ub(12)=data_set.beq-data_set.lb_sum;
                data_set.delta_lb(12)=0;
        end
        
        [p,fval,exitflag] = fmincon(data_set.fun,data_set.x0,data_set.A,data_set.b,data_set.Aeq,data_set.beq,data_set.lb,data_set.ub+data_set.delta_lb);
        
        if exitflag == -2
            fval=10^10^10;
        end

        if length(p) == 11
            data_set.pv_cur=0;
        elseif length(p) == 12
            data_set.pv_cur=p(12);
        end
            
        data_set.p = p(1:11).*(p(1:11)>1);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        data_set.LFC_gen=7:11;
        data_set.EDC_gen=1:11;

% -- 遒ｺ隱堺ｺ矩��:逋ｺ髮ｻ讖溷�ｺ蜉帑ｸ矩剞蛻ｶ邏�繧呈ｺ�縺溘☆縺九←縺�縺� --
    data_set.hantei_min1 = p(1:11)>=data_set.Rate_Min(1:11,2)'-0.01;    % 譛�蟆丞�ｺ蜉帑ｻ･荳翫°縺ｩ縺�縺句愛螳�
    data_set.hantei_min2 = p(1:11)<=0.01;                 % 蛛懈ｭ｢逋ｺ髮ｻ讖溘�ｮ蛻､螳�
    data_set.hantei_min = data_set.hantei_min1+data_set.hantei_min2;  % 蜈ｨ縺ｦ1縺ｫ縺ｪ繧後�ｰOK

% -- 遒ｺ隱堺ｺ矩��:LFC螳ｹ驥冗｢ｺ菫晏宛邏�繧呈ｺ�縺溘☆縺� --
    data_set.b_o=data_set.b_lfc(2:12);
    data_set.LFC_opt = sum((data_set.LFC_rated(data_set.LFC_gen+1)-data_set.b_o(data_set.LFC_gen)).*data_set.hantei_min1(data_set.LFC_gen)'); % 'hantei_min1(LFC_gen)'繧剃ｹ励★繧具ｼ檎ｨｼ蜒広FC讖溘〒縺ｮLFC遒ｺ菫晞�冗ｮ怜�ｺ
    data_set.lfc_surplus = data_set.LFC_opt-data_set.LFC_capacity(1);       % 邉ｻ邨ｱ縺ｧ縺ｮLFC遒ｺ菫晞�丞宛邏�繧呈ｺ�縺溘＠縺ｦ縺�繧後�ｰ豁｣
    data_set.lfc_surplus =round(data_set.lfc_surplus,2);           % 豁｣縺ｫ縺ｪ繧後�ｰOK

% -- 遒ｺ隱堺ｺ矩��:EDC螳ｹ驥冗｢ｺ菫晏宛邏�繧呈ｺ�縺溘☆縺� --
	data_set.EDC_C=(data_set.b_o-(p(:,data_set.EDC_gen))').*data_set.hantei_min1';   % 襍ｷ蜍募●豁｢縺ｫ髢｢繧上ｉ縺夲ｼ鍬FC遒ｺ菫晞�従
    data_set.EDC_opt=sum(data_set.EDC_C);
%     EDC_C=EDC_rated(EDC_gen+1)-(p(:,EDC_gen))';   % 襍ｷ蜍募●豁｢縺ｫ髢｢繧上ｉ縺夲ｼ鍬FC遒ｺ菫晞��
%     EDC_opt = sum(EDC_C.*(p(EDC_gen)~=0)'); % 'hantei_min1(EDC_gen)'繧剃ｹ励★繧具ｼ檎ｨｼ蜒孔DC讖溘〒縺ｮEDC遒ｺ菫晞�冗ｮ怜�ｺ
    data_set.edc_surplus = data_set.EDC_opt-data_set.EDC_capacity(1);       % 邉ｻ邨ｱ縺ｧ縺ｮLFC遒ｺ菫晞�丞宛邏�繧呈ｺ�縺溘＠縺ｦ縺�繧後�ｰ豁｣
    data_set.edc_surplus =round(data_set.edc_surplus,2);           % 豁｣縺ｫ縺ｪ繧後�ｰOK

% % -- 荳九£莉｣遒ｺ隱� --
% rate_min
% EDC_LFC_down=abs(sum((Rate_Min(1:11,2)-p').*Aeq'));
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        data_set.P(data_set.m,:)=p(1:11).*(p(1:11)>1);
        data_set.PV_cur(data_set.m,:)=data_set.pv_cur;
        data_set.Fval(data_set.m,:)=fval;
        data_set.Flag(data_set.m,:)=exitflag;
        data_set.balancing_EDC_LFC(data_set.m,:)=[data_set.LFC_opt,data_set.LFC_capacity_t,data_set.EDC_opt,data_set.EDC_capacity_t];
        data_set.B(data_set.m,:)=data_set.b_lfc(2:12)';
        % data_set.I=[I,i];
    end
end
        end
    else
        %% 豁｣蟶ｸ繧ｱ繝ｼ繧ｹ(execute_UC.m)
        % I=[];
        data_set.P=[];
        data_set.PV_cur=[];
        data_set.Fval=[];
        data_set.Flag=[];
        data_set.balancing_EDC_LFC=[];
        data_set.B=[];
        for i = 1:size(data_set.G_ox,1)
    %% 逶ｮ逧�髢｢謨ｰ
    data_set.BC_t=data_set.EDC_reserved_plus(time)+data_set.LFC_reserved_up(time);
    data_set.ND_t=-data_set.demand_30min(time)+data_set.PVF_30min(time);
    data_set.fun = @(p)((data_set.a_k(1)/p(1)*p(1)+data_set.b_k(1)*p(1)+data_set.c_k(1)*p(1)^2)+...
        (data_set.a_k(2)/p(2)*p(2)+data_set.b_k(2)*p(2)+data_set.c_k(2)*p(2)^2)+...
        (data_set.a_k(3)/p(3)*p(3)+data_set.b_k(3)*p(3)+data_set.c_k(3)*p(3)^2)+...
        (data_set.a_k(4)/p(4)*p(4)+data_set.b_k(4)*p(4)+data_set.c_k(4)*p(4)^2)+...
        (data_set.a_k(5)/p(5)*p(5)+data_set.b_k(5)*p(5)+data_set.c_k(5)*p(5)^2)+...
        (data_set.a_k(6)/p(6)*p(6)+data_set.b_k(6)*p(6)+data_set.c_k(6)*p(6)^2)+...
        (data_set.a_k(7)/p(7)*p(7)+data_set.b_k(7)*p(7)+data_set.c_k(7)*p(7)^2)+...
        (data_set.a_k(8)/p(8)*p(8)+data_set.b_k(8)*p(8)+data_set.c_k(8)*p(8)^2)+...
        (data_set.a_k(9)/p(9)*p(9)+data_set.b_k(9)*p(9)+data_set.c_k(9)*p(9)^2)+...
        (data_set.a_k(10)/p(10)*p(10)+data_set.b_k(10)*p(10)+data_set.c_k(10)*p(10)^2)+...
        (data_set.a_k(11)/p(11)*p(11)+data_set.b_k(11)*p(11)+data_set.c_k(11)*p(11)^2));
    % -- 蛻晄悄轤ｹ --
    data_set.x0 = zeros(1,11);
    data_set.output_speed=[3;3;12.5;3;5;5;15;28;10;28;20]*30;
%% 蛻ｶ邏�譚｡莉ｶ
data_set.Const_Out = [0,0,0,0,0,0,0];
% -- 髴�邨ｦ繝舌Λ繝ｳ繧ｹ蛻ｶ邏� --
    data_set.Aeq = data_set.G_ox(i,:); % 遏ｳ豐ｹ4讖滂ｼ檎浹轤ｭ6讖滂ｼ鍬NG1讖�
    data_set.beq = data_set.demand_30min(time)-data_set.PVF_30min(time)-sum(data_set.Const_Out);
% -- EDC隱ｿ謨ｴ蜉帶椛蛻ｶ蛻ｶ邏� --
    data_set.LFC_capacity_t=round(data_set.LFC_reserved_up(time),1);
    data_set.EDC_capacity_t=round(data_set.EDC_reserved_plus(time),1);
% -- 莠梧ｬ｡隱ｿ謨ｴ蜉帷｢ｺ菫晏宛邏� --
   % -- 蜷�譎ょ綾縺ｮ謇�隕∽ｺ梧ｬ｡隱ｿ謨ｴ蜉帙�ｮ邂怜�ｺ (n:隕∫ｴ�逡ｪ蜿ｷ)--
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % [邉ｻ邨ｱ縺ｧ縺ｮ謇�隕∽ｺ梧ｬ｡竭�(n=1),蜷ЛFC讖溘�ｮ謇�隕∽ｺ梧ｬ｡竭�螳ｹ驥従
data_set.Not_LFC_gen=[];
data_set.LFC_gen=7:11;
data_set.LFC_gen=data_set.LFC_gen.*(data_set.Aeq(data_set.LFC_gen)==1);
data_set.LFC_gen(data_set.LFC_gen==0)=[];
data_set.LFC_capacity = [data_set.LFC_capacity_t;zeros(11,1)];
data_set.LFC_capacity(data_set.LFC_gen+1)=data_set.LFC_capacity_t*data_set.output_speed(data_set.LFC_gen,1)/sum(data_set.output_speed(data_set.LFC_gen,1)); % 蜃ｺ蜉帛､牙喧騾溷ｺｦ豈皮紫縺ｫ蠢懊§縺ｦ蛻�驟�

data_set.remain_lfc=data_set.Rate_Min(1:11,1)-data_set.Rate_Min(1:11,2)-data_set.LFC_capacity(2:end);
data_set.remain_lfc=reshape(data_set.remain_lfc,[11,1]);
data_set.lfc_outnum=find(data_set.remain_lfc<0);
data_set.lfc_haibunn_hantei=1;
while isempty(data_set.lfc_outnum)==0
    data_set.LFC_gen = setdiff(data_set.LFC_gen, data_set.lfc_outnum);
    if isempty(data_set.LFC_gen) == 1
        if sum(abs(fix(data_set.remain_lfc))) == 0
            data_set.lfc_haibunn_hantei=1;
        else
            data_set.lfc_haibunn_hantei=0;
        end
        data_set.lfc_outnum=[];
    else
        data_set.LFC_capacity(data_set.lfc_outnum+1)=data_set.LFC_capacity(data_set.lfc_outnum+1)+data_set.remain_lfc(data_set.lfc_outnum); % 謠蝉ｾ帑ｸ榊庄縺ｪ驟榊��驥上ｒ髯､蜴ｻ
        data_set.remain_lfc=sum(data_set.remain_lfc(data_set.lfc_outnum));
        data_set.LFC_capacity(data_set.LFC_gen+1)=data_set.LFC_capacity(data_set.LFC_gen+1)-data_set.remain_lfc*data_set.output_speed(data_set.LFC_gen,1)/sum(data_set.output_speed(data_set.LFC_gen,1)); % 蜃ｺ蜉帛､牙喧騾溷ｺｦ豈皮紫縺ｫ蠢懊§縺ｦ蛻�驟�
        data_set.remain_lfc=data_set.Rate_Min(1:11,1)-data_set.Rate_Min(1:11,2)-data_set.LFC_capacity(2:end);
        data_set.lfc_outnum=find(data_set.remain_lfc<0);
    end
end
% -- 蜷�逋ｺ髮ｻ讖溘�ｮ莠梧ｬ｡竭�逕ｨ螳壽�ｼ蜃ｺ蜉幢ｼ�(髱朖FC讖�:0,LFC讖�:螳壽�ｼ蜃ｺ蜉�)
data_set.LFC_rated = data_set.Rate_Min(1:11,1).*[zeros(6,1);ones(5,1)];
data_set.LFC_rated = [sum(data_set.LFC_rated.*data_set.Aeq');data_set.LFC_rated]; % 蜈ｨLFC讖溘�ｮ蜷郁ｨ亥ｮ壽�ｼ蜃ｺ蜉帙ｒ霑ｽ蜉�

% -- 邉ｻ邨ｱ縺ｧ縺ｮ莠梧ｬ｡竭�遒ｺ菫晏宛邏� --
data_set.A_l0 = [zeros(1,6),ones(1,5)];
data_set.b_l0 = -(data_set.LFC_capacity(1)-data_set.LFC_rated(1));
% -- 髱朖FC讖溘�ｮ莠梧ｬ｡竭�遒ｺ菫晏宛邏� --
data_set.A_l1 = zeros(6,11);
data_set.b_l1 = -data_set.LFC_capacity(2:7);
data_set.b_l1 = data_set.Rate_Min(1:6,1);
% -- LFC讖溘�ｮ莠梧ｬ｡竭�遒ｺ菫晏宛邏� --
data_set.A_l2 = [zeros(1,6),1,zeros(1,4)];       % 遏ｳ轤ｭ3蜿ｷ讖�
data_set.b_l2 = -(data_set.LFC_capacity(8)-data_set.LFC_rated(8));
data_set.A_l3 = [zeros(1,7),1,zeros(1,3)];       % 遏ｳ轤ｭ4蜿ｷ讖�
data_set.b_l3 = -(data_set.LFC_capacity(9)-data_set.LFC_rated(9));
data_set.A_l4 = [zeros(1,8),1,zeros(1,2)];       % 遏ｳ轤ｭ5蜿ｷ讖�
data_set.b_l4 = -(data_set.LFC_capacity(10)-data_set.LFC_rated(10));
data_set.A_l5 = [zeros(1,9),1,zeros(1,1)];       % 遏ｳ轤ｭ6蜿ｷ讖�
data_set.b_l5 = -(data_set.LFC_capacity(11)-data_set.LFC_rated(11));
data_set.A_l6 = [zeros(1,10),1];                 % LNG讖�
data_set.b_l6 = -(data_set.LFC_capacity(12)-data_set.LFC_rated(12));
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   data_set.b_lfc=vertcat(data_set.b_l0,data_set.b_l1,data_set.b_l2,data_set.b_l3,data_set.b_l4,data_set.b_l5,data_set.b_l6);
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   data_set.cost_rate=[];data_set.EDC_gen=1:11; % EDC讖溘�ｯ蜈ｨ縺ｦ
data_set.cost_k=data_set.cost_kWh(data_set.EDC_gen,1);
for k= data_set.EDC_gen
    d=data_set.cost_k;
    d(k)=[];
    data_set.cost_rate=[data_set.cost_rate,sum(d)/sum(data_set.cost_k)];
end

%% 荳翫£莉｣
% [邉ｻ邨ｱ縺ｧ縺ｮ謇�隕∽ｺ梧ｬ｡竭�(n=1),蜷ЕDC讖溘�ｮ謇�隕∽ｺ梧ｬ｡竭�螳ｹ驥従
data_set.EDC_gen=data_set.EDC_gen.*(data_set.Aeq(data_set.EDC_gen)==1);
data_set.EDC_gen(data_set.EDC_gen==0)=[];
data_set.EDC_capacity = [data_set.EDC_capacity_t;zeros(11,1)];
data_set.EDC_capacity(data_set.EDC_gen+1)=data_set.EDC_capacity_t*data_set.cost_rate(data_set.EDC_gen)'/sum(data_set.cost_rate(data_set.EDC_gen)); % 繧ｳ繧ｹ繝域ｯ皮紫縺ｫ蠢懊§縺ｦ蛻�驟�

% -- 蜷�逋ｺ髮ｻ讖溘�ｮ莠梧ｬ｡竭�逕ｨ螳壽�ｼ蜃ｺ蜉幢ｼ�(髱昿DC讖�:0,EDC讖�:螳壽�ｼ蜃ｺ蜉�)
data_set.EDC_rated = [data_set.Rate_Min(1:6,1);data_set.b_l2;data_set.b_l3;data_set.b_l4;data_set.b_l5;data_set.b_l6];
data_set.EDC_rated = [sum(data_set.EDC_rated.*data_set.Aeq');data_set.EDC_rated]; % 蜈ｨEDC讖溘�ｮ蜷郁ｨ亥ｮ壽�ｼ蜃ｺ蜉帙ｒ霑ｽ蜉�

data_set.remain_edc=data_set.EDC_rated(2:end)-data_set.Rate_Min(1:11,2)-data_set.EDC_capacity(2:end);
data_set.remain_edc=reshape(data_set.remain_edc,[11,1]);
data_set.edc_outnum=find(data_set.remain_edc<0);
data_set.edc_haibunn_hantei=1;
while isempty(data_set.edc_outnum)==0
    data_set.EDC_gen = setdiff(data_set.EDC_gen, data_set.edc_outnum);
    if isempty(data_set.EDC_gen) == 1
        if sum(abs(fix(data_set.remain_edc))) == 0
            data_set.edc_haibunn_hantei=1;
        else
            data_set.edc_haibunn_hantei=0;
        end
        data_set.edc_outnum=[];
    else
        data_set.EDC_capacity(data_set.edc_outnum+1)=data_set.EDC_capacity(data_set.edc_outnum+1)+data_set.remain_edc(data_set.edc_outnum); % 謠蝉ｾ帑ｸ榊庄縺ｪ驟榊��驥上ｒ髯､蜴ｻ
        data_set.remain_edc=sum(data_set.remain_edc(data_set.edc_outnum));
        data_set.EDC_capacity(data_set.EDC_gen+1)=data_set.EDC_capacity(data_set.EDC_gen+1)-data_set.remain_edc*data_set.cost_rate(data_set.EDC_gen)'/sum(data_set.cost_rate(data_set.EDC_gen)); % 繧ｳ繧ｹ繝域ｯ皮紫縺ｫ蠢懊§縺ｦ蛻�驟�
        data_set.remain_edc=data_set.EDC_rated(2:end)-data_set.Rate_Min(1:11,2)-data_set.EDC_capacity(2:end);
        data_set.edc_outnum=find(data_set.remain_edc<0);
    end
end
% -- 邉ｻ邨ｱ縺ｧ縺ｮ莠梧ｬ｡竭｡遒ｺ菫晏宛邏� --
data_set.A_e0 = ones(1,11);
data_set.b_e0 = -(data_set.EDC_capacity(1)-data_set.EDC_rated(1));
% -- EDC讖溘�ｮ莠梧ｬ｡竭｡遒ｺ菫晏宛邏� --
data_set.A_e1=[1,zeros(1,10)];
data_set.b_e1=-(data_set.EDC_capacity(2)-data_set.EDC_rated(2));
data_set.A_e2=[zeros(1,1),1,zeros(1,9)];
data_set.b_e2=-(data_set.EDC_capacity(3)-data_set.EDC_rated(3));
data_set.A_e3=[zeros(1,2),1,zeros(1,8)];
data_set.b_e3=-(data_set.EDC_capacity(4)-data_set.EDC_rated(4));
data_set.A_e4=[zeros(1,3),1,zeros(1,7)];
data_set.b_e4=-(data_set.EDC_capacity(5)-data_set.EDC_rated(5));
data_set.A_e5=[zeros(1,4),1,zeros(1,6)];
data_set.b_e5=-(data_set.EDC_capacity(6)-data_set.EDC_rated(6));
data_set.A_e6=[zeros(1,5),1,zeros(1,5)];
data_set.b_e6=-(data_set.EDC_capacity(7)-data_set.EDC_rated(7));
data_set.A_e7=[zeros(1,6),1,zeros(1,4)];
data_set.b_e7=-(data_set.EDC_capacity(8)-data_set.EDC_rated(8));
data_set.A_e8=[zeros(1,7),1,zeros(1,3)];
data_set.b_e8=-(data_set.EDC_capacity(9)-data_set.EDC_rated(9));
data_set.A_e9=[zeros(1,8),1,zeros(1,2)];
data_set.b_e9=-(data_set.EDC_capacity(10)-data_set.EDC_rated(10));
data_set.A_e10=[zeros(1,9),1,zeros(1,1)];
data_set.b_e10=-(data_set.EDC_capacity(11)-data_set.EDC_rated(11));
data_set.A_e11=[zeros(1,10),1];
data_set.b_e11=-(data_set.EDC_capacity(12)-data_set.EDC_rated(12));

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% -- 逋ｺ髮ｻ讖溷�ｺ蜉帑ｸ贋ｸ矩剞蛻ｶ邏� --
    data_set.ub0 = data_set.Rate_Min(1:11,1);
    data_set.lb0 = data_set.Rate_Min(1:11,2).*data_set.Aeq';

% -- 逋ｺ髮ｻ讖溷�ｺ蜉帛､牙喧騾溷ｺｦ荳贋ｸ矩剞蛻ｶ邏� --
    % 譎ょ綾譁ｭ髱｢2莉･髯阪�ｯ蜑阪�ｮ譛�驕ｩ隗｣縺ｫ萓晏ｭ�
    if time == 1
        data_set.ub1 = data_set.ub0;
        data_set.lb1 = data_set.lb0;
    else
        data_set.ub1 = data_set.UC_planning(time-1,:)'+data_set.output_speed;
        data_set.lb1 = data_set.UC_planning(time-1,:)'-data_set.output_speed;
    end
    
% -- LFC螳ｹ驥冗｢ｺ菫晏宛邏�繧呈ｺ�縺溘☆縺ｹ縺丞ｿ�隕√↑蛻ｶ邏� (蛻昴ａ縺ｯ�ｼ檎匱髮ｻ讖溷�ｺ蜉帑ｸ贋ｸ矩剞蛻ｶ邏�縺ｫ縺吶ｋ) --
    data_set.ub2 = data_set.ub0;
    data_set.lb2 = zeros(11,1);
% -- 襍ｷ蜍慕ｶｭ謖∵凾髢灘宛邏�繧呈ｺ�縺溘☆縺ｹ縺丞ｿ�隕√↑蛻ｶ邏� (蛻昴ａ縺ｯ�ｼ檎匱髮ｻ讖溷�ｺ蜉帑ｸ贋ｸ矩剞蛻ｶ邏�縺ｫ縺吶ｋ) --
    data_set.ub3 = data_set.ub0;
    data_set.lb3 = zeros(11,1);
% -- 蛛懈ｭ｢邯ｭ謖∵凾髢灘宛邏�繧呈ｺ�縺溘☆縺ｹ縺丞ｿ�隕√↑蛻ｶ邏� (蛻昴ａ縺ｯ�ｼ檎匱髮ｻ讖溷�ｺ蜉帑ｸ贋ｸ矩剞蛻ｶ邏�縺ｫ縺吶ｋ) --
    data_set.ub4 = data_set.ub0;
    data_set.lb4 = zeros(11,1);

    data_set.ub5=vertcat(data_set.b_e1,data_set.b_e2,data_set.b_e3,data_set.b_e4,data_set.b_e5,...
        data_set.b_e6,data_set.b_e7,data_set.b_e8,data_set.b_e9,data_set.b_e10,data_set.b_e11);
    
    data_set.ub=horzcat(data_set.ub0,data_set.ub1,data_set.ub2,data_set.ub3,data_set.ub4,data_set.ub5);
    data_set.lb=horzcat(data_set.lb0,data_set.lb1,data_set.lb2,data_set.lb3,data_set.lb4);

    data_set.lb=max(data_set.lb')';                                       % 荳矩剞蛻ｶ邏�:譛�螟ｧ荳矩剞繧貞叙繧�
    data_set.lb(find(data_set.lb<data_set.Rate_Min(1:11,2)))=...
        (data_set.Rate_Min(find(data_set.lb<data_set.Rate_Min(1:11,2)),2)).*...
        data_set.Aeq(find(data_set.lb<data_set.Rate_Min(1:11,2)))';
    data_set.ub=min(data_set.ub')';                                       % 荳企剞蛻ｶ邏�:譛�蟆丈ｸ企剞繧貞叙繧�



    data_set.A=[];data_set.b=[];

%% 菫晏ｭ�
data_set.sikiiatai2=sum(data_set.ub(find(data_set.Aeq)));
    if data_set.EDC_capacity_t>=0 && round(data_set.sikiiatai2,1)>=round(data_set.beq,1) && data_set.lfc_haibunn_hantei==1 && data_set.edc_haibunn_hantei==1
        data_set.lb_sum=sum(data_set.lb.*data_set.Aeq');
        if data_set.lb_sum<=data_set.beq
            data_set.delta_lb=ones(11,1).*(10^-3);
        elseif data_set.lb_sum>data_set.beq
            
            data_set.fun = @(p)((data_set.a_k(1)/p(1)*p(1)+data_set.b_k(1)*p(1)+data_set.c_k(1)*p(1)^2)+...
                (data_set.a_k(2)/p(2)*p(2)+data_set.b_k(2)*p(2)+data_set.c_k(2)*p(2)^2)+...
                (data_set.a_k(3)/p(3)*p(3)+data_set.b_k(3)*p(3)+data_set.c_k(3)*p(3)^2)+...
                (data_set.a_k(4)/p(4)*p(4)+data_set.b_k(4)*p(4)+data_set.c_k(4)*p(4)^2)+...
                (data_set.a_k(5)/p(5)*p(5)+data_set.b_k(5)*p(5)+data_set.c_k(5)*p(5)^2)+...
                (data_set.a_k(6)/p(6)*p(6)+data_set.b_k(6)*p(6)+data_set.c_k(6)*p(6)^2)+...
                (data_set.a_k(7)/p(7)*p(7)+data_set.b_k(7)*p(7)+data_set.c_k(7)*p(7)^2)+...
                (data_set.a_k(8)/p(8)*p(8)+data_set.b_k(8)*p(8)+data_set.c_k(8)*p(8)^2)+...
                (data_set.a_k(9)/p(9)*p(9)+data_set.b_k(9)*p(9)+data_set.c_k(9)*p(9)^2)+...
                (data_set.a_k(10)/p(10)*p(10)+data_set.b_k(10)*p(10)+data_set.c_k(10)*p(10)^2)+...
                (data_set.a_k(11)/p(11)*p(11)+data_set.b_k(11)*p(11)+data_set.c_k(11)*p(11)^2)+...
                -p(12)*8000*(1+0.5)); % PV謚大宛驥�=PV雋ｷ蜿紋ｾ｡譬ｼ(1+ﾎｱ)ﾃ猶V謚大宛驥�=8000(1+0.5)ﾃ用(12)
                % PV雋ｷ蜿紋ｾ｡譬ｼ8000蜀�/MWh, 縺九ｓ縺溘ｓ蝗ｺ螳壻ｾ｡譬ｼ繝励Λ繝ｳ�ｼ�https://www.rikuden.co.jp/koteikaitori/kaitorimenu.html�ｼ�
                data_set.x0(12)=0;
                data_set.Aeq(12)=1;
                data_set.lb(12)=-inf;
                data_set.ub(12)=data_set.beq-data_set.lb_sum;
                data_set.delta_lb(12)=0;
        end
        
        [p,fval,exitflag] = fmincon(data_set.fun,data_set.x0,data_set.A,data_set.b,data_set.Aeq,data_set.beq,data_set.lb,data_set.ub+data_set.delta_lb);
        
        if exitflag == -2
            fval=10^10^10;
        end

        if length(p) == 11
            data_set.pv_cur=0;
        elseif length(p) == 12
            data_set.pv_cur=p(12);
        end
            
        data_set.p = p(1:11).*(p(1:11)>1);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        data_set.LFC_gen=7:11;
        data_set.EDC_gen=1:11;

% -- 遒ｺ隱堺ｺ矩��:逋ｺ髮ｻ讖溷�ｺ蜉帑ｸ矩剞蛻ｶ邏�繧呈ｺ�縺溘☆縺九←縺�縺� --
    data_set.hantei_min1 = p(1:11)>=data_set.Rate_Min(1:11,2)'-0.01;    % 譛�蟆丞�ｺ蜉帑ｻ･荳翫°縺ｩ縺�縺句愛螳�
    data_set.hantei_min2 = p(1:11)<=0.01;                 % 蛛懈ｭ｢逋ｺ髮ｻ讖溘�ｮ蛻､螳�
    data_set.hantei_min = data_set.hantei_min1+data_set.hantei_min2;  % 蜈ｨ縺ｦ1縺ｫ縺ｪ繧後�ｰOK

% -- 遒ｺ隱堺ｺ矩��:LFC螳ｹ驥冗｢ｺ菫晏宛邏�繧呈ｺ�縺溘☆縺� --
    data_set.b_o=data_set.b_lfc(2:12);
    data_set.LFC_opt = sum((data_set.LFC_rated(data_set.LFC_gen+1)-data_set.b_o(data_set.LFC_gen)).*data_set.hantei_min1(data_set.LFC_gen)'); % 'hantei_min1(LFC_gen)'繧剃ｹ励★繧具ｼ檎ｨｼ蜒広FC讖溘〒縺ｮLFC遒ｺ菫晞�冗ｮ怜�ｺ
    data_set.lfc_surplus = data_set.LFC_opt-data_set.LFC_capacity(1);       % 邉ｻ邨ｱ縺ｧ縺ｮLFC遒ｺ菫晞�丞宛邏�繧呈ｺ�縺溘＠縺ｦ縺�繧後�ｰ豁｣
    data_set.lfc_surplus =round(data_set.lfc_surplus,2);           % 豁｣縺ｫ縺ｪ繧後�ｰOK

% -- 遒ｺ隱堺ｺ矩��:EDC螳ｹ驥冗｢ｺ菫晏宛邏�繧呈ｺ�縺溘☆縺� --
	data_set.EDC_C=(data_set.b_o-(p(:,data_set.EDC_gen))').*data_set.hantei_min1';   % 襍ｷ蜍募●豁｢縺ｫ髢｢繧上ｉ縺夲ｼ鍬FC遒ｺ菫晞�従
    data_set.EDC_opt=sum(data_set.EDC_C);
%     EDC_C=EDC_rated(EDC_gen+1)-(p(:,EDC_gen))';   % 襍ｷ蜍募●豁｢縺ｫ髢｢繧上ｉ縺夲ｼ鍬FC遒ｺ菫晞��
%     EDC_opt = sum(EDC_C.*(p(EDC_gen)~=0)'); % 'hantei_min1(EDC_gen)'繧剃ｹ励★繧具ｼ檎ｨｼ蜒孔DC讖溘〒縺ｮEDC遒ｺ菫晞�冗ｮ怜�ｺ
    data_set.edc_surplus = data_set.EDC_opt-data_set.EDC_capacity(1);       % 邉ｻ邨ｱ縺ｧ縺ｮLFC遒ｺ菫晞�丞宛邏�繧呈ｺ�縺溘＠縺ｦ縺�繧後�ｰ豁｣
    data_set.edc_surplus =round(data_set.edc_surplus,2);           % 豁｣縺ｫ縺ｪ繧後�ｰOK

% % -- 荳九£莉｣遒ｺ隱� --
% rate_min
% EDC_LFC_down=abs(sum((Rate_Min(1:11,2)-p').*Aeq'));
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        data_set.P(i,:)=p(1:11).*(p(1:11)>1);
        data_set.PV_cur(i,:)=data_set.pv_cur;
        data_set.Fval(i,:)=fval;
        data_set.Flag(i,:)=exitflag;
        data_set.balancing_EDC_LFC(i,:)=[data_set.LFC_opt,data_set.LFC_capacity_t,data_set.EDC_opt,data_set.EDC_capacity_t];
        data_set.B(i,:)=data_set.b_lfc(2:12)';
        % data_set.I=[I,i];
    end
end
end
    %%%%% 豁｣蟶ｸ繝代ち繝ｼ繝ｳ縺ｯOK�ｼ� %%%%%
    if isempty(find(data_set.Flag==1))*isempty(find(data_set.Flag==2))==1
        data_set.gen_rank=[8,10,7,9,5,6,11,3,2,1,4]; % 逋ｺ髮ｻ讖溽��譁呵ｲｻ繝ｩ繝ｳ繧ｭ繝ｳ繧ｰ�ｼ亥ｷｦ縺九ｉ辯�譁呵ｲｻ縺悟ｮ峨＞逋ｺ髮ｻ讖溽分蜿ｷ�ｼ�
        data_set.G_r_ox=[];
            for g_r=data_set.gen_rank
                g_r_ox=sum((find(data_set.hantei_off_time==0))==g_r);
                if g_r_ox==1
                    data_set.G_r_ox=[data_set.G_r_ox,g_r];
                end
            end
        
        data_set.time_out=time;
        % if exist((['譛�驕ｩ蛹悶ョ繝ｼ繧ｿ繝舌ャ繧ｯ繧｢繝�繝� (譖ｴ譁ｰ)\out_time',num2str(time_out),'.mat']))==2
        %     load((['譛�驕ｩ蛹悶ョ繝ｼ繧ｿ繝舌ャ繧ｯ繧｢繝�繝� (譖ｴ譁ｰ)\out_time',num2str(time_out),'.mat']),'out')
        %     out=out+1;
        % else
        %     out=1;
        % end
        if isempty(max(data_set.off_time(data_set.G_r_ox))) == 1
            time=time-1;
        else
            time=time-max(data_set.off_time(data_set.G_r_ox))-1;
        end
        data_set.G_r_ox(find(data_set.UC_planning(time+1,data_set.G_r_ox)~=0))=[];
        data_set.G_on=find(data_set.UC_planning(time+1,:)~=0);
        data_set.UC_planning(time+1:end,:)=[];
        data_set.PV_CUR(time+1:end,:)=[];
        data_set.kk=data_set.kk+1;
        
        % data_set.out(time)=1;
        % data_set.time(time)=1;
        % data_set.G_r_ox(time)=data_set.G_r_ox;
        % data_set.G_on(time)=data_set.G_on;
    else
        data_set.out_num1=find((data_set.Flag==1)+(data_set.Flag==2)~=1);
        [data_set.out_row,data_set.out_low]=find(data_set.balancing_EDC_LFC<0);
        data_set.out_num=unique([data_set.out_num1;data_set.out_row]);
        data_set.PV_cur(data_set.out_num)=[];
        data_set.Fval(data_set.out_num)=[];
        data_set.P(data_set.out_num,:)=[];
        data_set.balancing_EDC_LFC(data_set.out_num,:)=[];
        data_set.B(data_set.out_num,:)=[];
        data_set.opt_num=min(find(data_set.Fval==min(data_set.Fval)));
        data_set.error=1;
        
        data_set.PV_CUR(time)=data_set.PV_cur(data_set.opt_num);
        data_set.L_C_t(time,:)=data_set.B(data_set.opt_num,:);
        data_set.UC_planning(time,:) = data_set.P(data_set.opt_num,:);
        data_set.Balancing_EDC_LFC(time,:) = [data_set.balancing_EDC_LFC(data_set.opt_num,:),data_set.error];
        
        % clear kk g_r
        % OPT_ANS.PV_CUR(time)=PV_CUR;
        % OPT_ANS.TieLine_Output(time)=TieLine_Output;
        % OPT_ANS.Balancing_EDC_LFC(time)=Balancing_EDC_LFC;
        % OPT_ANS.L_C_t(time)=L_C_t;
        % OPT_ANS.UC_planning(time)=UC_planning;
        % OPT_ANS.on_time(time)=on_time;
        % OPT_ANS.off_time(time)=off_time;
        % OPT_ANS.a(time)=a;
        % OPT_ANS.Const_Out(time)=Const_Out;

        % clearvars -except data_set.end_hour time EDC_reserved_plus EDC_reserved_minus LFC_reserved_up LFC_reserved_down
        data_set.kk=0;data_set.aaa=1;
    end
end
% load(['譛�驕ｩ蛹悶ョ繝ｼ繧ｿ繝舌ャ繧ｯ繧｢繝�繝� (譖ｴ譁ｰ)\data_time',num2str(50),'.mat'])
% load(['../../莠域ｸｬPV蜃ｺ蜉帑ｽ懈�申PVF_30min.mat']) % PVF_30min
% load(['../../髴�隕∝ｮ溽ｸｾ繝ｻ莠域ｸｬ菴懈�申demand_30min.mat']) % demand_30min
% rate_min
% output_speed=[3;3;12.5;3;5;5;15;28;10;28;20]*30;
%% 髴�邨ｦ蜻ｨ豕｢謨ｰ繧ｷ繝溘Η繝ｬ繝ｼ繧ｷ繝ｧ繝ｳ繧貞ｮ滓命縺吶ｋ縺溘ａ縺ｮ.csv菴懈��
% -- G_up_plan_limit.csv --
% lfc=8;
% G_up=get_G_up_plan_limit('G_up_plan_limit.csv');
% l=[zeros(6,1);max(demand_30min)*lfc*LFC_rated(LFC_gen+1)/sum(LFC_rated(LFC_gen+1))];
% G_up([8:11,18],2)=(LFC_rated(LFC_gen+1)-l(LFC_gen));
% writematrix(G_up,'G_up_plan_limit.csv')

% -- G_up_plan_limit.csv --
% LFC_gen=7:11;
data_set.L_C=data_set.Rate_Min(7:11,1)-max(data_set.LFC_reserved_up)*data_set.output_speed(data_set.LFC_gen,1)/sum(data_set.output_speed(data_set.LFC_gen,1)); % 蜃ｺ蜉帛､牙喧騾溷ｺｦ豈皮紫縺ｫ蠢懊§縺ｦ蛻�驟�
data_set.Gupplanlimit=get_Gupplanlimit('G_up_plan_limit.csv');
data_set.Gupplanlimit(8:11,2)=data_set.L_C(1:4);
data_set.Gupplanlimit(18,2)=data_set.L_C(5);
writematrix(data_set.Gupplanlimit,'G_up_plan_limit.csv')

% -- Inertia.csv --


data_set.TEIKAKU=[280,280,556,280,280,280,556,780,556,780,472];
data_set.inertia_i=8*ones(1,11);
data_set.p_on=data_set.UC_planning>0;
data_set.inertia=sum((data_set.inertia_i.*data_set.TEIKAKU.*data_set.p_on)')/1000;
% -- 1遘貞�､ --
data_set.Inertia=zeros(88202,2);
data_set.Inertia(2:end,1)=0:88200;
data_set.x = 0:0.5:24.5;data_set.xq_1min = 1/3600:1/3600:24.5;
data_set.v=data_set.inertia;
data_set.Inertia(2,2) = data_set.v(1);
data_set.Inertia(3:end,2) = interp1(data_set.x,data_set.v,data_set.xq_1min);
data_set.Inertia(:,3)=data_set.Inertia(:,2);
writematrix(data_set.Inertia,'Inertia.csv')

% -- UC_planning 30蜿ｰ逕ｨ縺ｮ陦悟�励∈莉｣蜈･ --
data_set.UC_planning_30min=data_set.UC_planning;
data_set.UC_planning=zeros(50,30);
data_set.UC_planning(:,[1:4,6:11,18])=data_set.UC_planning_30min;

% -- G_Const_Out.csv縺ｸ莉｣蜈･ --
data_set.Const_Out0=zeros(88202,8);
data_set.Const_Out0(2:end,2:8)=data_set.Const_Out.*ones(88201,length(data_set.Const_Out));
data_set.Const_Out=data_set.Const_Out0;
writematrix(data_set.Const_Out,'G_Const_Out.csv')

% -- G_Out.csv --
x = 0:0.5:24.5;
xq_1min = 1/3600:1/3600:24.5;
data_set.G_Out=zeros(88202,31);
data_set.G_Out(2:end,1)=0:88200;
data_set.G_Out(1,2:end)=1:30;
for gen = 1:30
    data_set.v=data_set.UC_planning(:,gen);
    data_set.G_Out(2,gen+1) = data_set.v(1);
    data_set.G_Out(3:end,gen+1) = interp1(x,data_set.v,xq_1min);
end
writematrix(data_set.G_Out,'G_Out.csv')

% -- G_Mode.csv --
data_set.min_output=zeros(1,30);
data_set.min_output([1:4,6:11,18])=data_set.Rate_Min(1:11,2);
data_set.mode=data_set.UC_planning<data_set.min_output;
data_set.G_Out_o=data_set.G_Out(2:end,2:end);
data_set.g_mode=data_set.G_Out_o>=data_set.min_output;
data_set.G_Mode=zeros(88202,31);
data_set.G_Mode(2:end,1)=0:88200;
data_set.G_Mode(1,2:end)=1:30;
% -- 3: EDC, LFC蟇ｾ雎｡讖�(Coal#3,4,5,6,LNG)
% -- 1: EDC蟇ｾ雎｡, LFC髱槫ｯｾ雎｡讖�(蜈ｨOil, Coal#1,2)
data_set.mode_base = zeros(1,30);
data_set.mode_base([1:4,6:11,18]) = 1;
data_set.g_mode = data_set.g_mode.*data_set.mode_base;
data_set.G_Mode(2:end,2:end)=data_set.g_mode;
writematrix(data_set.G_Mode,'G_Mode.csv')

% -- PV_Forecast.csv, Load_Forecast.csv --

% -- 莠域ｸｬPV蜃ｺ蜉� --
    % 菴吝臆蛻�縺ｯ髯､蜴ｻ
    data_set.Sur=(sum(data_set.UC_planning')+data_set.PVF_30min'+(sum(sum(data_set.Const_Out(:,2:end)))/(length(data_set.Const_Out)-1)))-data_set.demand_30min';
    data_set.Sur(find(data_set.Sur<=0))=0;
    data_set.PVF_30min=data_set.PVF_30min-data_set.Sur';
% -- 邯壹″
data_set.PV_Forecast=zeros(88202,2);
data_set.PV_Forecast(2:end,1)=0:88200;
x = 0:0.5:24.5;
xq_1min = 1/3600:1/3600:24.5;
data_set.v=data_set.PVF_30min;
data_set.PV_Forecast(3:end,2) = interp1(x,data_set.v,xq_1min);
% -- 莠域ｸｬ髴�隕� --
data_set.Load_Forecast=zeros(88202,2);
data_set.Load_Forecast(2:end,1)=0:88200;
x = 0:0.5:24.5;
xq_1min = 1/3600:1/3600:24.5;
data_set.v=data_set.demand_30min;
data_set.Load_Forecast(2,2) = data_set.v(1);
data_set.Load_Forecast(3:end,2) = interp1(x,data_set.v,xq_1min);

writematrix(data_set.PV_Forecast,'PV_Forecast.csv')
writematrix(data_set.Load_Forecast,'Load_Forecast.csv')

% -- G_rate.csv --

data_set.G_rate=[zeros(30,1),...
    [3,3,12.5,3,0,5,5,15,28,10,28,20,6,6,21,21,21,...
    20,12.5,12.5,12.5,12.5,12.5,12.5,12.5,12.5,...
    12.5,6.75,10,18]'];
writematrix(data_set.G_rate,'G_rate.csv')

% -- G_up_plan_limit_time.csv --

lfc_t=[];
for gen = 1:11
x = (1:50)';
y = data_set.L_C_t(:,gen);
xi = (1:1/1800:50)';
yi = interp1q(x,y,xi);
lfc_t=[lfc_t,yi];
end
RP=[250;250;500;250;700;250;250;...
435.455979586261;579.517828561021;...
456.970653057507;579.517828561021;...
425;200;200;700;700;700;338.941306115015;...
250;250;250;250;250;250;250;250;...
250;388;337;82.9124653502311];
L_C_t0=[lfc_t(:,1:4),RP(5).*ones(length(yi),1),lfc_t(:,5:10),...
    RP(12:17)'.*ones(length(yi),6),lfc_t(:,11),RP(19:end)'.*ones(length(yi),12)];
data_set.L_C_t=L_C_t0;
writematrix(data_set.L_C_t,'G_up_plan_limit_time.csv')


data_set.Reserved_power=data_set.Balancing_EDC_LFC;
% save Reserved_power.mat Reserved_power
copyfile('Reserved_power.mat','../..')

% -- plot --
% figure,bar([PVF_30min,UC_planning_30min],1,'stacked')
% hold on;plot(demand_30min,'k','LineWidth',1.5)
% legend;get_color;colororder(mycolor_13);
% sec_time_30min;xlim([0.5,48.5])
% figure,bar(LFC_surplus(:,1))
% figure,bar(LFC_surplus(:,2));hold on;plot(demand_30min*lfc)
% figure,bar(cost_t)
% gfigure


    %%
catch ME
end

copyfile('*.csv','../../驕狗畑')
cd ../..
if exist('ME')==0
%% PV菴懈��
irr_data=[data_set.PVO_30min;zeros(3600,1)];
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% initset.m 繧ｷ繝溘Η繝ｬ繝ｼ繧ｷ繝ｧ繝ｳ蛻晄悄譚｡莉ｶ險育ｮ� 螳溯｡後�励Ο繧ｰ繝ｩ繝�
%% 莉･荳倶ｸ｡蟷ｴ蠎ｦ蜈ｱ騾�
cd 驕狗畑
make_csv               %Load.csv/PV_Out.csv縺ｮ菴懈��  莉悶お繝ｪ繧｢髴�隕√�ｮ菴懊ｊ譁ｹ

%% Load.csv/PV_Out.csv縺ｮ菴懈�撰ｼ郁�ｪ繧ｨ繝ｪ繧｢�ｼ�
%% 髴�隕�
Word=[0 0 0]; %[TIME 閾ｪ繧ｨ繝ｪ繧｢縲�莉悶お繝ｪ繧｢]=[0 0 0] 驟榊�嶺ｽ懈��
Load=[(1:88200)',data_set.demand_1sec(1:88200),data_set.demand_1sec(901:89100)]; %[譎る俣 閾ｪ繧ｨ繝ｪ繧｢縺ｮ繝�繝ｼ繧ｿ]縲�驟榊�励�ｮ邨仙粋
% ??莉悶お繝ｪ繧｢??
Load0=[Word;Load]; %[譎る俣 閾ｪ繧ｨ繝ｪ繧｢ 莉悶お繝ｪ繧｢]縲�驟榊�励�ｮ邨仙粋
writematrix(Load0,'Load.csv') %Load.csv縺ｸ縺ｮ譖ｸ縺崎ｾｼ縺ｿ
%% PV
Word=[0 0]; %[TIME PV蜃ｺ蜉嫋=[0 0] 驟榊�嶺ｽ懈��
PV=[(1:88200)',irr_data(1:88200)]; %[譎る俣 閾ｪ繧ｨ繝ｪ繧｢縺ｮ繝�繝ｼ繧ｿ]縲�驟榊�励�ｮ邨仙粋
PV0=[Word;PV]; %[譎る俣 閾ｪ繧ｨ繝ｪ繧｢ 莉悶お繝ｪ繧｢]縲�驟榊�励�ｮ邨仙粋
writematrix(PV0,'PV_Out.csv') %PV_Out.csv縺ｸ縺ｮ譖ｸ縺崎ｾｼ縺ｿ

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
% load('../lfclfc.mat')
% P_F = struct('PV_Forecast',PV_Forecast);
% PVF = P_F.PV_Forecast(2,:);
% L_F = struct('load_forecast_input',load_forecast_input);
% LOF = L_F.load_forecast_input(2,:);
% save('FO.mat','PVF','LOF')
% P_M = struct('PV_Out',PV_Out);
% PV_MAX = max(P_M.PV_Out(2,:));
% save('PV_MAX.mat','PV_MAX')
PVF=PV_Forecast(2,:);
LOF=load_forecast_input(2,:);
data = movmean(PV_Out(2,:),60);
short_devi=PV_Out(2,:)-data;
delta_PV=PVF-data;
pn=(delta_PV>=0);
PV_real_Output=PV_Out(2,:).*pn+(PVF+short_devi).*(pn==0);
PV_Surplus=PV_Out(2,:)-PV_real_Output;
PV_real_Output=[PV_Out(1,:);PV_real_Output];
% -- delete surplus PV against load
short_devi=load_input(2,:)-(LOF+PVF);
Net_demand=load_input(3,:)-PV_real_Output(2,:);
Net_demand_pn=(Net_demand<=0);
PV_real_Output(2,:)=Net_demand_pn.*load_input(2,:)+PV_real_Output(2,:).*(Net_demand_pn==0);
% -- delete surplus PV against load
% short_devi=Demand_year-(Demand_real_year+PV_forecast_year_line);
% Net_demand=Demand_year-PV_Out;
% Net_demand_pn=(Net_demand<=0);
% 
% PV_Out(isnan(PV_Out))=0;
%% Simulink縺ｮ螳溯｡�
try
% if lfc >= 100
% open_system('Hydro_load.slx')
% sim('Hydro_load.slx')
% else
open_system('AGC30_PVcut.slx')
sim('AGC30_PVcut.slx')
% end
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
%%
if mode == 1
filename = ['nXAI_ML_Sigma_',num2str(sigma),'_LFC_',num2str(lfc),'_PVcapacity_',num2str(PVC),'_',num2str(year),num2str(month),num2str(day)];
elseif mode == 2
filename = ['ML_E_Sigma_',num2str(sigma),'_LFC_',num2str(lfc),'_PVcapacity_',num2str(PVC),'_',num2str(year),num2str(month),num2str(day)];
elseif mode == 3
filename = ['ML_W_Sigma_',num2str(sigma),'_LFC_',num2str(lfc),'_PVcapacity_',num2str(PVC),'_',num2str(year),num2str(month),num2str(day)];
elseif mode == 4
filename = ['ML_T_Sigma_',num2str(sigma),'_LFC_',num2str(lfc),'_PVcapacity_',num2str(PVC),'_',num2str(year),num2str(month),num2str(day)];
elseif mode == 5
filename = ['ML_T_V_Sigma_',num2str(sigma),'_LFC_',num2str(lfc),'_PVcapacity_',num2str(PVC),'_',num2str(year),num2str(month),num2str(day)];
end
LFC = load('UC遶区｡�\LFC.mat');
% cd E:\02_繝�繝ｼ繧ｿ菫晏ｭ�
cd F:\NSD_results
%% 菫晏ｭ�
% save(filename,'PV_CUR','LFC_t','Reserved_power','short_devi','PV_real_Output','PV_Surplus','LFC_up','LFC_down','PV_MAX','G_Out_UC','g_const_out_sum','load_forecast_input','PV_Forecast','Oil_Output','Coal_Output','Combine_Output','LOF','PVF','dpout','load_input','dfout','TieLineLoadout','LFC_Output','EDC_Output','PV_Out','LFC','inertia_input')
cd C:\Users\PowerSystemLab\Desktop\01_遐皮ｩｶ雉�譁兔05_螳溯｡後ヵ繧｡繧､繝ｫ\program\蜈ｨ菴灘ｮ溯｡�
%                 dfout = round((dfout),2);
%                 F_stay(dfout(3600*4:3600*20))
%                 global aaa aaaa
%                 aaa = (aaa>=95);
%                 aaaa = (aaaa==100);
%                 hantei = aaa*aaaa;
else
if mode == 1
filename = ['Sigma_',num2str(sigma),'_LFC_',num2str(lfc),'_PVcapacity_',num2str(PVC),'_',num2str(year),num2str(month),num2str(day),'.mat'];
elseif mode == 2
filename = ['E_Sigma_',num2str(sigma),'_LFC_',num2str(lfc),'_PVcapacity_',num2str(PVC),'_',num2str(year),num2str(month),num2str(day),'.mat'];
elseif mode == 3
filename = ['W_Sigma_',num2str(sigma),'_LFC_',num2str(lfc),'_PVcapacity_',num2str(PVC),'_',num2str(year),num2str(month),num2str(day),'.mat'];
elseif mode == 4
filename = ['T_Sigma_',num2str(sigma),'_LFC_',num2str(lfc),'_PVcapacity_',num2str(PVC),'_',num2str(year),num2str(month),num2str(day),'.mat'];
elseif mode == 5
filename = ['T_V_Sigma_',num2str(sigma),'_LFC_',num2str(lfc),'_PVcapacity_',num2str(PVC),'_',num2str(year),num2str(month),num2str(day),'.mat'];
end
% cd E:\02_繝�繝ｼ繧ｿ菫晏ｭ�
cd F:\NSD_results
% save(filename,'time_out','ME','UC_planning','Balancing_EDC_LFC','EDC_reserved_plus','EDC_reserved_minus','LFC_reserved_up','LFC_reserved_down','PV_CUR','L_C_t')
cd C:\Users\PowerSystemLab\Desktop\01_遐皮ｩｶ雉�譁兔05_螳溯｡後ヵ繧｡繧､繝ｫ\program\蜈ｨ菴灘ｮ溯｡�
end
% end
end
end