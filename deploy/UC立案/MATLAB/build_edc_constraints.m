cost_rate=[];EDC_gen=1:11; % EDC機は全て
cost_k=cost_kWh(EDC_gen,1);
for k= EDC_gen
    d=cost_k;
    d(k)=[];
    cost_rate=[cost_rate,sum(d)/sum(cost_k)];
end

%% 上げ代
% [系統での所要二次①(n=1),各EDC機の所要二次①容量]
EDC_gen=EDC_gen.*(Aeq(EDC_gen)==1);
EDC_gen(EDC_gen==0)=[];
% LFC_capacity_t=demand_30min(time)*lfc;
EDC_capacity = [EDC_capacity_t;zeros(11,1)];
EDC_capacity(EDC_gen+1)=EDC_capacity_t*cost_rate(EDC_gen)'/sum(cost_rate(EDC_gen)); % コスト比率に応じて分配

% -- 各発電機の二次①用定格出力，(非EDC機:0,EDC機:定格出力)
EDC_rated = [Rate_Min(1:6,1);b_l2;b_l3;b_l4;b_l5;b_l6];
EDC_rated = [sum(EDC_rated.*Aeq');EDC_rated]; % 全EDC機の合計定格出力を追加

remain_edc=EDC_rated(2:end)-Rate_Min(1:11,2)-EDC_capacity(2:end);
remain_edc=reshape(remain_edc,[11,1]);
edc_outnum=find(remain_edc<0);
edc_haibunn_hantei=1;
while isempty(edc_outnum)==0
    EDC_gen = setdiff(EDC_gen, edc_outnum);
    if isempty(EDC_gen) == 1
        if sum(abs(fix(remain_edc))) == 0
            edc_haibunn_hantei=1;
        else
            edc_haibunn_hantei=0;
        end
        edc_outnum=[];
    else
        EDC_capacity(edc_outnum+1)=EDC_capacity(edc_outnum+1)+remain_edc(edc_outnum); % 提供不可な配分量を除去
        remain_edc=sum(remain_edc(edc_outnum));
        EDC_capacity(EDC_gen+1)=EDC_capacity(EDC_gen+1)+-remain_edc*cost_rate(EDC_gen)'/sum(cost_rate(EDC_gen)); % コスト比率に応じて分配
        remain_edc=EDC_rated(2:end)-Rate_Min(1:11,2)-EDC_capacity(2:end);
        edc_outnum=find(remain_edc<0);
    end
end
% -- 系統での二次②確保制約 --
A_e0 = ones(1,11);
b_e0 = -(EDC_capacity(1)-EDC_rated(1));
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