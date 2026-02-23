LFC5_1sigma_n_up=[];LFC5_2sigma_n_up=[];LFC5_3sigma_n_up=[];
LFC5_1sigma_n_down=[];LFC5_2sigma_n_down=[];LFC5_3sigma_n_down=[];
for t = 1:48
    data0_up=LFC_5min_up(t,:);
    data0_down=abs(LFC_5min_down(t,:));

    %% 
    LFC5_3sigma_up=prctile(data0_up,99.73); % 99.73
    LFC5_2sigma_up=prctile(data0_up,95.45); % 95.45+(100-95.45)/2
    LFC5_1sigma_up=prctile(data0_up,68.27); % 68.27+(100-68.27)/2

    LFC5_1sigma_n_up=[LFC5_1sigma_n_up;LFC5_1sigma_up];
    LFC5_2sigma_n_up=[LFC5_2sigma_n_up;LFC5_2sigma_up];
    LFC5_3sigma_n_up=[LFC5_3sigma_n_up;LFC5_3sigma_up];
    %% 
    LFC5_3sigma_down=prctile(data0_down,99.73); % 99.73
    LFC5_2sigma_down=prctile(data0_down,95.45); % 95.45+(100-95.45)/2
    LFC5_1sigma_down=prctile(data0_down,68.27); % 68.27+(100-68.27)/2

    LFC5_1sigma_n_down=[LFC5_1sigma_n_down;LFC5_1sigma_down];
    LFC5_2sigma_n_down=[LFC5_2sigma_n_down;LFC5_2sigma_down];
    LFC5_3sigma_n_down=[LFC5_3sigma_n_down;LFC5_3sigma_down];
end