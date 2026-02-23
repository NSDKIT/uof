%%%%%% 下げ代 %%%%%%
%% LFC
% [系統での所要二次①(n=1),各LFC機の所要二次①容量]
LFC_capacity_t_down=LFC_reserved_down(time);
Not_LFC_gen=[];
LFC_gen=7:11;
LFC_gen=LFC_gen.*(Aeq(LFC_gen)==1);
LFC_gen(LFC_gen==0)=[];
Rate_Min(LFC_gen,2)=Rate_Min(LFC_gen,2)+LFC_capacity_t_down*output_speed(LFC_gen,1)/sum(output_speed(LFC_gen,1)); % 出力変化速度比率に応じて分配
%% EDC
cost_rate=[];EDC_gen=1:11; % EDC機は全て
cost_k=cost_kWh(EDC_gen,1);
for k= EDC_gen
    d=cost_k;
    d(k)=[];
    cost_rate=[cost_rate,sum(d)/sum(cost_k)];
end

% [系統での所要二次①(n=1),各EDC機の所要二次①容量]
EDC_capacity_t_down=EDC_reserved_minus(time);
EDC_gen=EDC_gen.*(Aeq(EDC_gen)==1);
EDC_gen(EDC_gen==0)=[];
Rate_Min(EDC_gen,2)=Rate_Min(EDC_gen,2)+EDC_capacity_t_down*cost_rate(EDC_gen)'/sum(cost_rate(EDC_gen)); % コスト比率に応じて分配