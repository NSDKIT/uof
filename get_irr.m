cd F:\NSD_MSM\dldata

loc = [' -lon ',num2str(KEIDO(area)),' ',num2str(IDO(area))];

file1='00-15.bin';
file2='16-33.bin';
file3='34-39.bin';

copyfile(fullfile(GRIB_F,file1),...
    'C:\Users\PowerSystemLab\Desktop\01_研究資料\02_msm_wgirb2\wgrib2_ok');
copyfile(fullfile(GRIB_F,file2),...
    'C:\Users\PowerSystemLab\Desktop\01_研究資料\02_msm_wgirb2\wgrib2_ok');
copyfile(fullfile(GRIB_F,file3),...
    'C:\Users\PowerSystemLab\Desktop\01_研究資料\02_msm_wgirb2\wgrib2_ok');
cd 'C:\Users\PowerSystemLab\Desktop\01_研究資料\02_msm_wgirb2\wgrib2_ok'
file1=['wgrib2.exe ',file1,' ',loc,' -last grib.csv -nl_out grib.csv'];
file2=['wgrib2.exe ',file2,' ',loc,' -last grib.csv -nl_out grib.csv'];
file3=['wgrib2.exe ',file3,' ',loc,' -last grib.csv -nl_out grib.csv'];

system(file1);data1 = get_msm_fm_bin('grib.csv',1);
system(file2);data2 = get_msm_fm_bin('grib.csv',1);
system(file3);data3 = get_msm_fm_bin('grib.csv',1);
l1=length(data1);l2=length(data2);l3=length(data3);
a_l1=zeros(l1+l2+l3,1);
a_l2=a_l1;
a_l3=a_l1;

a_l1(1:l1)=data1;
a_l2(l1+1:l1+l2)=data2;
a_l3(l1+l2+1:l1+l2+l3)=data3;

a=a+a_l1+a_l2+a_l3;

%% 日射量は設置方法毎に変換
irr_data_ori=a_l1+a_l2+a_l3;

irr_data=reshape(irr_data_ori(11:end),12,39);
irr_data=[[irr_data_ori(1:10);zeros(2,1)],irr_data];
irr_data=irr_data(end,17:40);

delete('*.bin')