% [系統での所要二次①(n=1),各LFC機の所要二次①容量]
Not_LFC_gen=[];
LFC_gen=7:11;
LFC_gen=LFC_gen.*(Aeq(LFC_gen)==1);
LFC_gen(LFC_gen==0)=[];
% LFC_capacity_t=demand_30min(time)*lfc;
LFC_capacity = [LFC_capacity_t;zeros(11,1)];
LFC_capacity(LFC_gen+1)=LFC_capacity_t*output_speed(LFC_gen,1)/sum(output_speed(LFC_gen,1)); % 出力変化速度比率に応じて分配

remain_lfc=Rate_Min(1:11,1)-Rate_Min(1:11,2)-LFC_capacity(2:end);
remain_lfc=reshape(remain_lfc,[11,1]);
lfc_outnum=find(remain_lfc<0);
lfc_haibunn_hantei=1;
while isempty(lfc_outnum)==0
    LFC_gen = setdiff(LFC_gen, lfc_outnum);
    if isempty(LFC_gen) == 1
        if sum(abs(fix(remain_lfc))) == 0
            lfc_haibunn_hantei=1;
        else
            lfc_haibunn_hantei=0;
        end
        lfc_outnum=[];
    else
        LFC_capacity(lfc_outnum+1)=LFC_capacity(lfc_outnum+1)+remain_lfc(lfc_outnum); % 提供不可な配分量を除去
        remain_lfc=sum(remain_lfc(lfc_outnum));
        LFC_capacity(LFC_gen+1)=LFC_capacity(LFC_gen+1)+-remain_lfc*output_speed(LFC_gen,1)/sum(output_speed(LFC_gen,1)); % 出力変化速度比率に応じて分配
        remain_lfc=Rate_Min(1:11,1)-Rate_Min(1:11,2)-LFC_capacity(2:end);
        lfc_outnum=find(remain_lfc<0);
    end
end
% -- 各発電機の二次①用定格出力，(非LFC機:0,LFC機:定格出力)
LFC_rated = Rate_Min(1:11,1).*[zeros(6,1);ones(5,1)];
LFC_rated = [sum(LFC_rated.*Aeq');LFC_rated]; % 全LFC機の合計定格出力を追加

% -- 系統での二次①確保制約 --
A_l0 = [zeros(1,6),ones(1,5)];
b_l0 = -(LFC_capacity(1)-LFC_rated(1));
% -- 非LFC機の二次①確保制約 --
A_l1 = zeros(6,11);
b_l1 = -LFC_capacity(2:7);
b_l1=Rate_Min(1:6,1);
% -- LFC機の二次①確保制約 --
A_l2 = [zeros(1,6),1,zeros(1,4)];       % 石炭3号機
b_l2 = -(LFC_capacity(8)-LFC_rated(8));
A_l3 = [zeros(1,7),1,zeros(1,3)];       % 石炭4号機
b_l3 = -(LFC_capacity(9)-LFC_rated(9));
A_l4 = [zeros(1,8),1,zeros(1,2)];       % 石炭5号機
b_l4 = -(LFC_capacity(10)-LFC_rated(10));
A_l5 = [zeros(1,9),1,zeros(1,1)];       % 石炭6号機
b_l5 = -(LFC_capacity(11)-LFC_rated(11));
A_l6 = [zeros(1,10),1];                 % LNG機
b_l6 = -(LFC_capacity(12)-LFC_rated(12));