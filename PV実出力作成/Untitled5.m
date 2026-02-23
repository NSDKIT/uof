MP=[];
for month = [4:12,1:3]
    DDD = [14,24,2,19,22,2,20,5,19,3,3,2];
    day = DDD(month);
    year = 2018;
    cd C:\Users\PowerSystemLab\Desktop\01_遐皮ｩｶ雉�譁兔05_螳溯｡後ヵ繧｡繧､繝ｫ\program\蜈ｨ菴灘ｮ溯｡圭莠域ｸｬPV蜃ｺ蜉帑ｽ懈��
    make_PVF_year
    figure(200);hold on;bar(Month,max(IRR.sum(:,1)))
%     MP=[MP,max(IRR.sum(:,1))];
    clearvars -except MP year DDD
end