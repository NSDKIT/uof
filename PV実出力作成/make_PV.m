%% PV菴懈��
disp('繧ｷ繝溘Η繝ｬ繝ｼ繧ｷ繝ｧ繝ｳ螳溯｡後�ｮ縺溘ａ縺ｮPV菴懈��')
load('pv.mat')
if pv == 0
    origin_PV=zeros(86400,1);
    save('origin_PV.mat','origin_PV')
else
    if year == 2018
        PV_origin2018           %PV譖ｲ邱壹�ｮ驕ｸ謚橸ｼ檎洒蜻ｨ譛溷､牙虚縺ｮ螟匁諺
    else
        PV_origin2019           %PV譖ｲ邱壹�ｮ驕ｸ謚橸ｼ檎洒蜻ｨ譛溷､牙虚縺ｮ螟匁諺
%         PV_origin2019_for_agc
    end
end