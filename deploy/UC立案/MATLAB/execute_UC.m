I=[];
for i = 1:size(G_ox,1)
    if i == size(G_ox,1)
        1;
    end
    % -- 最適化データの作成 --
    make_opt_data
    %%%%%%%%%%% 各時刻断面独立で実施 %%%%%%%%%%%
    load('make_opt_data.mat')
    % BC_limit=b(14:end);
    % sikiiatai1=sum(BC_limit(find(Aeq)));
    sikiiatai2=sum(ub(find(Aeq)));
%     sikiiatai=sum(ub.*Aeq');

    % if sikiiatai1>beq && sikiiatai2>beq && lfc_haibunn_hantei==1 && edc_haibunn_hantei==1
    if EDC_capacity_t>=0 && round(sikiiatai2,1)>=round(beq,1) && lfc_haibunn_hantei==1 && edc_haibunn_hantei==1
        lb_sum=sum(lb.*Aeq');
        if lb_sum<=beq
            delta_lb=ones(11,1).*(10^-3);
        elseif lb_sum>beq
            pv_surplus_consider
            delta_lb=[ones(11,1).*(10^-3);0];
        end
        
        [p,fval,exitflag] = fmincon(fun,x0,A,b,Aeq,beq,lb,ub+delta_lb);
        % [p,fval,exitflag] = linprog(2*b_k,A,b,Aeq,beq,lb,ub+delta_lb);
        
        if exitflag == -2
            fval=10^10^10;
        end

        if length(p) == 11
            pv_cur=0;
        elseif length(p) == 12
            pv_cur=p(12);
        end
            
        p = p(1:11).*(p(1:11)>1);
        check_constraint

        P=[P;p(1:11)];
        PV_cur=[PV_cur,pv_cur];
        Fval=[Fval;fval];
        Flag=[Flag;exitflag];
        balancing_EDC_LFC=[balancing_EDC_LFC;...
            [LFC_opt,LFC_capacity_t,EDC_opt,EDC_capacity_t]];
        B=[B;b_lfc(2:12)'];
        I=[I,i];
    end
end