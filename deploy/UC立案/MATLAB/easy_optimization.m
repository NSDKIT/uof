%% 統計解析
load('mode.mat')
        if mode == 1
            file_PV = 'MS';
        elseif mode == 2
            file_PV = 'BiE';
        elseif mode == 3
            file_PV = 'BiW';
        elseif mode == 4
            file_PV = 'MOT';
        elseif mode == 5
            file_PV = 'BiT';
        end
load(['E:\03_結果\Annual analysis\',file_PV,'_',num2str(PVC),'_',num2str(year_l),'_',num2str(month_l),'_',num2str(day_l),'.mat'],'G_Out_UC')
save('G_Out_UC.mat','G_Out_UC')
G_OX=(G_Out_UC(1:1800:88201,[1:4,6:11,18]))~=0;
save('G_OX.mat','G_OX') 
p=pwd;
delete('最適化データバックアップ (更新)\data_time*')
delete('最適化データバックアップ (更新)\out_time*')
load('../../demand_30min.mat') % demand_30min
load('../../PVF_30min.mat') % PVF_30min
%% 静的
RES=demand_30min*.1+PVF_30min*.25;
%% 配分
EDC_reserved_plus=RES*(5/6);
LFC_reserved_up=RES*(1/6);
clearvars -except EDC_reserved_plus LFC_reserved_up p
%% LFC+EDC調整力が系統の許容調整力範囲を超えた分は除去
rate_min
System_lfc_max=sum(Rate_Min(7:11,1)-Rate_Min(7:11,2));
LFC_reduce=(System_lfc_max-LFC_reserved_up).*(LFC_reserved_up>=System_lfc_max);
LFC_reserved_up=LFC_reserved_up+LFC_reduce;
System_reserve_max=sum(Rate_Min(1:11,1)-Rate_Min(1:11,2));
System_reserve_need=EDC_reserved_plus+LFC_reserved_up;
EDC_reduce=(System_reserve_max-System_reserve_need).*(System_reserve_need>=System_reserve_max);
EDC_reserved_plus=EDC_reserved_plus+EDC_reduce;
cd(p)
%% 必要データの作成，読み込み(任意)
ass_data
% -- 空行列作成 --
UC_planning = []; % 最適解保存行列
Balancing_EDC_LFC = [];
on_time=zeros(1,11);
off_time=zeros(1,11);
cost_t = [];PV_CUR=[];TieLine_Output=[];L_C_t=[];Reserved_power=[];time0=0;
%%%%% 最適化開始 %%%%%
time=0;a=[];edc_out.edc_out=zeros(1,50);
kk=0;aaa=1;
on_time_pre=zeros(1,11);
off_time_pre=zeros(1,11);
while time < hour
    time=time+1;
    if time~=1
        load(['最適化データバックアップ (更新)\data_time',num2str(time-1),'.mat'])
    end
    ass_data
    %%%%% 最適化開始 %%%%%
    hantei = 1;mm=0;
    P=[];PV_cur=[];Fval=[];Flag=[];
    balancing_EDC_LFC=[];B=[];m=0;TLO=[];
    
    load('G_OX.mat')
    G_ox=G_OX(time,:).*1;
    execute_UC

    error=1;    
    PV_CUR=[PV_CUR;PV_cur];
    % TieLine_Output=[TieLine_Output;TLO(opt_num)];
    L_C_t=[L_C_t;B];
    UC_planning = [UC_planning;P];
    Balancing_EDC_LFC = [Balancing_EDC_LFC;...
        [balancing_EDC_LFC,error]];
    
    clear kk g_r
    save(['最適化データバックアップ (更新)\data_time',num2str(time),'.mat'],...
        'PV_CUR','TieLine_Output','Balancing_EDC_LFC','L_C_t','UC_planning','on_time','off_time','a','Const_Out')
    clearvars -except hour time EDC_reserved_plus EDC_reserved_minus LFC_reserved_up LFC_reserved_down
    kk=0;aaa=1;
end

load(['最適化データバックアップ (更新)\data_time',num2str(50),'.mat'])
load(['../../PVF_30min.mat']) % PVF_30min
PVF_30min=PVF_30min';
load(['../../demand_30min.mat']) % demand_30min
demand_30min=demand_30min';
rate_min
output_speed=[3;3;12.5;3;5;5;15;28;10;28;20]*30;
%% 需給周波数シミュレーションを実施するための.csv作成
% -- G_up_plan_limit.csv --
% lfc=8;
% G_up=get_G_up_plan_limit('G_up_plan_limit.csv');
% l=[zeros(6,1);max(demand_30min)*lfc*LFC_rated(LFC_gen+1)/sum(LFC_rated(LFC_gen+1))];
% G_up([8:11,18],2)=(LFC_rated(LFC_gen+1)-l(LFC_gen));
% writematrix(G_up,'G_up_plan_limit.csv')

% -- G_up_plan_limit.csv --
LFC_gen=7:11;
L_C=Rate_Min(7:11,1)-max(LFC_reserved_up)*output_speed(LFC_gen,1)/sum(output_speed(LFC_gen,1)); % 出力変化速度比率に応じて分配
Gupplanlimit=get_Gupplanlimit('G_up_plan_limit.csv');
Gupplanlimit(8:11,2)=L_C(1:4);
Gupplanlimit(18,2)=L_C(5);
writematrix(Gupplanlimit,'G_up_plan_limit.csv')

% -- Inertia.csv --
calculate_inertia
writematrix(Inertia,'Inertia.csv')

% -- UC_planning 30台用の行列へ代入 --
UC_planning_30min=UC_planning;
UC_planning=[UC_planning(:,1:4),zeros(50,1),UC_planning(:,5:10),zeros(50,6),UC_planning(:,11),zeros(50,12)];

% -- G_Const_Out.csvへ代入 --
Const_Out=Const_Out.*ones(88201,length(Const_Out));
t=0:88200;R_1=zeros(1,8);
Const_Out=[t',Const_Out];
Const_Out=[R_1;Const_Out];
writematrix(Const_Out,'G_Const_Out.csv')

% -- G_Out.csv --
make_G_Out
writematrix(G_Out,'G_Out.csv')

% -- G_Mode.csv --
make_G_Mode
writematrix(G_Mode,'G_Mode.csv')

% -- PV_Forecast.csv, Load_Forecast.csv --
make_Forecast
writematrix(PV_Forecast,'PV_Forecast.csv')
writematrix(Load_Forecast,'Load_Forecast.csv')

% -- G_rate.csv --
G_rate=[3,3,12.5,3,0,5,5,15,28,10,28,20,6,6,21,21,21,...
    20,12.5,12.5,12.5,12.5,12.5,12.5,12.5,12.5,...
    12.5,6.75,10,18];
G_rate(1:4)=output_speed(1:4)/30;
G_rate(6:11)=output_speed(5:10)/30;
G_rate(18)=output_speed(11)/30;
G_rate=[zeros(30,1),G_rate'];
writematrix(G_rate,'G_rate.csv')

% -- G_up_plan_limit_time.csv --

lfc_t=[];
for gen = 1:11
        
    x = (1:50)'; 
    y = L_C_t(:,gen);
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
L_C_t=[lfc_t(:,1:4),RP(5).*ones(length(yi),1),lfc_t(:,5:10),...
    RP(12:17)'.*ones(length(yi),6),lfc_t(:,11),RP(19:end)'.*ones(length(yi),12)];

writematrix(L_C_t,'G_up_plan_limit_time.csv')


Reserved_power=Balancing_EDC_LFC;
save Reserved_power.mat Reserved_power
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