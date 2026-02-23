clear;p=pwd;
%% 邨檎ｷｯ蠎ｦ縺ｮ險ｭ螳�
load('ido_keido.mat')
IDO=ido;KEIDO=keido;

LAT = IDO; % 邱ｯ蠎ｦ
LAT = fix(LAT)+(LAT-fix(LAT))*100/60; % 邱ｯ蠎ｦ縺ｮ譖ｴ譁ｰ
LON = KEIDO; % 邨悟ｺｦ    
LON = fix(LON)+(LON-fix(LON))*100/60; % 邨悟ｺｦ縺ｮ譖ｴ譁ｰ

%% 譌･譎よュ蝣ｱ菴懈��
start_date = datetime(2019, 4, 1);end_date = datetime(2020, 2, 27);date_range = start_date:end_date;date_strings = datestr(date_range, 'yyyymmdd');

%% 繝代Λ繝｡繝ｼ繧ｿ險ｭ螳�
% 蛯ｾ譁懆ｧ定ｨｭ螳壽凾縺ｫ3ﾃ�3驟榊�励ｒ菴懈�舌＠�ｼ後Δ繝ｼ繝峨↓蟇ｾ蠢懊☆繧�(荳�霆ｸ霑ｽ蟆ｾ縺ｯ蛯ｾ譁懆ｧ帝未菫ゅ↑縺�)
keisha_kaku = [20;90;90]; % 2陦檎岼縺ｯ荳｡髱｢譚ｱ繝ｻ隘ｿ(m:2,3)
% 譁ｹ隗定ｨｭ螳壽凾縺ｫ3ﾃ�3驟榊�励ｒ菴懈�舌＠�ｼ後Δ繝ｼ繝峨↓蟇ｾ蠢懊☆繧�(荳�霆ｸ霑ｽ蟆ｾ縺ｯ譁ｹ隗帝未菫ゅ↑縺�)
hougaku = [0;90;270]; % 2陦檎岼縺ｯ荳｡髱｢譚ｱ(m:2)�ｼ�3陦檎岼縺ｯ荳｡髱｢隘ｿ(m:3)
% 譎ょ綾譁ｭ髱｢
t=[1:24]-0.5;
% UTC縺ｫ蟇ｾ縺吶ｋ譎ょｷｮ險ｭ螳壽凾縺ｫ5ﾃ�3驟榊�励ｒ菴懈�舌＠�ｼ後Δ繝ｼ繝峨↓蟇ｾ蠢懊☆繧�
jisa = [9*ones(1,4),9-12];

for DD = 1:length(date_strings)
    %% 譌･莉倡分蜿ｷ縺ｮ蜿門ｾ�
    year_l=date_strings(DD,1:4);
    month_l=date_strings(DD,5:6);
    day_l=date_strings(DD,7:8);
    %% x: 蜈�譌ｦ繧�1縺ｨ縺励◆蟷ｴ髢捺律莉倥�ｮ騾壹＠逡ｪ蜿ｷ[deg]
    t_target = datetime(str2num(year_l),str2num(month_l),str2num(day_l));
    day_num = day(t_target,'dayofyear'); %隗｣譫仙ｯｾ雎｡譌･縺ｮ譌･莉倡分蜿ｷ繧貞叙蠕�
    x = (day_num-1)*360/365;
    
    IRR=0;a=0;
    for area = 1:17
        %% PV300縺ｮ蜿門ｾ�
        data = zeros(1,86401);
        pv300 = get_PV300_1sec(fullfile(ROOT_DIR, '基本データ', 'PV実測値作成', '1秒値', ['area',num2str(area)], [num2str(str2double(year_l)),'_',num2str(str2double(month_l))], ['day',num2str(str2double(day_l)),'.csv']));
        data(1:length(pv300))=pv300; % W竍談W竍談Wh
        % 蜑�15蛻�蠕�15蛻�蟷ｳ蝮�蛟､
        irr_data=[0,mean(reshape(data(1800+1:end-1801),3600,[]))];
        irr_data(find(irr_data<0))=0;
        if (sum(irr_data~=0)==0)==1
            irr_area=zeros(86401,5);
        else
            %% 邨檎ｷｯ蠎ｦ蜿門ｾ�
            fai = LAT(area);
            keido = LON(area);
            %% 繝輔ぃ繧､繝ｫ蜷榊叙蠕�
            GRIB_F=[year_l,'-',month_l,'-',day_l];
            f1=[year_l,'-',month_l,'-',day_l];
            %% 險ｭ鄂ｮ譁ｹ豕墓ｯ弱↓螟画鋤
            change_set_irr_measure
        end
        IRR=IRR+irr_area;
    end
    cd(p)
    irr_mea_data(86401*(DD-1)+1:86401*DD,:)=IRR/17;
end
save('../irr_mea_data.mat','irr_mea_data')