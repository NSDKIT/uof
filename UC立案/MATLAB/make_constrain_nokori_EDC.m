nokori_EDC=sum([Rate_Min(EDC_out_gen,2)-b(EDC_out_gen+13)]);
% [系統での所要二次①(n=1),各EDC機の所要二次①容量]
for edc_out_gen = EDC_out_gen'
    EDC_gen(find(EDC_gen==edc_out_gen))=[];
end
b(EDC_out_gen+13)=Rate_Min(EDC_out_gen,2);
% LFC_capacity_t=demand_30min(time)*lfc;
EDC_capacity = [EDC_capacity_t;zeros(11,1)];
EDC_capacity(EDC_gen+1)=nokori_EDC*cost_rate(EDC_gen)'/sum(cost_rate(EDC_gen)); % コスト比率に応じて分配

% -- 各発電機の二次①用定格出力，(非EDC機:0,EDC機:定格出力)
EDC_rated = [sum(EDC_rated);b(14:end)]; % 全EDC機の合計定格出力を追加

% -- 系統での二次②確保制約 --
A_e0 = ones(1,11);
b_e0 = b_e0;
% -- EDC機の二次②確保制約 --
A_e1=[1,zeros(1,10)];
b_e1=-(EDC_capacity(2)-EDC_rated(2));
A_e2=[zeros(1,1),1,zeros(1,9)];
b_e2=-(EDC_capacity(3)-EDC_rated(3));
A_e3=[zeros(1,2),1,zeros(1,8)];
b_e3=-(EDC_capacity(4)-EDC_rated(4));
A_e4=[zeros(1,3),1,zeros(1,7)];
b_e4=-(EDC_capacity(5)-EDC_rated(5));
A_e5=[zeros(1,4),1,zeros(1,6)];
b_e5=-(EDC_capacity(6)-EDC_rated(6));
A_e6=[zeros(1,5),1,zeros(1,5)];
b_e6=-(EDC_capacity(7)-EDC_rated(7));
A_e7=[zeros(1,6),1,zeros(1,4)];
b_e7=-(EDC_capacity(8)-EDC_rated(8));
A_e8=[zeros(1,7),1,zeros(1,3)];
b_e8=-(EDC_capacity(9)-EDC_rated(9));
A_e9=[zeros(1,8),1,zeros(1,2)];
b_e9=-(EDC_capacity(10)-EDC_rated(10));
A_e10=[zeros(1,9),1,zeros(1,1)];
b_e10=-(EDC_capacity(11)-EDC_rated(11));
A_e11=[zeros(1,10),1];
b_e11=-(EDC_capacity(12)-EDC_rated(12));