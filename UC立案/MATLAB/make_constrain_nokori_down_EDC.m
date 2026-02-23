%% EDC
% [系統での所要二次①(n=1),各EDC機の所要二次①容量]
EDC_gen=1:11;
EDC_capacity_t_down=other_reserve_down;
EDC_gen=EDC_gen.*(Aeq(EDC_gen)==1);
EDC_gen(hantei_lb_ub)=0;
EDC_gen(EDC_gen==0)=[];

% LFC_capacity_t=demand_30min(time)*lfc;
lb(EDC_gen,2)=lb(EDC_gen,2)+...
    EDC_capacity_t_down*cost_rate(EDC_gen)'/...
    sum(cost_rate(EDC_gen)); % コスト比率に応じて分配