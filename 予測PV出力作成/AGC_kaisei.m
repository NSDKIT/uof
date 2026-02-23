p=pwd;
cd('E:\01_遐皮ｩｶ雉�譁兔00_AGC30\隱ｲ鬘圭16B髮ｻ蜉幃怙邨ｦ蜻ｨ豕｢謨ｰ繧ｷ繝溘Η繝ｬ繝ｼ繧ｷ繝ｧ繝ｳ縺ｮ讓呎ｺ冶ｧ｣譫舌Δ繝�繝ｫ隗｣譫蝉ｾ矩｡碁寔\隗｣譫蝉ｾ矩｡碁寔\07 讓呎ｺ悶ョ繝ｼ繧ｿ\02 螟ｪ髯ｽ蜈臥匱髮ｻ繝�繝ｼ繧ｿ')
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