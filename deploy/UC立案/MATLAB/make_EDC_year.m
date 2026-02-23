EDC_1sigma_n_plus=[];EDC_2sigma_n_plus=[];EDC_3sigma_n_plus=[];
EDC_1sigma_n_minus=[];EDC_2sigma_n_minus=[];EDC_3sigma_n_minus=[];
for t = 1:48
    data0_plus=EDC_5min(t,:);
    data0_minus=EDC_5min(t,:);
    
    data0_plus(data0_plus<0)=[];
    data0_minus(data0_minus>0)=[];
    data0_minus=abs(data0_minus);

    %% 
    EDC_3sigma_plus=prctile(data0_plus,99.73); % 99.73
    EDC_2sigma_plus=prctile(data0_plus,95.45); % 95.45+(100-95.45)/2
    EDC_1sigma_plus=prctile(data0_plus,68.27); % 68.27+(100-68.27)/2

    EDC_1sigma_n_plus=[EDC_1sigma_n_plus;EDC_1sigma_plus];
    EDC_2sigma_n_plus=[EDC_2sigma_n_plus;EDC_2sigma_plus];
    EDC_3sigma_n_plus=[EDC_3sigma_n_plus;EDC_3sigma_plus];
    
    %% 
    EDC_3sigma_minus=prctile(data0_minus,99.73); % 99.73
    EDC_2sigma_minus=prctile(data0_minus,95.45); % 95.45+(100-95.45)/2
    EDC_1sigma_minus=prctile(data0_minus,68.27); % 68.27+(100-68.27)/2

    EDC_1sigma_n_minus=[EDC_1sigma_n_minus;EDC_1sigma_minus];
    EDC_2sigma_n_minus=[EDC_2sigma_n_minus;EDC_2sigma_minus];
    EDC_3sigma_n_minus=[EDC_3sigma_n_minus;EDC_3sigma_minus];
end