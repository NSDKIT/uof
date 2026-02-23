clear
cd C:\Users\PowerSystemLab\Desktop\01_研究資料\05_実行ファイル\program\全体実行

data_set = struct();
data_set.meth=1;
data_set.pv_ox = 1;
data_set.start_time = '00'; % 初期時刻 JST1 = T1 + 9h 
                            % T1 = '00' : 初期時刻 前日9:00 売買用
                            % T2 = '06' : 初期時刻 前日15:00 再計画
data_set.sigma = 2;
data_set.rm_pv = .25; % 調整力:PV出力に対する割合
data_set.rm_de = .10; % 調整力:需要に対する割合
data_set.pv_set = 1;
data_set.RES_lfc=1/6;
data_set.RES_edc=5/6;

data_set.PV_R = 1100:2000:11100; % 

%% 日時情報作成
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

%% 既設PV容量
load(['基本データ/PV_base_',num2str(data_set.YYYY),'.mat'])
data_set.PV_base=[PV_base(end-2:end,3)',PV_base(1:end-3,3)'];
%% システム出力係数
load(['基本データ/PR_',num2str(data_set.YYYY),'.mat'])
data_set.PR=PR;
%% MSMの倍数係数
load(['基本データ/MSM_bai_',num2str(data_set.YYYY),'.mat'])
data_set.MSM_bai=MSM_bai;

%% 予測日射量
load('irr_fore_data.mat')
data_set.irr_fore_data=irr_fore_data;
%% 実測日射量
load('irr_mea_data.mat')
data_set.irr_mea_data=irr_mea_data;
%% 予測・実測需要
load('D_1sec.mat');load('D_30min.mat')
data_set.D_1sec=D_1sec;
data_set.D_30min=D_30min;

data_set.x_t=0:.5:23;
data_set.T_30min=24;
data_set.T_1sec=86401;

%% UC立案時の必要データ
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
data_set.gen_on = data_set.ON_time*ones(1,11); % 1断面: 30分 (ex:1.5時間: 3断面)
data_set.gen_off = data_set.OFF_time*ones(1,11); % 1断面: 30分 (ex:1.5時間: 3断面)
data_set.kk=0;
data_set.aaa=1;

%% シミュレーション実行開始
clearvars -except data_set
for mode = 3:5
for PVC = data_set.PV_R
    %% PV予測
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
    %% PV実測
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
    %% 需要作成
    data_set.demand_1sec=data_set.D_1sec(data_set.DN,:)';
    data_set.demand_30min=data_set.D_30min(data_set.DN,:)';
    %% 発電起動停止計画への書き込み
    cd('UC立案/MATLAB')
    try
        delete((['最適化データバックアップ (更新)\data_time*']))
        delete((['最適化データバックアップ (更新)\out_time*']))
    %% 算出
    data_set.RES=data_set.demand_30min*data_set.rm_de+data_set.PVF_30min*data_set.rm_pv;
    %% 配分
    data_set.EDC_reserved_plus=data_set.RES*data_set.RES_edc;
    data_set.LFC_reserved_up=data_set.RES*data_set.RES_lfc;
    %% LFC+EDC調整力が系統の許容調整力範囲を超えた分は除去
    data_set.System_lfc_max=sum(data_set.Rate_Min(7:11,1)-data_set.Rate_Min(7:11,2));
    data_set.LFC_reduce=(data_set.System_lfc_max-data_set.LFC_reserved_up).*(data_set.LFC_reserved_up>=data_set.System_lfc_max);
    data_set.LFC_reserved_up=data_set.LFC_reserved_up+data_set.LFC_reduce;
    data_set.System_reserve_max=sum(data_set.Rate_Min(1:11,1)-data_set.Rate_Min(1:11,2));
    data_set.System_reserve_need=data_set.EDC_reserved_plus+data_set.LFC_reserved_up;
    data_set.EDC_reduce=(data_set.System_reserve_max-data_set.System_reserve_need).*(data_set.System_reserve_need>=data_set.System_reserve_max);
    data_set.EDC_reserved_plus=data_set.EDC_reserved_plus+data_set.EDC_reduce;
    %% 必要データの作成，読み込み(任意)
% -- 空行列作成 --
    % UC_planning = []; % 最適解保存行列
    % Balancing_EDC_LFC = [];
    % cost_t = [];PV_CUR=[];TieLine_Output=[];L_C_t=[];Reserved_power=[];time0=0;
    %%%%% 最適化開始 %%%%%
    time=0;
    a=[];
    edc_out=zeros(1,50);

    out_inf=struct();
    make_opt_data=struct();
    OPT_ANS=struct();

    while time < data_set.end_hour
    time=time+1;
    if time~=1
        % 前時刻データの取得
        % load(['最適化データバックアップ (更新)\data_time',num2str(time-1),'.mat'])
    else
        data_set.on_time=zeros(1,11);
        data_set.off_time =zeros(1,11);
    end
    % ass_data
    %%%%% 組み合わせ作成 %%%%%
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
        % load((['最適化データバックアップ (更新)\out_time',num2str(time_out),'.mat']))
    else
        % -- 時刻間での引き続きに必要なデータ以外は除去(開始時と同じ状態にする) --
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
    %%%%%%% 起動停止維持時間制約を満たすか? %%%%%%%
    if time == 1
        data_set.hantei_on_time = ones(1,11);     % 非稼働機は対象外だから1，稼働機は制約を満たしてれば1
        data_set.hantei_off_time = ones(1,11);    % 非停止機は対象外だから1，停止機は制約を満たしてれば1
    else
    if isempty(a) ~= 0
        data_set.pre_on = (data_set.UC_planning(time-1,:)~=0); % 前時刻断面での起動状態の確認
        data_set.pre_off = data_set.pre_on==0;                                 % 前時刻断面での停止状態の確認
        % -- 起動維持時間制約の対象発電機 --
        data_set.on_const_gen = (data_set.pre_on~=0);
        data_set.on_time = (data_set.on_time+data_set.pre_on).*data_set.pre_on;
        % -- 停止維持時間制約の対象発電機 --
        data_set.off_const_gen = (data_set.pre_off~=0);
        data_set.off_time = (data_set.off_time+data_set.pre_off).*data_set.pre_off;
    end
    data_set.hantei_on_time = (data_set.on_time==0)+(data_set.on_time>=data_set.gen_on);     % 非稼働機は対象外だから1，稼働機は制約を満たしてれば1
    data_set.hantei_off_time = (data_set.off_time==0)+(data_set.off_time>=data_set.gen_off); % 非停止機は対象外だから1，停止機は制約を満たしてれば1
    end
    
    %%%%% 最適化開始 %%%%%
    data_set.hantei = 1;
    data_set.mm=0;

    %% 停止必須発電機
    data_set.hantei_a=find(data_set.hantei_off_time==0);
    data_set.ok_num = 0;
    for i = data_set.hantei_a
        data_set.ok_num=data_set.ok_num+(data_set.G_ox(:,i)==1);% 一つでも1があったらダメ
    end
    data_set.G_ox(find(data_set.ok_num~=0),:)=[];

    %% 起動必須発電機
    data_set.hantei_a=find(data_set.hantei_on_time==0); % 起動しないといけない
    data_set.ok_num = 1;
    for i = data_set.hantei_a
        data_set.ok_num=data_set.ok_num.*(data_set.G_ox(:,i)==1);% 一つでも0があったらダメ
    end
    data_set.G_ox(find(data_set.ok_num==0),:)=[];

    %% LFC発電機必ず1機起動
    data_set.LFC_on_off=sum(data_set.G_ox(:,7:11)');
    data_set.ok_num=find(data_set.LFC_on_off==0);
    data_set.G_ox(data_set.ok_num,:)=[];
    
    % P=[];PV_cur=[];Fval=[];Flag=[];
    % balancing_EDC_LFC=[];B=[];m=0;TLO=[];
    if data_set.kk ~= 0
        %% フィードバックケース（調整力が確保できない状態を回避するために，前時刻に戻って出力状態を変えて最適化実施）
        P0=[];PV_cur0=[];Fval0=[];Flag0=[];
        balancing_EDC_LFC0=[];B0=[];m0=0;
        
        %%%% 稼働可能な発電機の全組み合わせ %%%%
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
        %%%% 各組み合わせでの最適化 %%%%
        for g=1:length(data_set.Z)
            data_set.gg=data_set.Z(g,:);
            data_set.gg(isnan(data_set.gg))=[];
            data_set.g_select=[];
            for g0 = data_set.gg
                %%%% 8 vs 10 %%%%
                if g0 == 8
                    if isempty(find(data_set.G_r_ox==10)) == 0
                        %%%% 10が含まれる場合 %%%%
                        g1=g0;
                    else
                        %%%% 10が含まれない場合 %%%%
                        g1=[g0,10];
                    end
                end

                if g0 == 10
                    if isempty(find(data_set.G_r_ox==8)) == 0
                        %%%% 8が含まれる場合 %%%%
                        g1=g0;
                    else
                        %%%% 8が含まれない場合 %%%%
                        g1=[g0,8];
                    end
                end

                %%%% 7 vs 9 %%%%
                if g0 == 7
                    if isempty(find(data_set.G_r_ox==9)) == 0
                        %%%% 9が含まれる場合 %%%%
                        g1=g0;
                    else
                        %%%% 9が含まれない場合 %%%%
                        g1=[g0,9];
                    end
                end

                if g0 == 9
                    if isempty(find(data_set.G_r_ox==7)) == 0
                        %%%% 7が含まれる場合 %%%%
                        g1=g0;
                    else
                        %%%% 7が含まれない場合 %%%%
                        g1=[g0,7];
                    end
                end

                %%%% 5 vs 6 %%%%
                if g0 == 5
                    if isempty(find(data_set.G_r_ox==6)) == 0
                        %%%% 6が含まれる場合 %%%%
                        g1=g0;
                    else
                        %%%% 6が含まれない場合 %%%%
                        g1=[g0,6];
                    end
                end

                if g0 == 6
                    if isempty(find(data_set.G_r_ox==5)) == 0
                        %%%% 5が含まれる場合 %%%%
                        g1=g0;
                    else
                        %%%% 5が含まれない場合 %%%%
                        g1=[g0,5];
                    end
                end
                
                if g0 == 2
                    if isempty(find(data_set.G_r_ox==3)) == 0
                        %%%% 5が含まれる場合 %%%%
                        g1=g0;
                    else
                        %%%% 5が含まれない場合 %%%%
                        g1=[g0,3];
                    end
                end
                
                if g0 == 3
                    if isempty(find(data_set.G_r_ox==2)) == 0
                        %%%% 5が含まれる場合 %%%%
                        g1=g0;
                    else
                        %%%% 5が含まれない場合 %%%%
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
            
        %% 正常ケース(execute_UC.m)
        % I=[];
        data_set.P=[];
        data_set.PV_cur=[];
        data_set.Fval=[];
        data_set.Flag=[];
        data_set.balancing_EDC_LFC=[];
        data_set.B=[];
        for i = 1:size(data_set.G_ox,1)
            data_set.m=data_set.m+1;
    %% 目的関数
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
    % -- 初期点 --
    data_set.x0 = zeros(1,11);
    data_set.output_speed=[3;3;12.5;3;5;5;15;28;10;28;20]*30;
%% 制約条件
data_set.Const_Out = [0,0,0,0,0,0,0];
% -- 需給バランス制約 --
    data_set.Aeq = data_set.G_ox(i,:); % 石油4機，石炭6機，LNG1機
    data_set.beq = data_set.demand_30min(time)-data_set.PVF_30min(time)-sum(data_set.Const_Out);
% -- EDC調整力抑制制約 --
    data_set.LFC_capacity_t=round(data_set.LFC_reserved_up(time),1);
    data_set.EDC_capacity_t=round(data_set.EDC_reserved_plus(time),1);
% -- 二次調整力確保制約 --
   % -- 各時刻の所要二次調整力の算出 (n:要素番号)--
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % [系統での所要二次①(n=1),各LFC機の所要二次①容量]
data_set.Not_LFC_gen=[];
data_set.LFC_gen=7:11;
data_set.LFC_gen=data_set.LFC_gen.*(data_set.Aeq(data_set.LFC_gen)==1);
data_set.LFC_gen(data_set.LFC_gen==0)=[];
data_set.LFC_capacity = [data_set.LFC_capacity_t;zeros(11,1)];
data_set.LFC_capacity(data_set.LFC_gen+1)=data_set.LFC_capacity_t*data_set.output_speed(data_set.LFC_gen,1)/sum(data_set.output_speed(data_set.LFC_gen,1)); % 出力変化速度比率に応じて分配

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
        data_set.LFC_capacity(data_set.lfc_outnum+1)=data_set.LFC_capacity(data_set.lfc_outnum+1)+data_set.remain_lfc(data_set.lfc_outnum); % 提供不可な配分量を除去
        data_set.remain_lfc=sum(data_set.remain_lfc(data_set.lfc_outnum));
        data_set.LFC_capacity(data_set.LFC_gen+1)=data_set.LFC_capacity(data_set.LFC_gen+1)-data_set.remain_lfc*data_set.output_speed(data_set.LFC_gen,1)/sum(data_set.output_speed(data_set.LFC_gen,1)); % 出力変化速度比率に応じて分配
        data_set.remain_lfc=data_set.Rate_Min(1:11,1)-data_set.Rate_Min(1:11,2)-data_set.LFC_capacity(2:end);
        data_set.lfc_outnum=find(data_set.remain_lfc<0);
    end
end
% -- 各発電機の二次①用定格出力，(非LFC機:0,LFC機:定格出力)
data_set.LFC_rated = data_set.Rate_Min(1:11,1).*[zeros(6,1);ones(5,1)];
data_set.LFC_rated = [sum(data_set.LFC_rated.*data_set.Aeq');data_set.LFC_rated]; % 全LFC機の合計定格出力を追加

% -- 系統での二次①確保制約 --
data_set.A_l0 = [zeros(1,6),ones(1,5)];
data_set.b_l0 = -(data_set.LFC_capacity(1)-data_set.LFC_rated(1));
% -- 非LFC機の二次①確保制約 --
data_set.A_l1 = zeros(6,11);
data_set.b_l1 = -data_set.LFC_capacity(2:7);
data_set.b_l1 = data_set.Rate_Min(1:6,1);
% -- LFC機の二次①確保制約 --
data_set.A_l2 = [zeros(1,6),1,zeros(1,4)];       % 石炭3号機
data_set.b_l2 = -(data_set.LFC_capacity(8)-data_set.LFC_rated(8));
data_set.A_l3 = [zeros(1,7),1,zeros(1,3)];       % 石炭4号機
data_set.b_l3 = -(data_set.LFC_capacity(9)-data_set.LFC_rated(9));
data_set.A_l4 = [zeros(1,8),1,zeros(1,2)];       % 石炭5号機
data_set.b_l4 = -(data_set.LFC_capacity(10)-data_set.LFC_rated(10));
data_set.A_l5 = [zeros(1,9),1,zeros(1,1)];       % 石炭6号機
data_set.b_l5 = -(data_set.LFC_capacity(11)-data_set.LFC_rated(11));
data_set.A_l6 = [zeros(1,10),1];                 % LNG機
data_set.b_l6 = -(data_set.LFC_capacity(12)-data_set.LFC_rated(12));
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   data_set.b_lfc=vertcat(data_set.b_l0,data_set.b_l1,data_set.b_l2,data_set.b_l3,data_set.b_l4,data_set.b_l5,data_set.b_l6);
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   data_set.cost_rate=[];data_set.EDC_gen=1:11; % EDC機は全て
data_set.cost_k=data_set.cost_kWh(data_set.EDC_gen,1);
for k= data_set.EDC_gen
    d=data_set.cost_k;
    d(k)=[];
    data_set.cost_rate=[data_set.cost_rate,sum(d)/sum(data_set.cost_k)];
end

%% 上げ代
% [系統での所要二次①(n=1),各EDC機の所要二次①容量]
data_set.EDC_gen=data_set.EDC_gen.*(data_set.Aeq(data_set.EDC_gen)==1);
data_set.EDC_gen(data_set.EDC_gen==0)=[];
data_set.EDC_capacity = [data_set.EDC_capacity_t;zeros(11,1)];
data_set.EDC_capacity(data_set.EDC_gen+1)=data_set.EDC_capacity_t*data_set.cost_rate(data_set.EDC_gen)'/sum(data_set.cost_rate(data_set.EDC_gen)); % コスト比率に応じて分配

% -- 各発電機の二次①用定格出力，(非EDC機:0,EDC機:定格出力)
data_set.EDC_rated = [data_set.Rate_Min(1:6,1);data_set.b_l2;data_set.b_l3;data_set.b_l4;data_set.b_l5;data_set.b_l6];
data_set.EDC_rated = [sum(data_set.EDC_rated.*data_set.Aeq');data_set.EDC_rated]; % 全EDC機の合計定格出力を追加

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
        data_set.EDC_capacity(data_set.edc_outnum+1)=data_set.EDC_capacity(data_set.edc_outnum+1)+data_set.remain_edc(data_set.edc_outnum); % 提供不可な配分量を除去
        data_set.remain_edc=sum(data_set.remain_edc(data_set.edc_outnum));
        data_set.EDC_capacity(data_set.EDC_gen+1)=data_set.EDC_capacity(data_set.EDC_gen+1)-data_set.remain_edc*data_set.cost_rate(data_set.EDC_gen)'/sum(data_set.cost_rate(data_set.EDC_gen)); % コスト比率に応じて分配
        data_set.remain_edc=data_set.EDC_rated(2:end)-data_set.Rate_Min(1:11,2)-data_set.EDC_capacity(2:end);
        data_set.edc_outnum=find(data_set.remain_edc<0);
    end
end
% -- 系統での二次②確保制約 --
data_set.A_e0 = ones(1,11);
data_set.b_e0 = -(data_set.EDC_capacity(1)-data_set.EDC_rated(1));
% -- EDC機の二次②確保制約 --
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


% -- 発電機出力上下限制約 --
    data_set.ub0 = data_set.Rate_Min(1:11,1);
    data_set.lb0 = data_set.Rate_Min(1:11,2).*data_set.Aeq';

% -- 発電機出力変化速度上下限制約 --
    % 時刻断面2以降は前の最適解に依存
    if time == 1
        data_set.ub1 = data_set.ub0;
        data_set.lb1 = data_set.lb0;
    else
        data_set.ub1 = data_set.UC_planning(time-1,:)'+data_set.output_speed;
        data_set.lb1 = data_set.UC_planning(time-1,:)'-data_set.output_speed;
    end
    
% -- LFC容量確保制約を満たすべく必要な制約 (初めは，発電機出力上下限制約にする) --
    data_set.ub2 = data_set.ub0;
    data_set.lb2 = zeros(11,1);
% -- 起動維持時間制約を満たすべく必要な制約 (初めは，発電機出力上下限制約にする) --
    data_set.ub3 = data_set.ub0;
    data_set.lb3 = zeros(11,1);
% -- 停止維持時間制約を満たすべく必要な制約 (初めは，発電機出力上下限制約にする) --
    data_set.ub4 = data_set.ub0;
    data_set.lb4 = zeros(11,1);

    data_set.ub5=vertcat(data_set.b_e1,data_set.b_e2,data_set.b_e3,data_set.b_e4,data_set.b_e5,...
        data_set.b_e6,data_set.b_e7,data_set.b_e8,data_set.b_e9,data_set.b_e10,data_set.b_e11);
    
    data_set.ub=horzcat(data_set.ub0,data_set.ub1,data_set.ub2,data_set.ub3,data_set.ub4,data_set.ub5);
    data_set.lb=horzcat(data_set.lb0,data_set.lb1,data_set.lb2,data_set.lb3,data_set.lb4);

    data_set.lb=max(data_set.lb')';                                       % 下限制約:最大下限を取る
    data_set.lb(find(data_set.lb<data_set.Rate_Min(1:11,2)))=...
        (data_set.Rate_Min(find(data_set.lb<data_set.Rate_Min(1:11,2)),2)).*...
        data_set.Aeq(find(data_set.lb<data_set.Rate_Min(1:11,2)))';
    data_set.ub=min(data_set.ub')';                                       % 上限制約:最小上限を取る



    data_set.A=[];data_set.b=[];

%% 保存
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
                -p(12)*8000*(1+0.5)); % PV抑制量=PV買取価格(1+α)×PV抑制量=8000(1+0.5)×p(12)
                % PV買取価格8000円/MWh, かんたん固定価格プラン（https://www.rikuden.co.jp/koteikaitori/kaitorimenu.html）
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

% -- 確認事項:発電機出力下限制約を満たすかどうか --
    data_set.hantei_min1 = p(1:11)>=data_set.Rate_Min(1:11,2)'-0.01;    % 最小出力以上かどうか判定
    data_set.hantei_min2 = p(1:11)<=0.01;                 % 停止発電機の判定
    data_set.hantei_min = data_set.hantei_min1+data_set.hantei_min2;  % 全て1になればOK

% -- 確認事項:LFC容量確保制約を満たすか --
    data_set.b_o=data_set.b_lfc(2:12);
    data_set.LFC_opt = sum((data_set.LFC_rated(data_set.LFC_gen+1)-data_set.b_o(data_set.LFC_gen)).*data_set.hantei_min1(data_set.LFC_gen)'); % 'hantei_min1(LFC_gen)'を乗ずる，稼働LFC機でのLFC確保量算出
    data_set.lfc_surplus = data_set.LFC_opt-data_set.LFC_capacity(1);       % 系統でのLFC確保量制約を満たしていれば正
    data_set.lfc_surplus =round(data_set.lfc_surplus,2);           % 正になればOK

% -- 確認事項:EDC容量確保制約を満たすか --
	data_set.EDC_C=(data_set.b_o-(p(:,data_set.EDC_gen))').*data_set.hantei_min1';   % 起動停止に関わらず，LFC確保量]
    data_set.EDC_opt=sum(data_set.EDC_C);
%     EDC_C=EDC_rated(EDC_gen+1)-(p(:,EDC_gen))';   % 起動停止に関わらず，LFC確保量
%     EDC_opt = sum(EDC_C.*(p(EDC_gen)~=0)'); % 'hantei_min1(EDC_gen)'を乗ずる，稼働EDC機でのEDC確保量算出
    data_set.edc_surplus = data_set.EDC_opt-data_set.EDC_capacity(1);       % 系統でのLFC確保量制約を満たしていれば正
    data_set.edc_surplus =round(data_set.edc_surplus,2);           % 正になればOK

% % -- 下げ代確認 --
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
        %% 正常ケース(execute_UC.m)
        % I=[];
        data_set.P=[];
        data_set.PV_cur=[];
        data_set.Fval=[];
        data_set.Flag=[];
        data_set.balancing_EDC_LFC=[];
        data_set.B=[];
        for i = 1:size(data_set.G_ox,1)
    %% 目的関数
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
    % -- 初期点 --
    data_set.x0 = zeros(1,11);
    data_set.output_speed=[3;3;12.5;3;5;5;15;28;10;28;20]*30;
%% 制約条件
data_set.Const_Out = [0,0,0,0,0,0,0];
% -- 需給バランス制約 --
    data_set.Aeq = data_set.G_ox(i,:); % 石油4機，石炭6機，LNG1機
    data_set.beq = data_set.demand_30min(time)-data_set.PVF_30min(time)-sum(data_set.Const_Out);
% -- EDC調整力抑制制約 --
    data_set.LFC_capacity_t=round(data_set.LFC_reserved_up(time),1);
    data_set.EDC_capacity_t=round(data_set.EDC_reserved_plus(time),1);
% -- 二次調整力確保制約 --
   % -- 各時刻の所要二次調整力の算出 (n:要素番号)--
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % [系統での所要二次①(n=1),各LFC機の所要二次①容量]
data_set.Not_LFC_gen=[];
data_set.LFC_gen=7:11;
data_set.LFC_gen=data_set.LFC_gen.*(data_set.Aeq(data_set.LFC_gen)==1);
data_set.LFC_gen(data_set.LFC_gen==0)=[];
data_set.LFC_capacity = [data_set.LFC_capacity_t;zeros(11,1)];
data_set.LFC_capacity(data_set.LFC_gen+1)=data_set.LFC_capacity_t*data_set.output_speed(data_set.LFC_gen,1)/sum(data_set.output_speed(data_set.LFC_gen,1)); % 出力変化速度比率に応じて分配

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
        data_set.LFC_capacity(data_set.lfc_outnum+1)=data_set.LFC_capacity(data_set.lfc_outnum+1)+data_set.remain_lfc(data_set.lfc_outnum); % 提供不可な配分量を除去
        data_set.remain_lfc=sum(data_set.remain_lfc(data_set.lfc_outnum));
        data_set.LFC_capacity(data_set.LFC_gen+1)=data_set.LFC_capacity(data_set.LFC_gen+1)-data_set.remain_lfc*data_set.output_speed(data_set.LFC_gen,1)/sum(data_set.output_speed(data_set.LFC_gen,1)); % 出力変化速度比率に応じて分配
        data_set.remain_lfc=data_set.Rate_Min(1:11,1)-data_set.Rate_Min(1:11,2)-data_set.LFC_capacity(2:end);
        data_set.lfc_outnum=find(data_set.remain_lfc<0);
    end
end
% -- 各発電機の二次①用定格出力，(非LFC機:0,LFC機:定格出力)
data_set.LFC_rated = data_set.Rate_Min(1:11,1).*[zeros(6,1);ones(5,1)];
data_set.LFC_rated = [sum(data_set.LFC_rated.*data_set.Aeq');data_set.LFC_rated]; % 全LFC機の合計定格出力を追加

% -- 系統での二次①確保制約 --
data_set.A_l0 = [zeros(1,6),ones(1,5)];
data_set.b_l0 = -(data_set.LFC_capacity(1)-data_set.LFC_rated(1));
% -- 非LFC機の二次①確保制約 --
data_set.A_l1 = zeros(6,11);
data_set.b_l1 = -data_set.LFC_capacity(2:7);
data_set.b_l1 = data_set.Rate_Min(1:6,1);
% -- LFC機の二次①確保制約 --
data_set.A_l2 = [zeros(1,6),1,zeros(1,4)];       % 石炭3号機
data_set.b_l2 = -(data_set.LFC_capacity(8)-data_set.LFC_rated(8));
data_set.A_l3 = [zeros(1,7),1,zeros(1,3)];       % 石炭4号機
data_set.b_l3 = -(data_set.LFC_capacity(9)-data_set.LFC_rated(9));
data_set.A_l4 = [zeros(1,8),1,zeros(1,2)];       % 石炭5号機
data_set.b_l4 = -(data_set.LFC_capacity(10)-data_set.LFC_rated(10));
data_set.A_l5 = [zeros(1,9),1,zeros(1,1)];       % 石炭6号機
data_set.b_l5 = -(data_set.LFC_capacity(11)-data_set.LFC_rated(11));
data_set.A_l6 = [zeros(1,10),1];                 % LNG機
data_set.b_l6 = -(data_set.LFC_capacity(12)-data_set.LFC_rated(12));
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   data_set.b_lfc=vertcat(data_set.b_l0,data_set.b_l1,data_set.b_l2,data_set.b_l3,data_set.b_l4,data_set.b_l5,data_set.b_l6);
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   data_set.cost_rate=[];data_set.EDC_gen=1:11; % EDC機は全て
data_set.cost_k=data_set.cost_kWh(data_set.EDC_gen,1);
for k= data_set.EDC_gen
    d=data_set.cost_k;
    d(k)=[];
    data_set.cost_rate=[data_set.cost_rate,sum(d)/sum(data_set.cost_k)];
end

%% 上げ代
% [系統での所要二次①(n=1),各EDC機の所要二次①容量]
data_set.EDC_gen=data_set.EDC_gen.*(data_set.Aeq(data_set.EDC_gen)==1);
data_set.EDC_gen(data_set.EDC_gen==0)=[];
data_set.EDC_capacity = [data_set.EDC_capacity_t;zeros(11,1)];
data_set.EDC_capacity(data_set.EDC_gen+1)=data_set.EDC_capacity_t*data_set.cost_rate(data_set.EDC_gen)'/sum(data_set.cost_rate(data_set.EDC_gen)); % コスト比率に応じて分配

% -- 各発電機の二次①用定格出力，(非EDC機:0,EDC機:定格出力)
data_set.EDC_rated = [data_set.Rate_Min(1:6,1);data_set.b_l2;data_set.b_l3;data_set.b_l4;data_set.b_l5;data_set.b_l6];
data_set.EDC_rated = [sum(data_set.EDC_rated.*data_set.Aeq');data_set.EDC_rated]; % 全EDC機の合計定格出力を追加

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
        data_set.EDC_capacity(data_set.edc_outnum+1)=data_set.EDC_capacity(data_set.edc_outnum+1)+data_set.remain_edc(data_set.edc_outnum); % 提供不可な配分量を除去
        data_set.remain_edc=sum(data_set.remain_edc(data_set.edc_outnum));
        data_set.EDC_capacity(data_set.EDC_gen+1)=data_set.EDC_capacity(data_set.EDC_gen+1)-data_set.remain_edc*data_set.cost_rate(data_set.EDC_gen)'/sum(data_set.cost_rate(data_set.EDC_gen)); % コスト比率に応じて分配
        data_set.remain_edc=data_set.EDC_rated(2:end)-data_set.Rate_Min(1:11,2)-data_set.EDC_capacity(2:end);
        data_set.edc_outnum=find(data_set.remain_edc<0);
    end
end
% -- 系統での二次②確保制約 --
data_set.A_e0 = ones(1,11);
data_set.b_e0 = -(data_set.EDC_capacity(1)-data_set.EDC_rated(1));
% -- EDC機の二次②確保制約 --
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


% -- 発電機出力上下限制約 --
    data_set.ub0 = data_set.Rate_Min(1:11,1);
    data_set.lb0 = data_set.Rate_Min(1:11,2).*data_set.Aeq';

% -- 発電機出力変化速度上下限制約 --
    % 時刻断面2以降は前の最適解に依存
    if time == 1
        data_set.ub1 = data_set.ub0;
        data_set.lb1 = data_set.lb0;
    else
        data_set.ub1 = data_set.UC_planning(time-1,:)'+data_set.output_speed;
        data_set.lb1 = data_set.UC_planning(time-1,:)'-data_set.output_speed;
    end
    
% -- LFC容量確保制約を満たすべく必要な制約 (初めは，発電機出力上下限制約にする) --
    data_set.ub2 = data_set.ub0;
    data_set.lb2 = zeros(11,1);
% -- 起動維持時間制約を満たすべく必要な制約 (初めは，発電機出力上下限制約にする) --
    data_set.ub3 = data_set.ub0;
    data_set.lb3 = zeros(11,1);
% -- 停止維持時間制約を満たすべく必要な制約 (初めは，発電機出力上下限制約にする) --
    data_set.ub4 = data_set.ub0;
    data_set.lb4 = zeros(11,1);

    data_set.ub5=vertcat(data_set.b_e1,data_set.b_e2,data_set.b_e3,data_set.b_e4,data_set.b_e5,...
        data_set.b_e6,data_set.b_e7,data_set.b_e8,data_set.b_e9,data_set.b_e10,data_set.b_e11);
    
    data_set.ub=horzcat(data_set.ub0,data_set.ub1,data_set.ub2,data_set.ub3,data_set.ub4,data_set.ub5);
    data_set.lb=horzcat(data_set.lb0,data_set.lb1,data_set.lb2,data_set.lb3,data_set.lb4);

    data_set.lb=max(data_set.lb')';                                       % 下限制約:最大下限を取る
    data_set.lb(find(data_set.lb<data_set.Rate_Min(1:11,2)))=...
        (data_set.Rate_Min(find(data_set.lb<data_set.Rate_Min(1:11,2)),2)).*...
        data_set.Aeq(find(data_set.lb<data_set.Rate_Min(1:11,2)))';
    data_set.ub=min(data_set.ub')';                                       % 上限制約:最小上限を取る



    data_set.A=[];data_set.b=[];

%% 保存
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
                -p(12)*8000*(1+0.5)); % PV抑制量=PV買取価格(1+α)×PV抑制量=8000(1+0.5)×p(12)
                % PV買取価格8000円/MWh, かんたん固定価格プラン（https://www.rikuden.co.jp/koteikaitori/kaitorimenu.html）
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

% -- 確認事項:発電機出力下限制約を満たすかどうか --
    data_set.hantei_min1 = p(1:11)>=data_set.Rate_Min(1:11,2)'-0.01;    % 最小出力以上かどうか判定
    data_set.hantei_min2 = p(1:11)<=0.01;                 % 停止発電機の判定
    data_set.hantei_min = data_set.hantei_min1+data_set.hantei_min2;  % 全て1になればOK

% -- 確認事項:LFC容量確保制約を満たすか --
    data_set.b_o=data_set.b_lfc(2:12);
    data_set.LFC_opt = sum((data_set.LFC_rated(data_set.LFC_gen+1)-data_set.b_o(data_set.LFC_gen)).*data_set.hantei_min1(data_set.LFC_gen)'); % 'hantei_min1(LFC_gen)'を乗ずる，稼働LFC機でのLFC確保量算出
    data_set.lfc_surplus = data_set.LFC_opt-data_set.LFC_capacity(1);       % 系統でのLFC確保量制約を満たしていれば正
    data_set.lfc_surplus =round(data_set.lfc_surplus,2);           % 正になればOK

% -- 確認事項:EDC容量確保制約を満たすか --
	data_set.EDC_C=(data_set.b_o-(p(:,data_set.EDC_gen))').*data_set.hantei_min1';   % 起動停止に関わらず，LFC確保量]
    data_set.EDC_opt=sum(data_set.EDC_C);
%     EDC_C=EDC_rated(EDC_gen+1)-(p(:,EDC_gen))';   % 起動停止に関わらず，LFC確保量
%     EDC_opt = sum(EDC_C.*(p(EDC_gen)~=0)'); % 'hantei_min1(EDC_gen)'を乗ずる，稼働EDC機でのEDC確保量算出
    data_set.edc_surplus = data_set.EDC_opt-data_set.EDC_capacity(1);       % 系統でのLFC確保量制約を満たしていれば正
    data_set.edc_surplus =round(data_set.edc_surplus,2);           % 正になればOK

% % -- 下げ代確認 --
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
    %%%%% 正常パターンはOK！ %%%%%
    if isempty(find(data_set.Flag==1))*isempty(find(data_set.Flag==2))==1
        data_set.gen_rank=[8,10,7,9,5,6,11,3,2,1,4]; % 発電機燃料費ランキング（左から燃料費が安い発電機番号）
        data_set.G_r_ox=[];
            for g_r=data_set.gen_rank
                g_r_ox=sum((find(data_set.hantei_off_time==0))==g_r);
                if g_r_ox==1
                    data_set.G_r_ox=[data_set.G_r_ox,g_r];
                end
            end
        
        data_set.time_out=time;
        % if exist((['最適化データバックアップ (更新)\out_time',num2str(time_out),'.mat']))==2
        %     load((['最適化データバックアップ (更新)\out_time',num2str(time_out),'.mat']),'out')
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
% load(['最適化データバックアップ (更新)\data_time',num2str(50),'.mat'])
% load(['../../予測PV出力作成\PVF_30min.mat']) % PVF_30min
% load(['../../需要実績・予測作成\demand_30min.mat']) % demand_30min
% rate_min
% output_speed=[3;3;12.5;3;5;5;15;28;10;28;20]*30;
%% 需給周波数シミュレーションを実施するための.csv作成
% -- G_up_plan_limit.csv --
% lfc=8;
% G_up=get_G_up_plan_limit('G_up_plan_limit.csv');
% l=[zeros(6,1);max(demand_30min)*lfc*LFC_rated(LFC_gen+1)/sum(LFC_rated(LFC_gen+1))];
% G_up([8:11,18],2)=(LFC_rated(LFC_gen+1)-l(LFC_gen));
% writematrix(G_up,'G_up_plan_limit.csv')

% -- G_up_plan_limit.csv --
% LFC_gen=7:11;
data_set.L_C=data_set.Rate_Min(7:11,1)-max(data_set.LFC_reserved_up)*data_set.output_speed(data_set.LFC_gen,1)/sum(data_set.output_speed(data_set.LFC_gen,1)); % 出力変化速度比率に応じて分配
data_set.Gupplanlimit=get_Gupplanlimit('G_up_plan_limit.csv');
data_set.Gupplanlimit(8:11,2)=data_set.L_C(1:4);
data_set.Gupplanlimit(18,2)=data_set.L_C(5);
writematrix(data_set.Gupplanlimit,'G_up_plan_limit.csv')

% -- Inertia.csv --


data_set.TEIKAKU=[280,280,556,280,280,280,556,780,556,780,472];
data_set.inertia_i=8*ones(1,11);
data_set.p_on=data_set.UC_planning>0;
data_set.inertia=sum((data_set.inertia_i.*data_set.TEIKAKU.*data_set.p_on)')/1000;
% -- 1秒値 --
data_set.Inertia=zeros(88202,2);
data_set.Inertia(2:end,1)=0:88200;
data_set.x = 0:0.5:24.5;data_set.xq_1min = 1/3600:1/3600:24.5;
data_set.v=data_set.inertia;
data_set.Inertia(2,2) = data_set.v(1);
data_set.Inertia(3:end,2) = interp1(data_set.x,data_set.v,data_set.xq_1min);
data_set.Inertia(:,3)=data_set.Inertia(:,2);
writematrix(data_set.Inertia,'Inertia.csv')

% -- UC_planning 30台用の行列へ代入 --
data_set.UC_planning_30min=data_set.UC_planning;
data_set.UC_planning=zeros(50,30);
data_set.UC_planning(:,[1:4,6:11,18])=data_set.UC_planning_30min;

% -- G_Const_Out.csvへ代入 --
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
% -- 3: EDC, LFC対象機(Coal#3,4,5,6,LNG)
% -- 1: EDC対象, LFC非対象機(全Oil, Coal#1,2)
data_set.mode_base = zeros(1,30);
data_set.mode_base([1:4,6:11,18]) = 1;
data_set.g_mode = data_set.g_mode.*data_set.mode_base;
data_set.G_Mode(2:end,2:end)=data_set.g_mode;
writematrix(data_set.G_Mode,'G_Mode.csv')

% -- PV_Forecast.csv, Load_Forecast.csv --

% -- 予測PV出力 --
    % 余剰分は除去
    data_set.Sur=(sum(data_set.UC_planning')+data_set.PVF_30min'+(sum(sum(data_set.Const_Out(:,2:end)))/(length(data_set.Const_Out)-1)))-data_set.demand_30min';
    data_set.Sur(find(data_set.Sur<=0))=0;
    data_set.PVF_30min=data_set.PVF_30min-data_set.Sur';
% -- 続き
data_set.PV_Forecast=zeros(88202,2);
data_set.PV_Forecast(2:end,1)=0:88200;
x = 0:0.5:24.5;
xq_1min = 1/3600:1/3600:24.5;
data_set.v=data_set.PVF_30min;
data_set.PV_Forecast(3:end,2) = interp1(x,data_set.v,xq_1min);
% -- 予測需要 --
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

copyfile('*.csv','../../運用')
cd ../..
if exist('ME')==0
%% PV作成
irr_data=[data_set.PVO_30min;zeros(3600,1)];
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% initset.m シミュレーション初期条件計算 実行プログラム
%% 以下両年度共通
cd 運用
make_csv               %Load.csv/PV_Out.csvの作成  他エリア需要の作り方

%% Load.csv/PV_Out.csvの作成（自エリア）
%% 需要
Word=[0 0 0]; %[TIME 自エリア　他エリア]=[0 0 0] 配列作成
Load=[(1:88200)',data_set.demand_1sec(1:88200),data_set.demand_1sec(901:89100)]; %[時間 自エリアのデータ]　配列の結合
% ??他エリア??
Load0=[Word;Load]; %[時間 自エリア 他エリア]　配列の結合
writematrix(Load0,'Load.csv') %Load.csvへの書き込み
%% PV
Word=[0 0]; %[TIME PV出力]=[0 0] 配列作成
PV=[(1:88200)',irr_data(1:88200)]; %[時間 自エリアのデータ]　配列の結合
PV0=[Word;PV]; %[時間 自エリア 他エリア]　配列の結合
writematrix(PV0,'PV_Out.csv') %PV_Out.csvへの書き込み

disp('initset実行')
initset_dataload        % シミュレーション時間等の設定、発電計画データ、標準データの読込み
initset_inertia         % 慣性モデルにおける設定値
initset_trfpP           % 連系線潮流算出モデルにおける設定値
initset_lfc             % LFCモデルの初期値設定値
initset_edc             % EDCモデルの設定値と初期値計算
initset_thermals        % 汽力プラントモデル・GTCCプラントモデルの初期値計算
%                  initset_conhydros       % 定速揚水発電プラントモデルの初期値計算
%                  initset_vahydros        % 可変速揚水発電機モデルの初期値計算
initset_otherarea       % 他エリアモデルの初期値設定
%% 実測データと予測データの比較
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
%% Simulinkの実行
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
disp('シミュレーション終了')
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
%% 制約違反の判定
%                 onoff_ihan=get_ihan('運転停止時間違反.xlsx');
%                 speed_ihan=get_ihan('速度違反.xlsx');
%                 reserved_ihan=get_ihan('予備力違反.xlsx');
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
LFC = load('UC立案\LFC.mat');
% cd E:\02_データ保存
cd F:\NSD_results
%% 保存
% save(filename,'PV_CUR','LFC_t','Reserved_power','short_devi','PV_real_Output','PV_Surplus','LFC_up','LFC_down','PV_MAX','G_Out_UC','g_const_out_sum','load_forecast_input','PV_Forecast','Oil_Output','Coal_Output','Combine_Output','LOF','PVF','dpout','load_input','dfout','TieLineLoadout','LFC_Output','EDC_Output','PV_Out','LFC','inertia_input')
cd C:\Users\PowerSystemLab\Desktop\01_研究資料\05_実行ファイル\program\全体実行
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
% cd E:\02_データ保存
cd F:\NSD_results
% save(filename,'time_out','ME','UC_planning','Balancing_EDC_LFC','EDC_reserved_plus','EDC_reserved_minus','LFC_reserved_up','LFC_reserved_down','PV_CUR','L_C_t')
cd C:\Users\PowerSystemLab\Desktop\01_研究資料\05_実行ファイル\program\全体実行
end
% end
end
end