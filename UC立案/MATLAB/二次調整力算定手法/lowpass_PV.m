% data=lowpass(PV_Out,1/(60*1));
% short_devi=PV_Out-data;
% delta_PV=PV_forecast_year_line-data;
% pn=(delta_PV>=0);
% PV_Out=PV_Out.*pn+(PV_forecast_year_line+short_devi).*(pn==0);
% PV_Out=PV_Out.*(PV_Out>0);
% % -- delete surplus PV against load
% % short_devi=Demand_year-(Demand_real_year+PV_forecast_year_line);
% % Net_demand=Demand_year-PV_Out;
% % Net_demand_pn=(Net_demand<=0);
% % 
% % PV_Out(isnan(PV_Out))=0;
% 
% % インデックスの作成
% originalIndices = 1:numel(PVF_30min);
% % 拡張後のインデックス
% expandedIndices = linspace(1, numel(PVF_30min), 1800*(size(PVF_30min,2)-1)+1);
% % 線形補完
% pvf= interp1(originalIndices, PVF_30min, expandedIndices, 'linear');
% pvf = pvf(1:86402)';

pvf = PVF;
pv_data = PV_Out(2,:);

delta_PV = pvf-pv_data;
pn = (delta_PV>=0);
PV_Out(2,:) = pv_data .* pn + pvf .* (pn == 0);