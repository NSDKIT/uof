for mode = 1:5
    PVC=1100;PV_Out=[];
for month = [4:12,1:3]
    year=2018; %FY
    if year == 2018 % Until March 30th
        E_D = [31,28,30,30,31,30,31,31,30,31,30,31];
    elseif year == 2019
        E_D = [31,29,30,30,31,30,31,31,30,31,30,31];
    end
    save YM.mat year month
    for day = 1:E_D(month) % 10月20,21日は欠損日
        load('YM.mat')
        if month == 10
            if day == 20 || day == 21
            else
                new_get_PV300_day
%                 cd ../..
                PV_Out=[PV_Out;PV_1sec];
            end
        else
            new_get_PV300_day
%             cd ../..
            PV_Out=[PV_Out;PV_1sec];
        end
    end
end
save(['PVO_mode',num2str(mode)','.mat'],'PV_Out')
end