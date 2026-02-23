P=[];PV_cur=[];Fval=[];Flag=[];
for i = 1:size(G_ox,1)
    % -- 最適化データの作成 --
    build_lp_problem_danger
    sikiiatai2=sum(ub(find(Aeq)));

    if EDC_capacity_t>=0 && round(sikiiatai2,1)>=round(beq,1) && lfc_haibunn_hantei==1 && edc_haibunn_hantei==1
        lb_sum=sum(lb.*Aeq');
        if lb_sum<=beq
            delta_lb=ones(11,1).*(10^-3);
        elseif lb_sum>beq
            solve_uc_lp_pv_surplus
            delta_lb=[ones(11,1).*(10^-3);0];
        end
        [p,fval,exitflag] = fmincon(fun,x0,A,b,Aeq,beq,lb,ub+delta_lb);
            
        if exitflag == -2
            fval=10^10^10;
        end
    
        if length(p) == 11
            pv_cur=0;
        elseif length(p) == 12
            pv_cur=p(12);
        end
                
        p = p(1:11).*(p(1:11)>1);
        
        P=[P;p(1:11)];
        PV_cur=[PV_cur,pv_cur];
        Fval=[Fval;fval];
        Flag=[Flag;exitflag];
    end
end