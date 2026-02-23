X=Rate_Min(1:11,1);
X(find(hantei_min1(LFC_gen)==1)+6) = ...
    (b(find(hantei_min1(LFC_gen)==1)+6+1)+...
    lfc_surplus/(5-length(find(hantei_min1(LFC_gen)==0))))...
    .*ox((find(hantei_min1(LFC_gen)==1)+6))'; % 停止制約を満足した停止LFC発電機にLFC容量を再配分
negative = find(X<0);
X(negative) = zeros(size(negative));

a=find(X<=Rate_Min(1:11,2));
X(a)=Rate_Min(a,2);
b(2:12) = X;

[p,fval,exitflag] = fmincon(fun,x0,A,b,Aeq,beq,lb,ub);
p = p.*(p>1);