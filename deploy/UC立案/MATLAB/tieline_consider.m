I=[];
for i = 1:size(G_ox,1)
    if i == 41
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
    if EDC_capacity_t>=0 && lfc_haibunn_hantei==1 && edc_haibunn_hantei==1
        % 北陸→中部・関西 190万kW
        % 中部・関西→北陸 150万kW
        H_CK=1500;CK_H=1900;
        H_CK=H_CK*0.9;CK_H=CK_H*0.9;
        if round(sikiiatai2,1)<round(beq,1)
            tileline_output=beq-sikiiatai2;
            if tileline_output >= CK_H
                continue
            end
            beq=beq-tileline_output;
        else
            lb_sum=sum(lb.*Aeq');
            if lb_sum<=beq
                tileline_output=0;
            elseif lb_sum>beq
                % 優先給電ルールに基づく出力抑制
                cur=beq-lb_sum;
                if cur >= H_CK
                    tileline_output=-H_CK;
                else
                    tileline_output=-cur;
                end
                % PV抑制制約
                pv_surplus_consider
            end
        end
        
        [p,fval,exitflag] = fmincon(fun,x0,A,b,Aeq,beq,lb,ub+(10^-3));
        
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
        TLO=[TLO;tileline_output];
    end
end