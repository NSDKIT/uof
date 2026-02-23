p=pwd;
cd('E:\01_遐皮ｩｶ雉�譁兔00_AGC30\隱ｲ鬘圭16B髮ｻ蜉幃怙邨ｦ蜻ｨ豕｢謨ｰ繧ｷ繝溘Η繝ｬ繝ｼ繧ｷ繝ｧ繝ｳ縺ｮ讓呎ｺ冶ｧ｣譫舌Δ繝�繝ｫ隗｣譫蝉ｾ矩｡碁寔\隗｣譫蝉ｾ矩｡碁寔\07 讓呎ｺ悶ョ繝ｼ繧ｿ\01 髴�隕√ョ繝ｼ繧ｿ')
LL=get_load_agc('(讓呎ｺ悶ョ繝ｼ繧ｿ) 髴�隕√ョ繝ｼ繧ｿ 螟丞ｭ｣蟷ｳ譌･.xlsx');
LL=[LL(1:50400,5);LL(:,11)];
demand_1sec=LL(7201:7201+90000)';
demand_1sec=4000*demand_1sec/max(demand_1sec);
cd(p)
% pl_ox = 0; % 繝励Ο繝�繝域怏辟｡菫よ焚
% Year = year;Month = month;Day = day;
% clear day
% %% 蛹鈴匣繧ｨ繝ｪ繧｢PV蜃ｺ蜉帛ｮ滓ｸｬ蛟､縺ｮ謚ｽ蜃ｺ
% Demand_real=csv_tieline_PV2019('蛹鈴匣螻ｱ蜈�2019');
% Demand_real=table2array(Demand_real(2:end,3));
% Demand_real(isnan(Demand_real))=[];
% %% 譌･莉倡分蜿ｷ縺ｮ蜿門ｾ�
% t_331 = datetime(Year,3,31);dn = day(t_331,'dayofyear'); %3譛�31譌･縺ｮ譌･莉倡分蜿ｷ繧貞叙蠕�
% t_target = datetime(Year,Month,Day);dn = day(t_target,'dayofyear')-dn; %隗｣譫仙ｯｾ雎｡譌･縺ｮ譌･莉倡分蜿ｷ繧貞叙蠕�
% %% 隗｣譫仙ｯｾ雎｡譌･縺ｮ髴�隕∝ｮ溽ｸｾ蛟､縺ｮ蜿門ｾ�
% Demand_own=Demand_real(1440*(dn-1)+1:1440*dn+60,:);
% Demand_30=Demand_real(1440*(dn-1)+1:1440*(dn)+61,:); %蠕�30蛻�蟷ｳ蝮�蛟､逕ｨ縺ｮ繝�繝ｼ繧ｿ謚ｽ蜃ｺ
% Demand_own=reshape(Demand_own,[1,length(Demand_own)]);
% Demand_30=reshape(Demand_30,[1,length(Demand_30)]);
% %% 30蛻�蟷ｳ蝮�蛟､菴懈��
% A30 = Demand_30(1);
% for i = 1:49
%     a30 = mean(Demand_30(30*(i-1)+1:30*i));
%     A30 = [A30;a30];
% end
% %% 螳滓ｸｬ蛟､縺ｮ諡｡蠑ｵ
% for n = 1:2 % 1蝗樒岼: 隕∫ｴ�謨ｰ繧呈僑蠑ｵ縺励◆譎ゅ↓�ｼ悟ｮ滓ｸｬ繝�繝ｼ繧ｿ縺梧ｸ帛ｰ代☆繧九°繧会ｼ後◎縺ｮ譎ゅ�ｮ譛�螟ｧ蛟､繧貞叙蠕�
%             % 2蝗樒岼: 隕∫ｴ�謨ｰ繧呈僑蠑ｵ縺励◆譎ゅ�ｮ譛�螟ｧ蛟､縺九ｉ�ｼ悟ｮ溘ョ繝ｼ繧ｿ縺ｨ蜷後§隕乗ｨ｡縺ｫ螳壽焚蛟阪＠縺ｦ�ｼ瑚ｦ∫ｴ�謨ｰ繧呈僑蠑ｵ縺吶ｋ
%     %% 鬮倬�溘ヵ繝ｼ繝ｪ繧ｨ螟画鋤縺ｫ繧医ｊ繝輔�ｼ繝ｪ繧ｨ菫よ焚邂怜�ｺ
%     if n == 1
%         fft_BiE=fft(Demand_own);
%     elseif n == 2
%         fft_BiE=fft(Demand_own*max(Demand_own)/max(row));
%     end
%     n=length(Demand_own);
%     %% 蜻ｨ豕｢謨ｰ鬆伜沺縺ｧ縺ｮ繝ｪ繝九い繧ｹ繝壹け繝医Ν�ｼ後ヱ繝ｯ繝ｼ繧ｹ繝壹け繝医Ν邂怜�ｺ
%     powerBiE_L = (abs(fft_BiE(1:floor(n/2)))); %繝ｪ繝九い繧ｹ繝壹け繝医Ν
%     powerBiE_A = (abs(fft_BiE(1:floor(n/2)))).^2; %螳滓ｸｬ繝�繝ｼ繧ｿ縺ｮ繝代Ρ繝ｼ繧ｹ繝壹け繝医Ν
%     %% 蜻ｨ譛滄�榊�励�ｮ菴懈��
%     maxfreq=1/120;freq=(1:n/2)/(n/2)*maxfreq; %蜊雁��縺ｮ蜻ｨ豕｢謨ｰ
%     period1 = 1./freq; %蜊雁��縺ｮ蜻ｨ譛�
%     %% 螳滓ｸｬ蛟､縺ｮ繝輔�ｼ繝ｪ繧ｨ菫よ焚縺ｮ諡｡蠑ｵ
%     N=60*60*24+1800*2; %sec*min*day 1譌･縺ｮ遘呈焚
%     T =60;      %60sec, 繧ｵ繝ｳ繝励Μ繝ｳ繧ｰ蜻ｨ譛�
%     All_BiE=zeros(N,1); %遨ｺ縺ｮ驟榊��
%     All_BiE(1:N/(2*T))=fft_BiE(1:length(fft_BiE)/2); %螳滓ｸｬ繝�繝ｼ繧ｿ莉｣蜈･
%     All_BiE(length(All_BiE)-(N/(2*T))+1:end)=fft_BiE(length(fft_BiE)/2+1:end); %螳滓ｸｬ繝�繝ｼ繧ｿ莉｣蜈･
%     %% 螳溽ｸｾ蛟､縺ｮ菴懈��(騾�繝輔�ｼ繝ｪ繧ｨ螟画鋤)
%     row = real(ifft(All_BiE));
%     row = reshape(row,[1,length(row)]);
% end
% %% 霑台ｼｼ逶ｴ邱壻ｽ懈��
% num = (period1>=120).*(period1<3600);
% ne_liner(1,log10([period1(find(num==1))',powerBiE_A(find(num==1))']),'b',[1,10^4],[1,10^8])
% a1 = line.a;b1 = line.b;
% % 繝励Ο繝�繝医〒遒ｺ隱�
% if pl_ox == 1
%     figure,loglog(period1,powerBiE_A)
%     hold on
%     loglog(10^(b1)*[1:1000].^(a1))
% end
% %% 繝帙Ρ繧､繝医う繧ｺ菴懈��
% %     rng('default');rng(1);R=rand(1,86400+1800*2);
% %     r = (R-0.5);
% %     n=length(r);
% %     fft_r=fft(r); %鬮倬�溘ヵ繝ｼ繝ｪ繧ｨ螟画鋤竊偵ヵ繝ｼ繝ｪ繧ｨ菫よ焚
% %     P_2_L = (abs(fft_r(1:floor(n/2)))); %繝ｪ繝九い繧ｹ繝壹け繝医Ν
% %     P_2_A = (abs(fft_r(1:floor(n/2)))).^2; %繝帙Ρ繧､繝医ヮ繧､繧ｺ縺ｮ繝代Ρ繝ｼ繧ｹ繝壹け繝医Ν
% %     maxfreq=1/2;freq=(1:n/2)/(n/2)*maxfreq; %蜊雁��縺ｮ蜻ｨ豕｢謨ｰ
% %     period = 1./freq; %蜊雁��縺ｮ蜻ｨ譛�
% %     %% 霑台ｼｼ逶ｴ邱壻ｽ懈��
% %     % 螳滓ｸｬ蛟､縺ｨ霑代＞蜻ｨ譛�(60遘偵°繧�120遘偵∪縺ｧ)縺ｧ霑台ｼｼ逶ｴ邱壹ｒ蜿悶ｋ
% %     num = (period<120).*(period>=60);
% %     ne_liner(1,log10([period(find(num==1))',P_2_A(find(num==1))']))
% %     a2 = line.a;b2 = line.b;
% %     % 蛻�迚�繧呈峩譁ｰ縺励※�ｼ悟�榊ｺｦ霑台ｼｼ逶ｴ邱壻ｽ懈��
% %     P = P_2_A/10^(b2-b1);
% %     ne_liner(1,log10([period(find(num==1))',P(find(num==1))']))
% %     a2 = line.a;b2 = line.b;
% %% 霑台ｼｼ逶ｴ邱壹�ｮ蛯ｾ縺阪ｒ遲峨＠縺上☆繧九◆繧√�ｮ郢ｰ繧願ｿ斐＠繧ｳ繝槭Φ繝�
% %     equal_kinji
% %     %% 遏ｭ蜻ｨ譛溷､牙虚縺ｮ菴懈��(騾�繝輔�ｼ繝ｪ繧ｨ螟画鋤)
% %     load('PVC.mat')
% %     fugou = sign(fft_r);
% %     white = real(ifft((fugou.*sqrt(P_2_A/sqrt(PVC/1010)/(10^(b2-b1)))))); 
% %% 遏ｭ蜻ｨ譛溷､牙虚繧定��諷ｮ縺励◆PV蜃ｺ蜉帙�ｮ菴懈��
% demand_1sec = row;
% % demand_1sec = white+row;
% demand_1sec(demand_1sec<0.001) = 0;
% % 繝励Ο繝�繝医〒遒ｺ隱�
% if pl_ox == 1
%     re_PS(demand_1sec,[],[])
%     figure,plot(demand_1sec);hold on;plot(row)
% end
%% 髴�隕∽ｺ域ｸｬ菴懈��(髢灘ｼ輔″�ｼ嗟oad_forecast_30min)
demand_30min = demand_1sec(1);
for t =  1:49
    demand_30min = [demand_30min;mean(demand_1sec(1800*t-900:1800*t+900))]; %1遘偵ョ繝ｼ繧ｿ縺ｮ驟榊��(30蛻�遯捺歓蜃ｺ)
end
save demand_30min.mat demand_30min    
save demand_1sec.mat demand_1sec