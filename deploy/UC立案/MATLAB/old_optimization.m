% -- ワークスペース，Figureをクリアに --
% close all
run('二次調整力算定手法\analysis_error.m')
clearvars -except EDC_reserved LFC_reserved
p=pwd;
%% 必要データの作成，読み込み(任意)
ass_data
% -- 空行列作成 --
UC_planning = []; % 最適解保存行列
on_time=zeros(1,11);
off_time=zeros(1,11);
cost_t = [];L_C_t=[];Reserved_power=[];
%% -- 最適化開始 --
for time = 1:hour
    % -- 時刻間での引き続きに必要なデータ以外は除去(開始時と同じ状態にする) --
    clearvars -except Reserved_power p time UC_planning on_time off_time cost_t lfc a_k b_k c_k gen_on gen_off demand_30min PVF_30min Rate_Min EDC_reserved LFC_reserved L_C_t cost_kWh
        
    % -- 最適化データの作成 --
    make_opt_data
    
    % -- Step1, 各時刻断面独立で実施 --
    load('make_opt_data.mat')
    lb=max(lb')'; % 下限制約:最大下限を取る
    ub=min(ub')'; % 上限制約:最小上限を取る
    [p,fval] = fmincon(fun,x0,A,b,Aeq,beq,lb,ub);
    p = p.*(p>1); % 最適解が微小に出ることがあるため，そこは零と考える
    
    if time == 25
        1;
    end
    
    
    % -- 起動停止維持時間制約を満たすかどうかの確認 --
    check_onoff_time
    
    if sum(hantei_on_time)~=11 || sum(hantei_off_time)~=11
        if sum(hantei_on_time)~=11 % 起動維持時間制約違反
            lb=Rate_Min(1:11,2).*(hantei_on_time==0)'; % 制約を満たすために，最小出力を更新
        end
        if sum(hantei_off_time)~=11 % 停止維持時間制約違反
%             o0=(off_time~=0)==0;
            ub=ub.*(hantei_off_time==1)'+ub./10^5.*(hantei_off_time==0)'; % 停止制約の発電機上限を10^5で割る。零にするとfminconできない
            lb=lb.*(hantei_off_time==1)'+lb./10^5.*(hantei_off_time==0)'; % 停止制約の発電機下限を10^5で割る。零にするとfminconできない
        end
        [p,fval] = fmincon(fun,x0,A,b,Aeq,beq,lb,ub); % 下限制約:最大下限を取る, 上限制約:最小上限を取る
        p = p.*(p>1); % 最適解が微小に出ることがあるため，そこは零と考える
    end
    
    if sum(p) ~= 0 % ※残余需要が負になり，pが全て0になる場合は127行の処理を実施
        % 2回目，前断面との引き継ぎ        
        check_constraint
        
        % -- 判定係数 -- 全てを満たしているなら1になる
        hantei=(sum(hantei_min)==11)*...
            (lfc_surplus>=0)*(edc_surplus>=0);
        n=0;
        error=0;
        while hantei == 0
            save data_set.mat fun x0 A b Aeq beq lb ub p
            n=n+1;            
            o0=(off_time~=0)==0; % 前時刻断面での起動状態の確認
            if sum(hantei_min)~=11 % 発電機出力下限制約を満たすかどうか
%                 if n == 1
%                     lb(:,1) = Rate_Min(1:11,2).*(hantei_min==0)';
%                 else
                    gen_rank=[8,10,7,9,5,6,11,3,2,1,4]; % 発電機燃料費ランキング（左から燃料費が安い発電機番号）
                    num=(hantei_min~=0);
                    num=num.*(1:11);
                    num(find(num==0))=[];
                    for k = num
                        gen_rank(find(gen_rank==k))=[];
                    end
                    lb(gen_rank(1)) = Rate_Min(gen_rank(1),2);% 停止制約を満足した停止LFC発電機の最小出力を「零から最小出力」へ変更end                
%                 end
            end
            
            ox=(o0+(off_time>=gen_off))'; % 停止制約を満足した停止LFC発電機
            if lfc_surplus < 0 % LFC容量確保制約違反
                if p(find(hantei_min(LFC_gen)==0)+6) ~= 0
                    % LFC対象機を新たに起動する必要がある場合は，不足分を起動
                    lb = max(lb,[[zeros(6,1);...
                        (hantei_min1(LFC_gen)==0)'.*Rate_Min(LFC_gen,2)].*(ox)]); % 停止制約を満足した停止LFC発電機の最小出力を「零から最小出力」へ変更
                else
                    % LFC対象機を新たに起動する必要がない場合は，不足分を配分
                    X=zeros(11,1);
                    X=Rate_Min(1:11,1);
                    X(find(hantei_min1(LFC_gen)==1)+6) = ...
                        (b(find(hantei_min1(LFC_gen)==1)+6+1)+lfc_surplus/(5-length(find(hantei_min1(LFC_gen)==0)))).*ox((find(hantei_min1(LFC_gen)==1)+6)); % 停止制約を満足した停止LFC発電機にLFC容量を再配分
                    negative = find(X<0);
                    X(negative) = zeros(size(negative));
                    a=find(X<=Rate_Min(1:11,2));
                    X(a)=Rate_Min(a,2);
                    b(2:12) = X;
                end
            end
            
            if edc_surplus < 0 % LFC容量確保制約違反
                if n == 1
                    % 不足分を配分
                    num=((hantei_off_time==1).*(p~=0)==1).*(1:11);
                    num(find(num==0))=[];
                    X=Rate_Min(1:11,1);
    %                 X=zeros(11,1);
                    X([num]) = ...
                        b([num]+13)+edc_surplus/(length([num])); % 停止制約を満足した停止LFC発電機にLFC容量を再配分
                    negative = find(X<0);
                    X(negative) = zeros(size(negative));
                    b(14:end) = X.*(X>Rate_Min(1:11,2))+Rate_Min(1:11,2).*(X<=Rate_Min(1:11,2));
                else
                    gen_rank=[8,10,7,9,5,6,11,3,2,1,4]; % 発電機燃料費ランキング（左から燃料費が安い発電機番号）
%                     num=((hantei_off_time==1).*(p~=0)==1).*(1:11);
                    num=((hantei_off_time==0)+(p~=0));
                    num=num.*(1:11);
                    num(find(num==0))=[];
                    for k = num
                        gen_rank(find(gen_rank==k))=[];
                    end
                    if isempty(gen_rank) == 1
%                         z
%                         num=((hantei_off_time==1).*(p~=0)==1).*(1:11);
                        num=[hantei_off_time'.*hantei_on_time'+(hantei_on_time'==0)].*(1:11)';
                        num(find(num==0))=[];
                        X=Rate_Min(1:11,1);
        %                 X=zeros(11,1);
                        X([num]) = ...
                            b([num]+13)+edc_surplus/(length([num])); % 停止制約を満足した停止LFC発電機にLFC容量を再配分
                        negative = find(X<0);
                        X(negative) = zeros(size(negative));
                        b(14:end) = X.*(X>Rate_Min(1:11,2))+Rate_Min(1:11,2).*(X<=Rate_Min(1:11,2));                        
                    else
                        % 不足分を起動
                        lb(gen_rank(1)) = Rate_Min(gen_rank(1),2);% 停止制約を満足した停止LFC発電機の最小出力を「零から最小出力」へ変更end
                    end
                end
            end
            
%             gen_rank=[8,10,7,9,5,6,11,3,2,1,4]; % 発電機燃料費ランキング（左から燃料費が安い発電機番号）
%             if rem(n,5) == 0 % 何回回してもループするだけの状況に陥った時の対策
%                 ox=(o0*1+(off_time>=gen_off))';
%                 lb(gen_rank(1:n/5),1)=Rate_Min(gen_rank(1:n/5),2).*ox(gen_rank(1:n/5)); % 燃料費が安い順に停止制約を満たした発電機を起動させる
%             end
            
            [p,fval,exitflag] = fmincon(fun,x0,A,b,Aeq,beq,lb,ub);
            p = p.*(p>1);
            
            if exitflag == 1 || exitflag == 2
                check_constraint

                % -- 判定係数 -- 全てを満たしているなら1になる
                hantei=(sum(hantei_min)==11)*...
                    (lfc_surplus>=0)*(edc_surplus>=0);
%                 load('data_set.mat')
                error=1;
            else
                EDC_ox=(lb>=b(14:end));
                if sum(lb) > beq
                    error=2;
                    break
                elseif beq>sum(b(14:end).*[hantei_off_time'.*hantei_on_time'+(hantei_on_time'==0)])
                    error=3;
                    break
                elseif sum(EDC_ox)~=0
                    b(14:end)=b(14:end).*(lb<b(14:end))+lb.*(lb>=b(14:end));
                elseif sum(ub>=b(14:end)) ~= 11
                    B=b(14:end);
                    B(find((ub>=b(14:end))==0))=ub(find((ub>=b(14:end))==0));
                    b(14:end)=B;
                else
                    load('data_set.mat')
                    hantei = 0;
                end
            end
        end
    else
        % PV > load では発電機起動停止状態は変えずに，前断面の稼働発電機を最小出力で起動させる
        ox=UC_planning(time-1,:)~=0;
        p=(Rate_Min(1:11,2).*ox')';
    end
    UC_planning = [UC_planning;p];
    p_k=p./p;
    p_k(isnan(p_k))=0;
    check_constraint
    L_C_t=[L_C_t;b(2:12)'];
    Reserved_power=[Reserved_power;[EDC_capacity_t,EDC_opt,LFC_capacity_t,LFC_opt,error]];
%     cost_t = [cost_t;fval,sum(a_k(1:11).*p_k'+b_k(1:11).*p'+c_k(1:11).*p'.^2)];
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