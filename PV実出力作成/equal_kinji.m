hantei = 0;m=0;l=0.01;
while hantei ~= 1
    m=m+1;
    maxfreq=1/2;
    freq=(1:n)/(n/2)*maxfreq;
    period0 = 1./freq;
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
    if m == 1
        white = (real(ifft(All_W)))./max(real(ifft(abs(All_W)))).*row./max(row);
    else
        white = (real(ifft(All_W)))./max(real(ifft(abs(All_W))));
    end
    %% 
    new_re_PS(white)
    num = (period1<10^((20.8)/10)).*(period1>=10^0.4);
    ne_liner(1,[period1(find(num==1))',...
        powerBiE_A(find(num==1))'])
    a22 = a2;b22 = b2;
    a2 = line.a;a2(isnan(a2))=[];
    b2 = line.b;
    if isempty(a2) == 1
        l = l + 0.01;
        a2 = a22;b2 = b22;
        hantei = abs(a1-a2) < l;
    else
        hantei = abs(a1-a2) < 0.01;
    end
end
hold on;loglog(period0,P_2_A/(10^(b2-b1)));loglog((10^(b2)*[1:1000].^(a2))/(10^(b2-b1)));
hold on;loglog(period0,P_2_A);loglog((10^(b2)*[1:1000].^(a2)));
close
% close