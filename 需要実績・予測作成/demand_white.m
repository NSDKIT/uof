L_s = fft_X;N=1:length(fft_X);
LL_s = (L_s.^(log10(a1-a2))) .* (10.^(log10(b1-b2)));
%% ホワイトノイズのフーリエ係数補正
N=length(fft_X); %sec*min*day １日の秒数
T=60;       %60sec, サンプリング周期
All_W=zeros(N,1)'; %ホワイトノイズのフーリエ係数
                   %リニアスペクトル
All_W(N/(2*T)+1:N-(N/(2*T)))=LL_s(N/(2*T)+1:N-(N/(2*T)));
%% 振幅スペクトル合成
%% 逆フーリエ変換合成
white = (real(ifft(All_W)));
white(find(abs(white)==max(abs(white))))=...
    white(find(white==max(white))+1);
P=(white.*row./max(row));
new_re_PS(P,[],[])