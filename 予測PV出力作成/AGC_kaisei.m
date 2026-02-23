p=pwd;
cd('E:\01_研究資料\00_AGC30\課題\16B電力需給周波数シミュレーションの標準解析モデル解析例題集\解析例題集\07 標準データ\02 太陽光発電データ')
PV=get_PVstandard('PV_快晴.xlsx');
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