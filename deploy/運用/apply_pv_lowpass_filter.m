pvf = PVF;
pv_data = PV_Out(2,:);

delta_PV = pvf-pv_data;
pn = (delta_PV>=0);
PV_Out(2,:) = pv_data .* pn + pvf .* (pn == 0);