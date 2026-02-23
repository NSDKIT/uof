pl_ox = 0; % プロット有無係数
load('PV_1sec.mat')
PV_1sec=[PV_1sec(1800:end)',zeros(1,3600)];
save PV_1sec.mat PV_1sec
% %% 解析対象日のPV実績値の取得
% load('PV_1min.mat')
% %% 解析対象PV容量へ拡張
% load(['../PV_base_',num2str(year),'.mat'])
% Pv_out=PV_1min*PVC/PV_base(month);
% %% PVパネル設置方法の選択
% Pv_out=reshape(Pv_out,[1,length(Pv_out)]); % 配列の形状整理
% %% 実測値の拡張
% for n = 1:2 % 1回目: 要素数を拡張した時に，実測データが減少するから，その時の最大値を取得
%             % 2回目: 要素数を拡張した時の最大値から，実データと同じ規模に定数倍して，要素数を拡張する
%     %% 高速フーリエ変換によりフーリエ係数算出
%     if n == 1
%         fft_BiE=fft(Pv_out);
%     elseif n == 2
%         fft_BiE=fft(Pv_out*max(Pv_out)/max(row));
%     end
%     n=length(Pv_out);
%     %% 周波数領域でのリニアスペクトル，パワースペクトル算出
%     powerBiE_L = (abs(fft_BiE(1:floor(n/2)))); %リニアスペクトル
%     powerBiE_A = (abs(fft_BiE(1:floor(n/2)))).^2; %実測データのパワースペクトル
%     %% 周期配列の作成
%     maxfreq=1/120;freq=(1:n/2)/(n/2)*maxfreq; %半分の周波数
%     period1 = 1./freq; %半分の周期
%     %% 実測値のフーリエ係数の拡張
%     N=60*60*24; %sec*min*day 1日の秒数
%     T =60;      %60sec, サンプリング周期
%     All_BiE=zeros(N,1); %空の配列
%     All_BiE(1:N/(2*T))=fft_BiE(1:length(fft_BiE)/2); %実測データ代入
%     All_BiE(length(All_BiE)-(N/(2*T))+1:end)=fft_BiE(length(fft_BiE)/2+1:end); %実測データ代入
%     %% 実績値の作成(逆フーリエ変換)
%     row = real(ifft(All_BiE));
%     row = reshape(row,[1,length(row)]);
% end
% %% 近似直線作成
% ne_liner(1,log10([period1(1:end/2)',powerBiE_A(1:end/2)']),'b',[1,10^4],[1,10^8])
% a1 = line.a;b1 = line.b;
% % プロットで確認
% if pl_ox == 1
%     figure,loglog(period1,powerBiE_A)
%     hold on
%     loglog(10^(b1)*[1:1000].^(a1))
% end
% %% ホワイトイズ作成
% rng('default');rng(1);R=rand(1,86400);
% r = (R-0.5)/sqrt(PVC/PV_base(month));
% n=length(r);
% fft_r=fft(r); %高速フーリエ変換→フーリエ係数
% P_2_L = (abs(fft_r(1:floor(n/2)))); %リニアスペクトル
% P_2_A = (abs(fft_r(1:floor(n/2)))).^2; %ホワイトノイズのパワースペクトル
% maxfreq=1/2;freq=(1:n/2)/(n/2)*maxfreq; %半分の周波数
% period = 1./freq; %半分の周期
% %% 近似直線作成
% % 実測値と近い周期(60秒から120秒まで)で近似直線を取る
% num = (period<120).*(period>=60);
% ne_liner(1,log10([period(find(num==1))',P_2_A(find(num==1))']))
% a2 = line.a;b2 = line.b;
% % 切片を更新して，再度近似直線作成
% % P = P_2_A/10^(b2-b1);
% % ne_liner(1,log10([period(find(num==1))',P(find(num==1))']))
% % a2 = line.a;b2 = line.b;
% %% 近似直線の傾きを等しくするための繰り返しコマンド
% equal_kinji
% %% 短周期変動の作成(逆フーリエ変換)
% load('PVC.mat')
% fugou = sign(fft_r);
% white = real(ifft((fugou.*sqrt(P_2_A/sqrt(PVC/1010)/(10^(b2-b1)))))); 
% %% 短周期変動を考慮したPV出力の作成
% PV_1sec = white+row;
% PV_1sec(PV_1sec<0.001) = 0;
% % プロットで確認
% if pl_ox == 1
%     re_PS(PV_1sec,[],[])
%     figure,plot(PV_1sec);hold on;plot(row)
% end
% PV_1sec=[PV_1sec(1801:end),zeros(1,3600)];
% save PV_1sec.mat PV_1sec