load('YMD.mat')
if month>3
    if year == 2018
        chose_date_2018
        PV_origin2018           %PV曲線の選択，短周期変動の外挿
    else
        chose_date_2019
        PV_origin2019           %PV曲線の選択，短周期変動の外挿
    end
else
    if year == 2018
        chose_date_2018
        PV_origin2018           %PV曲線の選択，短周期変動の外挿
    else
        chose_date_2019
        PV_origin2019           %PV曲線の選択，短周期変動の外挿
    end
end