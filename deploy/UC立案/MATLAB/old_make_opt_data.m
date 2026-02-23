%% 目的関数
fun = @(p)((a_k(1)/p(1)*p(1)+b_k(1)*p(1)+c_k(1)*p(1)^2)+(a_k(2)/p(2)*p(2)+b_k(2)*p(2)+c_k(2)*p(2)^2)+...
    (a_k(3)/p(3)*p(3)+b_k(3)*p(3)+c_k(3)*p(3)^2)+(a_k(4)/p(4)*p(4)+b_k(4)*p(4)+c_k(4)*p(4)^2)+...
    (a_k(5)/p(5)*p(5)+b_k(5)*p(5)+c_k(5)*p(5)^2)+(a_k(6)/p(6)*p(6)+b_k(6)*p(6)+c_k(6)*p(6)^2)+...
    (a_k(7)/p(7)*p(7)+b_k(7)*p(7)+c_k(7)*p(7)^2)+(a_k(8)/p(8)*p(8)+b_k(8)*p(8)+c_k(8)*p(8)^2)+...
    (a_k(9)/p(9)*p(9)+b_k(9)*p(9)+c_k(9)*p(9)^2)+(a_k(10)/p(10)*p(10)+b_k(10)*p(10)+c_k(10)*p(10)^2)+...
    (a_k(11)/p(11)*p(11)+b_k(11)*p(11)+c_k(11)*p(11)^2));
% -- 初期点 --
x0 = zeros(1,11);
%% 制約条件
% -- 需給バランス制約 --
    Aeq = ones(1,11); % 石油4機，石炭6機，LNG1機
    beq = demand_30min(time)-PVF_30min(time);

% -- LFC容量確保制約 --
   % -- 各時刻の所要LFC容量の算出 (n:要素番号)--
   % [系統での所要LFC容量(n=1),各LFC機の所要LFC容量]
    LFC_gen=7:11; % LFC機は石炭3~6号機, LNG機
    LFC_capacity = [demand_30min(time)*lfc;zeros(6,1);...
        demand_30min(time)*lfc*Rate_Min(LFC_gen,1)/sum(Rate_Min(LFC_gen,1))]; % 各LFC機の所要LFC容量は，定格出力比率に応じて分配
    
    % -- 各発電機のLFC用定格出力，(非LFC機:0,LFC機:定格出力)
    LFC_rated = Rate_Min(1:11,1).*[zeros(6,1);ones(5,1)];
    LFC_rated = [sum(LFC_rated);LFC_rated]; % 全LFC機の合計定格出力を追加
    
    % -- 系統でのLFC容量確保制約 --
    A0 = [zeros(1,6),ones(1,5)];
    b0 = -(LFC_capacity(1)-LFC_rated(1));
    % -- 非LFC機のLFC容量確保制約 --
    A1 = zeros(6,11);
    b1 = -LFC_capacity(2:7);
    % -- LFC機のLFC容量確保制約 --
    A2 = [zeros(1,6),1,zeros(1,4)];       % 石炭3号機
    b2 = -(LFC_capacity(8)-LFC_rated(8));
    A3 = [zeros(1,7),1,zeros(1,3)];       % 石炭4号機
    b3 = -(LFC_capacity(9)-LFC_rated(9));
    A4 = [zeros(1,8),1,zeros(1,2)];       % 石炭5号機
    b4 = -(LFC_capacity(10)-LFC_rated(10));
    A5 = [zeros(1,9),1,zeros(1,1)];       % 石炭6号機
    b5 = -(LFC_capacity(11)-LFC_rated(11));
    A6 = [zeros(1,10),1];                 % LNG機
    b6 = -(LFC_capacity(12)-LFC_rated(12));
    
    A=vertcat(A0,A1,A2,A3,A4,A5,A6);
    b=vertcat(b0,b1,b2,b3,b4,b5,b6);

% -- 発電機出力上下限制約 --
    ub0 = Rate_Min(1:11,1);
    lb0 = zeros(11,1);

% -- 発電機出力変化速度上下限制約 --
    output_speed=[3;3;12.5;3;5;5;15;28;10;28;20]*30;
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
    
    ub=horzcat(ub0,ub1,ub2,ub3);
    lb=horzcat(lb0,lb1,lb2,lb3);

%% 保存
save make_opt_data.mat fun x0 Aeq beq A b ub lb