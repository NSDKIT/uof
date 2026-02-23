LFC_gen=7:11;
nokori_LFC=sum([ub(LFC_out_gen)-Rate_Min(LFC_out_gen,2)]);
for lfc_out_gen = LFC_out_gen'
    LFC_gen(find(LFC_gen==lfc_out_gen))=[];
end
% 再配分量の決定
LFC_capacity_nokori = zeros(11,1);
LFC_capacity_nokori(LFC_gen)=...
    nokori_LFC*cost_rate(LFC_gen)'/sum(cost_rate(LFC_gen)); % コスト比率に応じて分配