if Month < 10
    if Month < 4
        NAME1 = [num2str(Year+1),'-0',num2str(Month)];
        NAME2 = ['GRIB_',num2str(Year+1),'0',num2str(Month)];
    else
        NAME1 = [num2str(Year),'-0',num2str(Month)];
        NAME2 = ['GRIB_',num2str(Year),'0',num2str(Month)];
    end
else
    NAME1 = [num2str(Year),'-',num2str(Month)];
    NAME2 = ['GRIB_',num2str(Year),num2str(Month)];
end
load('../TT.mat')
if Day < 10
    NAME_a = [NAME1,'-0',num2str(Day)];
else
    NAME_a = [NAME1,'-',num2str(Day)];
end

%% 
cd(fullfile(MSM_DATA_DIR, NAME_a))
copyfile('00-15.bin', WGRIB2_DIR)
copyfile('16-33.bin', WGRIB2_DIR)
copyfile('34-39.bin', WGRIB2_DIR)


% cd C:\Users\PowerSystemLab\Downloads
% A=dir(NAME_a);
% TF = isempty(A); %空（存在しない）なら 1 を出力
% if TF == 1 %空（存在しない）場合
% %     cd ../Desktop/研究資料/北陸電力
% %     cd (NAME3)
%     cd C:\Users\PowerSystemLab\Documents\msm\dldata
%     A=dir(NAME_a);
%     TF = isempty(A); %空（存在しない）なら 1 を出力
%     if TF == 1 %空（存在しない）場合
%         cd C:\Users\PowerSystemLab\Desktop\01_研究資料\03_日射量予測
%         A=dir(NAME3);
%         TF = isempty(A);
%         if TF == 1
%             cd 'C:\Users\PowerSystemLab\Desktop\01_研究資料\02_msm_wgirb2\wgrib2_ok'
%         else
%             cd (NAME3)
%             A=dir(NAME_a);
%             TF = isempty(A);
%             if TF == 1
%             else
%                copyfile(NAME_a,'C:\Users\PowerSystemLab\Desktop\01_研究資料\02_msm_wgirb2\wgrib2_ok')
%             end
%         end
%     else
%         copyfile(NAME_a,'C:\Users\PowerSystemLab\Desktop\01_研究資料\02_msm_wgirb2\wgrib2_ok')
%     end
% else %存在するの場合
%     copyfile(NAME_a,'C:\Users\PowerSystemLab\Desktop\研究資料\msm_wgirb2\wgrib2_ok')
% end
% %% 
% cd C:\Users\PowerSystemLab\Downloads
% A=dir(NAME_b);
% TF = isempty(A); %空（存在しない）なら 1 を出力
% if TF == 1 %空（存在しない）場合
% %     cd ../Desktop/研究資料/北陸電力
% %     cd (NAME3)
%     cd C:\Users\PowerSystemLab\Documents\msm\dldata
%     A=dir(NAME_b);
%     TF = isempty(A); %空（存在しない）なら 1 を出力
%     if TF == 1 %空（存在しない）場合
%         cd C:\Users\PowerSystemLab\Desktop\01_研究資料\03_日射量予測
%         A=dir(NAME3);
%         TF = isempty(A);
%         if TF == 1
%             cd 'C:\Users\PowerSystemLab\Desktop\01_研究資料\02_msm_wgirb2\wgrib2_ok'
%         else
%             cd (NAME3)
%             A=dir(NAME_b);
%             TF = isempty(A);
%             if TF == 1
%             else
%                copyfile(NAME_b,'C:\Users\PowerSystemLab\Desktop\01_研究資料\02_msm_wgirb2\wgrib2_ok')
%             end
%         end
%     else
%         copyfile(NAME_b,'C:\Users\PowerSystemLab\Desktop\01_研究資料\02_msm_wgirb2\wgrib2_ok')
%     end
% else %存在するの場合
%     copyfile(NAME_b,'C:\Users\PowerSystemLab\Desktop\01_研究資料\02_msm_wgirb2\wgrib2_ok')
% end
% %% 
% cd C:\Users\PowerSystemLab\Downloads
% A=dir(NAME_c);
% TF = isempty(A); %空（存在しない）なら 1 を出力
% if TF == 1 %空（存在しない）場合
% %     cd ../Desktop/研究資料/北陸電力
% %     cd (NAME3)
%     cd C:\Users\PowerSystemLab\Documents\msm\dldata
%     A=dir(NAME_c);
%     TF = isempty(A); %空（存在しない）なら 1 を出力
%     if TF == 1 %空（存在しない）場合
%         cd C:\Users\PowerSystemLab\Desktop\01_研究資料\03_日射量予測
%         A=dir(NAME3);
%         TF = isempty(A);
%         if TF == 1
%             cd 'C:\Users\PowerSystemLab\Desktop\01_研究資料\02_msm_wgirb2\wgrib2_ok'
%         else
%             cd (NAME3)
%             A=dir(NAME_c);
%             TF = isempty(A);
%             if TF == 1
%             else
%                copyfile(NAME_c,'C:\Users\PowerSystemLab\Desktop\01_研究資料\02_msm_wgirb2\wgrib2_ok')
%             end
%         end
%     else
%         copyfile(NAME_c,'C:\Users\PowerSystemLab\Desktop\01_研究資料\02_msm_wgirb2\wgrib2_ok')
%     end
% else %存在するの場合
%     copyfile(NAME_c,'C:\Users\PowerSystemLab\Desktop\01_研究資料\02_msm_wgirb2\wgrib2_ok')
% end
%% 
cd(ROOT_DIR)