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
% -- 二次調整力確保制約 --
% -- 各時刻の所要二次調整力の算出 (n:要素番号)--
build_lfc_constraints
b_lfc=vertcat(b_l0,b_l1,b_l2,b_l3,b_l4,b_l5,b_l6);

build_edc_constraints
% -- 発電機出力上下限制約 --
ub0 = Rate_Min(1:11,1);
lb0 = Rate_Min(1:11,2).*Aeq';

% -- 発電機出力変化速度上下限制約 --
ub1 = ub0;
lb1 = lb0;

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