L_s = fft_X;N=1:length(fft_X);
LL_s = (L_s.^(log10(a1-a2))) .* (10.^(log10(b1-b2)));
%% 繝帙Ρ繧､繝医ヮ繧､繧ｺ縺ｮ繝輔�ｼ繝ｪ繧ｨ菫よ焚陬懈ｭ｣
N=length(fft_X); %sec*min*day �ｼ第律縺ｮ遘呈焚
T=60;       %60sec, 繧ｵ繝ｳ繝励Μ繝ｳ繧ｰ蜻ｨ譛�
All_W=zeros(N,1)'; %繝帙Ρ繧､繝医ヮ繧､繧ｺ縺ｮ繝輔�ｼ繝ｪ繧ｨ菫よ焚
                   %繝ｪ繝九い繧ｹ繝壹け繝医Ν
All_W(N/(2*T)+1:N-(N/(2*T)))=LL_s(N/(2*T)+1:N-(N/(2*T)));
%% 謖ｯ蟷�繧ｹ繝壹け繝医Ν蜷域��
%% 騾�繝輔�ｼ繝ｪ繧ｨ螟画鋤蜷域��
white = (real(ifft(All_W)));
white(find(abs(white)==max(abs(white))))=...
    white(find(white==max(white))+1);
P=(white.*row./max(row));
new_re_PS(P,[],[])