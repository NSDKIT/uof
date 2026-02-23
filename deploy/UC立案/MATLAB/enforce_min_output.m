gen_rank=[8,10,7,9,5,6,11,3,2,1,4]; % 発電機燃料費ランキング
num=hantei_min.*(1:11);             % 制約を満たす発電機番号取得
num(find(num==0))=[];
for k = num
    gen_rank(find(gen_rank==k))=[]; % 制約を満たさない発電機番号をランキング順に取得
end
lb(gen_rank(1)) = max(lb(gen_rank(1)),... % ランキング1位の発電機の下限を最小出力へ
    Rate_Min(gen_rank(1),2));

[p,fval] = fmincon(fun,x0,A,b,Aeq,beq,lb,ub);
p = p.*(p>1);                                   % 最適解が微小に出ることがあるため，そこは零と考える
check_output_constraints
if sum(lb) > beq
    lb(gen_rank(1))=lb(gen_rank(1))/10^5;
    ub(gen_rank(1))=ub(gen_rank(1))/10^5;
    [p,fval] = fmincon(fun,x0,A,b,Aeq,beq,lb,ub);
    p = p.*(p>1);                                   % 最適解が微小に出ることがあるため，そこは零と考える
    check_output_constraints
end