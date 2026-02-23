pl_ox = 0; % 繝励Ο繝�繝域怏辟｡菫よ焚
load('PV_1sec.mat')
% PV_1sec=[PV_1sec(1800:end)',zeros(1,3600)];
PV_1sec=[PV_1sec,zeros(1,1800)];
save PV_1sec.mat PV_1sec
% %% 隗｣譫仙ｯｾ雎｡譌･縺ｮPV螳溽ｸｾ蛟､縺ｮ蜿門ｾ�
% load('PV_1min.mat')
% %% 隗｣譫仙ｯｾ雎｡PV螳ｹ驥上∈諡｡蠑ｵ
% load(['../PV_base_',num2str(year),'.mat'])
% Pv_out=PV_1min*PVC/PV_base(month);
% %% PV繝代ロ繝ｫ險ｭ鄂ｮ譁ｹ豕輔�ｮ驕ｸ謚�
% Pv_out=reshape(Pv_out,[1,length(Pv_out)]); % 驟榊�励�ｮ蠖｢迥ｶ謨ｴ逅�
% %% 螳滓ｸｬ蛟､縺ｮ諡｡蠑ｵ
% for n = 1:2 % 1蝗樒岼: 隕∫ｴ�謨ｰ繧呈僑蠑ｵ縺励◆譎ゅ↓�ｼ悟ｮ滓ｸｬ繝�繝ｼ繧ｿ縺梧ｸ帛ｰ代☆繧九°繧会ｼ後◎縺ｮ譎ゅ�ｮ譛�螟ｧ蛟､繧貞叙蠕�
%             % 2蝗樒岼: 隕∫ｴ�謨ｰ繧呈僑蠑ｵ縺励◆譎ゅ�ｮ譛�螟ｧ蛟､縺九ｉ�ｼ悟ｮ溘ョ繝ｼ繧ｿ縺ｨ蜷後§隕乗ｨ｡縺ｫ螳壽焚蛟阪＠縺ｦ�ｼ瑚ｦ∫ｴ�謨ｰ繧呈僑蠑ｵ縺吶ｋ
%     %% 鬮倬�溘ヵ繝ｼ繝ｪ繧ｨ螟画鋤縺ｫ繧医ｊ繝輔�ｼ繝ｪ繧ｨ菫よ焚邂怜�ｺ
%     if n == 1
%         fft_BiE=fft(Pv_out);
%     elseif n == 2
%         fft_BiE=fft(Pv_out*max(Pv_out)/max(row));
%     end
%     n=length(Pv_out);
%     %% 蜻ｨ豕｢謨ｰ鬆伜沺縺ｧ縺ｮ繝ｪ繝九い繧ｹ繝壹け繝医Ν�ｼ後ヱ繝ｯ繝ｼ繧ｹ繝壹け繝医Ν邂怜�ｺ
%     powerBiE_L = (abs(fft_BiE(1:floor(n/2)))); %繝ｪ繝九い繧ｹ繝壹け繝医Ν
%     powerBiE_A = (abs(fft_BiE(1:floor(n/2)))).^2; %螳滓ｸｬ繝�繝ｼ繧ｿ縺ｮ繝代Ρ繝ｼ繧ｹ繝壹け繝医Ν
%     %% 蜻ｨ譛滄�榊�励�ｮ菴懈��
%     maxfreq=1/120;freq=(1:n/2)/(n/2)*maxfreq; %蜊雁��縺ｮ蜻ｨ豕｢謨ｰ
%     period1 = 1./freq; %蜊雁��縺ｮ蜻ｨ譛�
%     %% 螳滓ｸｬ蛟､縺ｮ繝輔�ｼ繝ｪ繧ｨ菫よ焚縺ｮ諡｡蠑ｵ
%     N=60*60*24; %sec*min*day 1譌･縺ｮ遘呈焚
%     T =60;      %60sec, 繧ｵ繝ｳ繝励Μ繝ｳ繧ｰ蜻ｨ譛�
%     All_BiE=zeros(N,1); %遨ｺ縺ｮ驟榊��
%     All_BiE(1:N/(2*T))=fft_BiE(1:length(fft_BiE)/2); %螳滓ｸｬ繝�繝ｼ繧ｿ莉｣蜈･
%     All_BiE(length(All_BiE)-(N/(2*T))+1:end)=fft_BiE(length(fft_BiE)/2+1:end); %螳滓ｸｬ繝�繝ｼ繧ｿ莉｣蜈･
%     %% 螳溽ｸｾ蛟､縺ｮ菴懈��(騾�繝輔�ｼ繝ｪ繧ｨ螟画鋤)
%     row = real(ifft(All_BiE));
%     row = reshape(row,[1,length(row)]);
% end
% %% 霑台ｼｼ逶ｴ邱壻ｽ懈��
% ne_liner(1,log10([period1(1:end/2)',powerBiE_A(1:end/2)']),'b',[1,10^4],[1,10^8])
% a1 = line.a;b1 = line.b;
% % 繝励Ο繝�繝医〒遒ｺ隱�
% if pl_ox == 1
%     figure,loglog(period1,powerBiE_A)
%     hold on
%     loglog(10^(b1)*[1:1000].^(a1))
% end
% %% 繝帙Ρ繧､繝医う繧ｺ菴懈��
% rng('default');rng(1);R=rand(1,86400);
% r = (R-0.5)/sqrt(PVC/PV_base(month));
% n=length(r);
% fft_r=fft(r); %鬮倬�溘ヵ繝ｼ繝ｪ繧ｨ螟画鋤竊偵ヵ繝ｼ繝ｪ繧ｨ菫よ焚
% P_2_L = (abs(fft_r(1:floor(n/2)))); %繝ｪ繝九い繧ｹ繝壹け繝医Ν
% P_2_A = (abs(fft_r(1:floor(n/2)))).^2; %繝帙Ρ繧､繝医ヮ繧､繧ｺ縺ｮ繝代Ρ繝ｼ繧ｹ繝壹け繝医Ν
% maxfreq=1/2;freq=(1:n/2)/(n/2)*maxfreq; %蜊雁��縺ｮ蜻ｨ豕｢謨ｰ
% period = 1./freq; %蜊雁��縺ｮ蜻ｨ譛�
% %% 霑台ｼｼ逶ｴ邱壻ｽ懈��
% % 螳滓ｸｬ蛟､縺ｨ霑代＞蜻ｨ譛�(60遘偵°繧�120遘偵∪縺ｧ)縺ｧ霑台ｼｼ逶ｴ邱壹ｒ蜿悶ｋ
% num = (period<120).*(period>=60);
% ne_liner(1,log10([period(find(num==1))',P_2_A(find(num==1))']))
% a2 = line.a;b2 = line.b;
% % 蛻�迚�繧呈峩譁ｰ縺励※�ｼ悟�榊ｺｦ霑台ｼｼ逶ｴ邱壻ｽ懈��
% % P = P_2_A/10^(b2-b1);
% % ne_liner(1,log10([period(find(num==1))',P(find(num==1))']))
% % a2 = line.a;b2 = line.b;
% %% 霑台ｼｼ逶ｴ邱壹�ｮ蛯ｾ縺阪ｒ遲峨＠縺上☆繧九◆繧√�ｮ郢ｰ繧願ｿ斐＠繧ｳ繝槭Φ繝�
% equal_kinji
% %% 遏ｭ蜻ｨ譛溷､牙虚縺ｮ菴懈��(騾�繝輔�ｼ繝ｪ繧ｨ螟画鋤)
% load('PVC.mat')
% fugou = sign(fft_r);
% white = real(ifft((fugou.*sqrt(P_2_A/sqrt(PVC/1010)/(10^(b2-b1)))))); 
% %% 遏ｭ蜻ｨ譛溷､牙虚繧定��諷ｮ縺励◆PV蜃ｺ蜉帙�ｮ菴懈��
% PV_1sec = white+row;
% PV_1sec(PV_1sec<0.001) = 0;
% % 繝励Ο繝�繝医〒遒ｺ隱�
% if pl_ox == 1
%     re_PS(PV_1sec,[],[])
%     figure,plot(PV_1sec);hold on;plot(row)
% end
% PV_1sec=[PV_1sec(1801:end),zeros(1,3600)];
% save PV_1sec.mat PV_1sec