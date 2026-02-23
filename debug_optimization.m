%% 繝�繝舌ャ繧ｰ逕ｨ繧ｹ繧ｯ繝ｪ繝励ヨ - 譛�驕ｩ蛹門�ｦ逅�縺ｮ繧ｨ繝ｩ繝ｼ隧ｳ邏ｰ繧堤｢ｺ隱�
clear; clc;

% 菴懈･ｭ繝�繧｣繝ｬ繧ｯ繝医Μ縺ｫ遘ｻ蜍�

% 蠢�隕√↑繝代せ繧定ｿｽ蜉�
fprintf('MATLAB繝代せ縺ｫ01_matlab_mytool繧定ｿｽ蜉�縺励∪縺励◆\n');

% 譌･莉倩ｨｭ螳�
year_l = 2019;
month_l = 8;
day_l = 28;
save('YMD.mat','year_l','month_l','day_l')

% 蠢�隕√↑險ｭ螳�
error_ox = 0;
save('error_ox.mat','error_ox')

meth_num = 2;  % 邱壼ｽ｢謇区ｳ�
save('meth_num.mat','meth_num')

sigma = 2;
save('sigma.mat','sigma')

mode = 1;  % 迚�髱｢
save('mode.mat','mode')

lfc = 8;
save('lfclfc.mat','lfc')

PVC = 5300;
save('PVC.mat','PVC')

% 譌･莉俶枚蟄怜�励�ｮ菴懈��
start_date = datetime(2019, 4, 1);
end_date = datetime(2020, 3, 31);
date_range = start_date:end_date;
date_strings = datestr(date_range, 'yyyymmdd');
save('date_strings.mat','date_strings')

% DN縺ｮ險育ｮ�
YYYY = str2num(date_strings(:,1:4))==year_l;
MM = str2num(date_strings(:,5:6))==month_l;
DD = str2num(date_strings(:,7:8))==day_l;
DN = find(YYYY.*MM.*DD);

fprintf('DN = %d (譌･莉倥う繝ｳ繝�繝�繧ｯ繧ｹ)\n', DN);

% 繝�繝ｼ繧ｿ縺ｮ貅門ｙ
if year_l==2020
    y=year_l-1;
else
    y=year_l;
end

fprintf('蝓ｺ譛ｬ繝�繝ｼ繧ｿ縺ｮ隱ｭ縺ｿ霎ｼ縺ｿ荳ｭ...\n');
load(['蝓ｺ譛ｬ繝�繝ｼ繧ｿ/PV_base_',num2str(y),'.mat'])
PV_base=[PV_base(end-2:end,3)',PV_base(1:end-3,3)'];
load(['蝓ｺ譛ｬ繝�繝ｼ繧ｿ/PR_',num2str(y),'.mat'])
load(['蝓ｺ譛ｬ繝�繝ｼ繧ｿ/MSM_bai_',num2str(y),'.mat'])
load('蝓ｺ譛ｬ繝�繝ｼ繧ｿ/irr_fore_data.mat')
load('蝓ｺ譛ｬ繝�繝ｼ繧ｿ/D_1sec.mat')
load('蝓ｺ譛ｬ繝�繝ｼ繧ｿ/D_30min.mat')
load('蝓ｺ譛ｬ繝�繝ｼ繧ｿ/irr_mea_data.mat')

fprintf('莠域ｸｬPV蜃ｺ蜉帙�ｮ菴懈�蝉ｸｭ...\n');
n_l=[1,mode];
PVF_30min_al=irr_fore_data(24*((DN-1)-1)+1:24*(DN-1),n_l(1))*MSM_bai(month_l)*PR(month_l)*PV_base(month_l)/1000;
PVF_30min_new=irr_fore_data(24*((DN-1)-1)+1:24*(DN-1),n_l(2))*MSM_bai(month_l)*PR(month_l)*PV_base(month_l)/1000;
PV_al=1100;
PVF_30min=PVF_30min_al*PV_al/PV_base(month_l)+PVF_30min_new*(PVC-PV_al)/PV_base(month_l);
x = 1:24;
xq_1min = 1:1/2:24;
PVF_30min = [interp1(x,PVF_30min,xq_1min),0,0,0];
PVF_30min(isnan(PVF_30min))=0;
save('PVF_30min.mat','PVF_30min')

fprintf('髴�隕√ョ繝ｼ繧ｿ縺ｮ菴懈�蝉ｸｭ...\n');
demand_1sec=D_1sec(DN,:)-500;
demand_30min=D_30min(DN,:)-500;
save('demand_30min.mat','demand_30min')
save('demand_1sec.mat','demand_1sec')

fprintf('PV螳溷�ｺ蜉帙ョ繝ｼ繧ｿ縺ｮ菴懈�蝉ｸｭ...\n');
PV_1sec_al=irr_mea_data(86401*(DN-1):86401*DN,n_l(1))*PR(month_l)*PV_base(month_l)/1000;
PV_1sec_new=irr_mea_data(86401*(DN-1):86401*DN,n_l(2))*PR(month_l)*PV_base(month_l)/1000;
PV_1sec=PV_1sec_al*PV_al/PV_base(month_l)+PV_1sec_new*(PVC-PV_al)/PV_base(month_l);
save('PV_1sec.mat','PV_1sec')

fprintf('\n譛�驕ｩ蛹門�ｦ逅�繧貞ｮ溯｡御ｸｭ...\n');
cd('UC遶区｡�/MATLAB')

try
    % 譛�驕ｩ蛹悶ｒ螳溯｡�
    new_optimization
    fprintf('\n笨� 譛�驕ｩ蛹悶′豁｣蟶ｸ縺ｫ螳御ｺ�縺励∪縺励◆�ｼ―n');
catch ME
    fprintf('\n笨� 繧ｨ繝ｩ繝ｼ縺檎匱逕溘＠縺ｾ縺励◆:\n');
    fprintf('繧ｨ繝ｩ繝ｼ繝｡繝�繧ｻ繝ｼ繧ｸ: %s\n', ME.message);
    fprintf('\n繧ｨ繝ｩ繝ｼ逋ｺ逕溷�ｴ謇�:\n');
    for k = 1:length(ME.stack)
        fprintf('  %s (陦� %d)\n', ME.stack(k).name, ME.stack(k).line);
    end

    % 隧ｳ邏ｰ縺ｪ繧ｨ繝ｩ繝ｼ諠�蝣ｱ
    fprintf('\n繧ｨ繝ｩ繝ｼ縺ｮ隧ｳ邏ｰ:\n');
    fprintf('  隴伜挨蟄�: %s\n', ME.identifier);
    if ~isempty(ME.cause)
        fprintf('  蜴溷屏:\n');
        for c = 1:length(ME.cause)
            fprintf('    - %s\n', ME.cause{c}.message);
        end
    end
end

cd('../../')
fprintf('\n螳御ｺ�\n');
