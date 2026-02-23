% -- ワークスペース，Figureをクリアに --
close all
run('二次調整力算定手法\analysis_error.m')
clearvars -except EDC_reserved LFC_reserved
p=pwd;
%% 必要データの作成，読み込み(任意)
ass_data
%%%%%%%%%%%%% 比較手法 %%%%%%%%%%%%%
% EDC_reserved=PVF_30min'*5/100;
% LFC_reserved=demand_30min'*2/100;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% -- 空行列作成 --
UC_planning = []; % 最適解保存行列
on_time=zeros(1,11);
off_time=zeros(1,11);
cost_t = [];L_C_t=[];Reserved_power=[];time0=0;
%% -- 最適化開始 --
time=0;a=[];edc_out.edc_out=zeros(1,50);
while time < hour
    time=time+1;
    % -- 時刻間での引き続きに必要なデータ以外は除去(開始時と同じ状態にする) --
    clearvars -except time0 edc_out edc_surplus Reserved_power hantei_off_time a p time hour UC_planning on_time off_time cost_t lfc a_k b_k c_k gen_on gen_off demand_30min PVF_30min Rate_Min EDC_reserved LFC_reserved L_C_t cost_kWh
    
    if time == 21
        1;
    end
    % -- 最適化データの作成 --
    make_opt_data
    
    %%%%%%%%%%% 各時刻断面独立で実施 %%%%%%%%%%%
    load('make_opt_data.mat')
    lb=max(lb')';                                       % 下限制約:最大下限を取る
    ub=min(ub')';                                       % 上限制約:最小上限を取る
    RANK=0;
    if isempty(a) == 0
        gen_rank=[8,10,7,9,5,6,11,3,2,1,4];             % 発電機燃料費ランキング
        num=hantei_off_time.*(1:11);                    % 制約を満たす発電機番号取得
        num(a)=0;
        num=find(num==0);
        for k = num
            gen_rank(find(gen_rank==k))=[]; % 制約を満たさない発電機番号をランキング順に取得
        end
        if isempty(gen_rank) == 0
            lb([num,gen_rank(1)])=Rate_Min([num,gen_rank(1)],2);
            edc_out.edc_out(time)=edc_out.edc_out(time)+1;
            if edc_out.edc_out(time) >= 100
                while edc_surplus < 0
                    RANK=RANK+1;
                    % 追加供給可能量
                    edc_add_ok=b(gen_rank(RANK)+12+1)-Rate_Min(gen_rank(RANK),2);
                    if edc_add_ok>=-edc_surplus
                        b(gen_rank(RANK)+12+1)=b(gen_rank(RANK)+12+1)+edc_surplus;
                        edc_surplus=edc_surplus+edc_add_ok;
                    else
                        b(gen_rank(RANK)+12+1)=Rate_Min(gen_rank(RANK),2);
                        edc_surplus=edc_surplus+edc_add_ok;
                    end
                end
            end
        end
    end
    [p,fval] = fmincon(fun,x0,A,b,Aeq,beq,lb,ub);
    p = p.*(p>1);                                       % 最適解が微小に出ることがあるため，そこは零と考える   
    
    %%%%%%% 起動停止維持時間制約を満たすか? %%%%%%%
    check_onoff_time
    
    if sum(hantei_on_time)~=11 || sum(hantei_off_time)~=11
        %%%%%%%%%%% 起動維持時間制約違反 %%%%%%%%%%%
        if sum(hantei_on_time)~=11
            lb=max(lb,Rate_Min(1:11,2).*(hantei_on_time==0)');  % 違反発電機は，最小出力を更新
        end
        %%%%%%%%%%% 停止維持時間制約違反 %%%%%%%%%%%
        if sum(hantei_off_time)~=11
            ub=ub.*(hantei_off_time==1)'+...
                ub./10^5.*(hantei_off_time==0)';        % 違反発電機の上限を10^5で割る。零にするとfminconできない
            lb=lb.*(hantei_off_time==1)'+...
                lb./10^5.*(hantei_off_time==0)';        % 違反発電機の下限を10^5で割る。零にするとfminconできない
        end
        [p,fval] = fmincon(fun,x0,A,b,Aeq,beq,lb,ub);
        p = p.*(p>1);                                   % 最適解が微小に出ることがあるため，そこは零と考える
    end
    
    %%%%%%% 残余需要が負になり，pが全て0になる場合は127行の処理を実施 %%%%%%%
    n=0;a=[];
    
    if beq<min(Rate_Min(find((hantei_off_time)),2))
        ox=UC_planning(time-1,:)~=0;
        gen_rank=[8,10,7,9,5,6,11,3,2,1,4];             % 発電機燃料費ランキング
        num=find(ox==0);                    % 制約を満たす発電機番号取得
        for k = num
            gen_rank(find(gen_rank==k))=[]; % 制約を満たさない発電機番号をランキング順に取得
        end
        p=zeros(1,11);
        p(min(find(Rate_Min(:,2)==min(Rate_Min(gen_rank,2)))))=min(Rate_Min(gen_rank,2));
        error=98;
    elseif beq < sum(p)-1
        if sum(hantei_on_time) == 11
        else
            p=zeros(1,11);
            p(find(hantei_on_time==0))=Rate_Min(find(hantei_on_time==0),2);
        end
        if beq<sum(p)
            gen_rank=[8,10,7,9,5,6,11,3,2,1,4];             % 発電機燃料費ランキング
            ox=p~=0;
            num=find(ox==0);                    % 制約を満たす発電機番号取得
            for k = num
                gen_rank(find(gen_rank==k))=[]; % 制約を満たさない発電機番号をランキング順に取得
            end
            ok_gen=(beq>=Rate_Min(gen_rank,2)).*gen_rank'; % 最小出力を満たし，ランクが高い発電機を稼働
            ok_gen(find(ok_gen==0))=[];
            if isempty(ok_gen) == 0
                nokori=beq-sum(p);
                nokori=nokori*(nokori>0);
                p(ok_gen(1))=p(ok_gen(1))+nokori;
            end
        end
        error=97;
    elseif sum(p) ~= 0 
        hantei = 0;hanpuku_kaihi=0;
        while hantei == 0
            if hanpuku_kaihi<=100 ||...
                    (sum(b(14:end).*[hantei_off_time'.*hantei_on_time'+(hantei_on_time'==0)])<beq) == 0
                check_constraint
                error=0;                                        % 違反番号

                save data_set.mat fun x0 A b Aeq beq lb ub p
            %%%%%%% 最小出力制約 %%%%%%%
                hantei = 1;
                while sum(hantei_min)~=11
                    check_min_output
                end

            %%%%%%% LFC調整力制約 %%%%%%%
                ox=hantei_off_time; % 停止制約を満足した停止LFC発電機
                hantei = 1;hanpuku_kaihi=0;
                while lfc_surplus < 0
                    hanpuku_kaihi=hanpuku_kaihi+1;
                    check_lfc_secured

                    check_constraint

                    while sum(hantei_min)~=11
                        check_min_output
                    end

                    check_constraint
                    hantei = (sum(hantei_min)==11)*(lfc_surplus >= 0);

                    if hanpuku_kaihi >= 101
                        break
                    end
                end

                hantei = 1;hanpuku_kaihi=0;kk=0;
                p_EDC=[];
                while edc_surplus < 0 % LFC容量確保制約違反
                    hanpuku_kaihi=hanpuku_kaihi+1;
                    
                    while sum(hantei_min)~=11
                        check_min_output
                    end
                    
                    a0=find(hantei_min1(EDC_gen)==1);
                    b(a0+13)=p(a0)';
                    
                    if kk==0
                    elseif sum(a0==gen_rank(kk)) == 0
                        a0=[a0,gen_rank(kk)];
                    end
                    X=Rate_Min(1:11,1);
                    X(a0) = (b(a0+12+1)+...
                        edc_surplus/length(a0))...
                        .*ox(a0)'; % 停止制約を満足した停止LFC発電機にLFC容量を再配分
                    negative = find(X<0);
                    X(negative) = zeros(size(negative));
                    a=find(X<=Rate_Min(1:11,2));
%                     if isempty(a) == 0
%                         on=p>=Rate_Min(1:11,2)';
%                         a=find(on);
%                         break
%                     end
                    X(a)=Rate_Min(a,2);
                    b(14:end) = X;

                    [p,fval,exitflag] = fmincon(fun,x0,A,b,Aeq,beq,lb,ub);
                    p = p.*(p>1);
                    
                    check_constraint
                    hantei = (sum(hantei_min)==11)*(lfc_surplus >= 0)*(edc_surplus >= 0);
                    
                    if rem(hanpuku_kaihi,100)==0
                        kk=kk+1;
                        gen_rank=[8,10,7,9,5,6,11,3,2,1,4]; % 発電機燃料費ランキング
                        num=(hantei_off_time==0).*(1:11);             % 制約を満たす発電機番号取得
%                         num=(hantei_on_time.*hantei_off_time.*hantei_min1).*(1:11);             % 制約を満たす発電機番号取得
                        num(find(num==0))=[];
                        for k = num
                            gen_rank(find(gen_rank==k))=[]; % 制約を満たさない発電機番号をランキング順に取得
                        end
                        if kk > length(gen_rank)
                            kk=length(gen_rank);
                        end
                        lb(gen_rank(kk)) = max(lb(gen_rank(kk)),... % ランキング1位の発電機の下限を最小出力へ
                            Rate_Min(gen_rank(kk),2));
                        ub(gen_rank(kk)) = min(UC_planning(end,gen_rank(kk))+...
                            output_speed(gen_rank(kk)),... % ランキング1位の発電機の下限を最小出力へ
                            Rate_Min(gen_rank(kk),1));
                        if hanpuku_kaihi > 1500
                            hantei = (sum(hantei_min)==11)*(lfc_surplus >= 0);
                            break
                        end
                    end
                    
                    p_EDC=[p_EDC;[exitflag,edc_surplus,p]];
                end
            else
                break
            end
        end
        
        [p,fval,exitflag] = fmincon(fun,x0,A,b,Aeq,beq-0.5,lb,ub);
        p = p.*(p>1);
                    
        if exitflag == 1 || exitflag == 2
            error=1;
            a=[];
        else
            EDC_ox=(lb>=b(14:end));
            if sum(lb) > beq
                %%%%% 調整力を確保しようとすると，発電機を起動する必要があり，そうすると，最小出力合計値が残余需要を上回り，需給バランス制約を満たさない
                %%%%% だから，需給バランス制約を満たすように，最適化（EDC調整力は確保できない）
                load('make_opt_data.mat')
                lb=max(lb')';                                       % 下限制約:最大下限を取る
                ub=min(ub')';       
                [p,fval,exitflag] = fmincon(fun,x0,A(1:12,:),b(1:12,:),Aeq,beq,lb,ub);
                p = p.*(p>1);
                check_constraint
                
                while lfc_surplus < 0
                    hanpuku_kaihi=hanpuku_kaihi+1;
                    check_lfc_secured

                    check_constraint

                    while sum(hantei_min)~=11
                        check_min_output
                    end

                    check_constraint
                end
                
                error=2;
                a=[];
            elseif beq>sum(b(14:end).*[hantei_off_time'.*hantei_on_time'+(hantei_on_time'==0)])
                error=3;
                a=[];
            elseif isempty(a) == 0
                p=[];time=time-1;
                continue
            elseif sum(EDC_ox)~=0
                b(14:end)=b(14:end).*(lb<b(14:end))+lb.*(lb>=b(14:end));
                a=[];
            elseif sum(ub>=b(14:end)) ~= 11
                B=b(14:end);
                B(find((ub>=b(14:end))==0))=ub(find((ub>=b(14:end))==0));
                b(14:end)=B;
                a=[];
            else
                load('data_set.mat')
                hantei = 0;
                a=[];
            end
        end
    else
        % PV > load では発電機起動停止状態は変えずに，前断面の稼働発電機を最小出力で起動させる
        ox=UC_planning(time-1,:)~=0;
        p=(Rate_Min(1:11,2).*ox')';
        error=99;
        a=[];
    end
    
    UC_planning = [UC_planning;p];
    if isempty(a) == 1
        p_k=p./p;
        p_k(isnan(p_k))=0;
        check_constraint
        L_C_t=[L_C_t;b(2:12)'];
        Reserved_power=[Reserved_power;[EDC_capacity_t,EDC_opt,LFC_capacity_t,LFC_opt,error]];
        cost_t = [cost_t;fval,sum(a_k(1:11).*p_k'+b_k(1:11).*p'+c_k(1:11).*p'.^2)];
    end
end

%% 需給周波数シミュレーションを実施するための.csv作成
% -- G_up_plan_limit.csv --
G_up=get_G_up_plan_limit('G_up_plan_limit.csv');
l=[zeros(6,1);max(demand_30min)*lfc*LFC_rated(LFC_gen+1)/sum(LFC_rated(LFC_gen+1))];
G_up([8:11,18],2)=(LFC_rated(LFC_gen+1)-l(LFC_gen));
writematrix(G_up,'G_up_plan_limit.csv')

% -- G_up_plan_limit.csv --
L_C=Rate_Min(7:11,1)-max(LFC_reserved)*output_speed(LFC_gen,1)/sum(output_speed(LFC_gen,1)); % 出力変化速度比率に応じて分配
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