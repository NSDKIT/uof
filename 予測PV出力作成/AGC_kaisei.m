p=pwd;
PV=get_PVstandard('PV_蠢ｫ譎ｴ.xlsx');
PVF=PV(:,5);
PVF(isnan(PVF))=[];
% PVO=PV(:,2);
% PVO(isnan(PVO))=[];

data=[];
% data_o=[];
for t = 1:24
    data=[data;PVF(60*(t-1)+1)];
%     data_o=[data_o;PVO(60*60*(t-1)+1)];
end
% data_o=data_o*data(12)/data_o(12);
data=[data(2:end);0];
cd(p)