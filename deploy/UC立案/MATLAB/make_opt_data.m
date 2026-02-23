rate_min
%% 目的関数
BC_t=EDC_reserved_plus(time)+LFC_reserved_up(time);
ND_t=-demand_30min(time)+PVF_30min(time);
fun = @(p)((a_k(1)/p(1)*p(1)+b_k(1)*p(1)+c_k(1)*p(1)^2)+(a_k(2)/p(2)*p(2)+b_k(2)*p(2)+c_k(2)*p(2)^2)+...
    (a_k(3)/p(3)*p(3)+b_k(3)*p(3)+c_k(3)*p(3)^2)+(a_k(4)/p(4)*p(4)+b_k(4)*p(4)+c_k(4)*p(4)^2)+...
    (a_k(5)/p(5)*p(5)+b_k(5)*p(5)+c_k(5)*p(5)^2)+(a_k(6)/p(6)*p(6)+b_k(6)*p(6)+c_k(6)*p(6)^2)+...
    (a_k(7)/p(7)*p(7)+b_k(7)*p(7)+c_k(7)*p(7)^2)+(a_k(8)/p(8)*p(8)+b_k(8)*p(8)+c_k(8)*p(8)^2)+...
    (a_k(9)/p(9)*p(9)+b_k(9)*p(9)+c_k(9)*p(9)^2)+(a_k(10)/p(10)*p(10)+b_k(10)*p(10)+c_k(10)*p(10)^2)+...
    (a_k(11)/p(11)*p(11)+b_k(11)*p(11)+c_k(11)*p(11)^2));
% -- 初期点 --
x0 = zeros(1,11);
output_speed=[3;3;12.5;3;5;5;15;28;10;28;20]*30;
%% 制約条件
Const_Out = [0,0,0,0,0,0,0];
% -- 需給バランス制約 --
    Aeq=G_ox(i,:); % 石油4機，石炭6機，LNG1機
    beq = demand_30min(time)-PVF_30min(time)-sum(Const_Out);

% -- EDC調整力抑制制約 --
    LFC_capacity_t=round(LFC_reserved_up(time),1);
    EDC_capacity_t=round(EDC_reserved_plus(time),1);
    % pos_supply=PVF_30min(time)+sum(Rate_Min(1:11,1).*Aeq');
    % pos_demand=demand_30min(time)+LFC_capacity_t+EDC_capacity_t;
    % reserve_del=pos_demand-pos_supply;
    % EDC_capacity_t=EDC_capacity_t-reserve_del.*(reserve_del>=0);

% -- 二次調整力確保制約 --
   % -- 各時刻の所要二次調整力の算出 (n:要素番号)--
   make_constrain_LFC
   b_lfc=vertcat(b_l0,b_l1,b_l2,b_l3,b_l4,b_l5,b_l6);

   % z=0;EDC_out_gen=100;EDC_muri=0;
   % while isempty(EDC_out_gen)==0
       % if z == 0
           % z=z+1;
           make_constrain_EDC
       % else
       %     make_constrain_nokori_EDC
       % end
       
       % A=vertcat(A_l0,A_l1,A_l2,A_l3,A_l4,A_l5,A_l6,...
       %     A_e0,A_e1,A_e2,A_e3,A_e4,A_e5,...
       %     A_e6,A_e7,A_e8,A_e9,A_e10,A_e11);
       % b=vertcat(b_l0,b_l1,b_l2,b_l3,b_l4,b_l5,b_l6,...
       %     b_e0,b_e1,b_e2,b_e3,b_e4,b_e5,...
       %     b_e6,b_e7,b_e8,b_e9,b_e10,b_e11);
       % EDC_out_gen=find((b(14:end)<Rate_Min(1:11,2)));
       
       % if isempty(EDC_gen) == 1
           % EDC_muri=1;
           % b(EDC_out_gen+13)=Rate_Min(EDC_out_gen,2);
           % break
       % end
   % end
   
%     % [系統での所要二次②(n=1),各LFC機の所要二次①容量]
%     EDC_capacity_t=EDC_reserved(time);
%     if EDC_capacity_t ~= 0
%         EDC_capacity=[EDC_capacity_t;
%             EDC_capacity_t*cost_kWh/sum(cost_kWh)]; % kWh費比率に応じて分配
%         % -- 各発電機の二次②用定格出力，(非LFC機:0,LFC機:定格出力)
%         EDC_rated = [Rate_Min(1:6,1);b_l2;b_l3;b_l4;b_l5;b_l6];
%         EDC_rated = [sum(EDC_rated);EDC_rated]; % 全LFC機の合計定格出力を追加
% 
%         % -- 系統での二次②確保制約 --
%         A_e0 = ones(1,11);
%         b_e0 = -(EDC_capacity(1)-EDC_rated(1));
%         % -- EDC機の二次②確保制約 --
%         A_e1=[1,zeros(1,10)];
%         b_e1=-(EDC_capacity(2)-EDC_rated(2));
%         A_e2=[zeros(1,1),1,zeros(1,9)];
%         b_e2=-(EDC_capacity(3)-EDC_rated(3));
%         A_e3=[zeros(1,2),1,zeros(1,8)];
%         b_e3=-(EDC_capacity(4)-EDC_rated(4));
%         A_e4=[zeros(1,3),1,zeros(1,7)];
%         b_e4=-(EDC_capacity(5)-EDC_rated(5));
%         A_e5=[zeros(1,4),1,zeros(1,6)];
%         b_e5=-(EDC_capacity(6)-EDC_rated(6));
%         A_e6=[zeros(1,5),1,zeros(1,5)];
%         b_e6=-(EDC_capacity(7)-EDC_rated(7));
%         A_e7=[zeros(1,6),1,zeros(1,4)];
%         b_e7=-(EDC_capacity(8)-EDC_rated(8));
%         A_e8=[zeros(1,7),1,zeros(1,3)];
%         b_e8=-(EDC_capacity(9)-EDC_rated(9));
%         A_e9=[zeros(1,8),1,zeros(1,2)];
%         b_e9=-(EDC_capacity(10)-EDC_rated(10));
%         A_e10=[zeros(1,9),1,zeros(1,1)];
%         b_e10=-(EDC_capacity(11)-EDC_rated(11));
%         A_e11=[zeros(1,10),1];
%         b_e11=-(EDC_capacity(12)-EDC_rated(12));
%         A=vertcat(A_e0,A_e1,A_e2,A_e3,A_e4,A_e5,...
%             A_e6,A_e7,A_e8,A_e9,A_e10,A_e11);
%         b=vertcat(b_e0,b_e1,b_e2,b_e3,b_e4,b_e5,...
%             b_e6,b_e7,b_e8,b_e9,b_e10,b_e11);
%         
%         Rate_Min(1:11,1)=[Rate_Min(1:6,1);[b_e7,b_e8,b_e9,b_e10,b_e11]'];
%     else
%         A=vertcat(A_l0,A_l1,A_l2,A_l3,A_l4,A_l5,A_l6);
%         b=vertcat(b_l0,b_l1,b_l2,b_l3,b_l4,b_l5,b_l6);
%     end

% -- 発電機出力上下限制約 --
    ub0 = Rate_Min(1:11,1);
    lb0 = Rate_Min(1:11,2).*Aeq';

% -- 発電機出力変化速度上下限制約 --
    % 時刻断面2以降は前の最適解に依存
    if time == 1
        ub1 = ub0;
        lb1 = lb0;
    else
        ub1 = UC_planning(time-1,:)'+output_speed;
        lb1 = UC_planning(time-1,:)'-output_speed;
    end
    
% -- LFC容量確保制約を満たすべく必要な制約 (初めは，発電機出力上下限制約にする) --
    ub2 = ub0;
    lb2 = zeros(11,1);
% -- 起動維持時間制約を満たすべく必要な制約 (初めは，発電機出力上下限制約にする) --
    ub3 = ub0;
    lb3 = zeros(11,1);
% -- 停止維持時間制約を満たすべく必要な制約 (初めは，発電機出力上下限制約にする) --
    ub4 = ub0;
    lb4 = zeros(11,1);

    ub5=vertcat(b_e1,b_e2,b_e3,b_e4,b_e5,...
        b_e6,b_e7,b_e8,b_e9,b_e10,b_e11);
    
    ub=horzcat(ub0,ub1,ub2,ub3,ub4,ub5);
    lb=horzcat(lb0,lb1,lb2,lb3,lb4);

    lb=max(lb')';                                       % 下限制約:最大下限を取る
    lb(find(lb<Rate_Min(1:11,2)))=...
        (Rate_Min(find(lb<Rate_Min(1:11,2)),2)).*...
        Aeq(find(lb<Rate_Min(1:11,2)))';
    ub=min(ub')';                                       % 上限制約:最小上限を取る



    A=[];b=[];

%% 保存
save make_opt_data.mat fun x0 Aeq beq A b ub lb b_lfc