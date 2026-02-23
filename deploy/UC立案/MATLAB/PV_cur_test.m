% -- ワークスペース，Figureをクリアに --
delete((['最適化データバックアップ (更新)\data_time*']))
delete((['最適化データバックアップ (更新)\out_time*']))
close all
run('二次調整力算定手法\analysis_error.m')
clearvars -except ME EDC_reserved_plus EDC_reserved_minus LFC_reserved_up LFC_reserved_down
p=pwd;
%% 必要データの作成，読み込み(任意)
ass_data
%%%%%%%%%%%%% 比較手法 %%%%%%%%%%%%%
% EDC_reserved=PVF_30min'*5/100;
% LFC_reserved=demand_30min'*2/100;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% -- 空行列作成 --
UC_planning = []; % 最適解保存行列
Balancing_EDC_LFC = [];
on_time=zeros(1,11);
off_time=zeros(1,11);
cost_t = [];PV_CUR=[];L_C_t=[];Reserved_power=[];time0=0;
%%%%% 最適化開始 %%%%%
time=0;a=[];edc_out.edc_out=zeros(1,50);
kk=0;aaa=1;
on_time_pre=zeros(1,11);
off_time_pre=zeros(1,11);
time=time+1;
ass_data
%%%%% 組み合わせ作成 %%%%%
make_kumiawase
on_time_pre=on_time;
off_time_pre=off_time;
%%%%%%% 起動停止維持時間制約を満たすか? %%%%%%%
check_onoff_time

%%%%% 最適化開始 %%%%%
hantei = 1;mm=0;
ok_scenario

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
I=[];beq=1000;
i = size(G_ox,1);
% -- 最適化データの作成 --
make_opt_data

%%%%%%%%%%% 各時刻断面独立で実施 %%%%%%%%%%%
load('make_opt_data.mat')

lb=max(lb')';                                       % 下限制約:最大下限を取る
lb(find(lb<Rate_Min(1:11,2)))=...
(Rate_Min(find(lb<Rate_Min(1:11,2)),2)).*...
Aeq(find(lb<Rate_Min(1:11,2)))';
ub=min(ub')';                                       % 上限制約:最小上限を取る
sikiiatai=sum(b(14:end).*Aeq');

beq=1000;
lb_sum=sum(lb.*Aeq');
pv_surplus_consider

P=[];PV_cur=[];Fval=[];

for pv_cur=0:-1:-1000
    ub(end)=pv_cur;
    b(end)=pv_cur;
    [p,fval,exitflag] = fmincon(fun,x0,A,b,Aeq,beq,lb,ub);

    P=[P;p(1:11)];
    PV_cur=[PV_cur,p(12)];
    Fval=[Fval;fval];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure,plot(-PV_cur,Fval)