make_kumiawase

margin=-diff(Rate_Min')';
margin=margin(1:11);
margin_gen=G_ox.*margin';

demand_time=demand_30min+RES;
supply_time=PVF_30min+sum(margin);

most_dangerous_time=supply_time-demand_time;
most_dangerous_time=find(most_dangerous_time==min(most_dangerous_time));

dengerous_LFC=LFC_reserved_up(most_dangerous_time);
margin_LFC_ava=sum(margin_gen(:,7:11)')';
margin_LFC_ox=margin_LFC_ava>=dengerous_LFC;

dengerous_EDC=EDC_reserved_plus(most_dangerous_time);
margin_EDC_ava=sum(margin_gen')'-dengerous_LFC; % 系統全体でLFC容量が配分されたと仮定
margin_EDC_ox=margin_EDC_ava>=dengerous_EDC;

margin_ox=margin_LFC_ox.*margin_EDC_ox;
G_ox(find(margin_ox==0),:)=[];

time=most_dangerous_time;
ass_data
execute_UC_denger

out_num=find((Flag==1)+(Flag==2)~=1);

        P(out_num,:)=[];
        PV_cur(out_num)=[];
        Fval(out_num)=[];
        Flag(out_num)=[];

opt_num=min(find(Fval==min(Fval)));

    PV_CUR=PV_cur(opt_num);
    UC_planning = P(opt_num,:);

%% 全時刻の組み合わせ作成
dengerous_LFC=LFC_reserved_up;
margin_LFC_ava=sum(margin_gen(:,7:11)')';
margin_LFC_ox=margin_LFC_ava>=dengerous_LFC;
dengerous_EDC=EDC_reserved_plus;
margin_EDC_ava=sum(margin_gen')'-dengerous_LFC; % 系統全体でLFC容量が配分されたと仮定
margin_EDC_ox=margin_EDC_ava>=dengerous_EDC;

make_kumiawase
G_ox0=G_ox;
for t=time-1:-1:1
    %% 確保不可シナリオ
    margin_ox=margin_LFC_ox.*margin_EDC_ox;
    %% 起動維持時間制約シナリオ
    UC_planning~=0;
    G_ox0(find(margin_ox==0),:)=[];