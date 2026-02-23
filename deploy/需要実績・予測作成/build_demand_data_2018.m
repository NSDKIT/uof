pl_ox = 0; % プロット有無係数
Year = year;Month = month;Day = day;
clear day
%% 北陸エリアPV出力実測値の抽出
Demand_real=csv_tieline_PV2018(fullfile(ROOT_DIR, '需要実績・予測作成', '北陸山元2018.xlsx'));
Demand_real=table2array(Demand_real(2:end,3));
Demand_real(isnan(Demand_real))=[];
%% 日付番号の取得
t_331 = datetime(Year,3,31);dn = day(t_331,'dayofyear'); %3月31日の日付番号を取得
t_target = datetime(Year,Month,Day);dn = day(t_target,'dayofyear')-dn; %解析対象日の日付番号を取得
%% 解析対象日の需要実績値の取得
Demand_own=Demand_real(1440*(dn-1)+1:1440*dn+60,:);
Demand_30=Demand_real(1440*(dn-1)+1:1440*(dn)+61,:); %後30分平均値用のデータ抽出
Demand_own=reshape(Demand_own,[1,length(Demand_own)]);
Demand_30=reshape(Demand_30,[1,length(Demand_30)]);
%% 30分平均値作成
A30 = Demand_30(1);
for i = 1:49
    a30 = mean(Demand_30(30*(i-1)+1:30*i));
    A30 = [A30;a30];
end
%% 実測値の拡張
for n = 1:2 % 1回目: 要素数を拡張した時に，実測データが減少するから，その時の最大値を取得
            % 2回目: 要素数を拡張した時の最大値から，実データと同じ規模に定数倍して，要素数を拡張する
    %% 高速フーリエ変換によりフーリエ係数算出
    if n == 1
        fft_BiE=fft(Demand_own);
    elseif n == 2
        fft_BiE=fft(Demand_own*max(Demand_own)/max(row));
    end
    n=length(Demand_own);
    %% 周波数領域でのリニアスペクトル，パワースペクトル算出
    powerBiE_L = (abs(fft_BiE(1:floor(n/2)))); %リニアスペクトル
    powerBiE_A = (abs(fft_BiE(1:floor(n/2)))).^2; %実測データのパワースペクトル
    %% 周期配列の作成
    maxfreq=1/120;freq=(1:n/2)/(n/2)*maxfreq; %半分の周波数
    period1 = 1./freq; %半分の周期
    %% 実測値のフーリエ係数の拡張
    N=60*60*24+1800*2; %sec*min*day 1日の秒数
    T =60;      %60sec, サンプリング周期
    All_BiE=zeros(N,1); %空の配列
    All_BiE(1:N/(2*T))=fft_BiE(1:length(fft_BiE)/2); %実測データ代入
    All_BiE(length(All_BiE)-(N/(2*T))+1:end)=fft_BiE(length(fft_BiE)/2+1:end); %実測データ代入
    %% 実績値の作成(逆フーリエ変換)
    row = real(ifft(All_BiE));
    row = reshape(row,[1,length(row)]);
end
%% 近似直線作成
num = (period1>=120).*(period1<3600);
ne_liner(1,log10([period1(find(num==1))',powerBiE_A(find(num==1))']),'b',[1,10^4],[1,10^8])
a1 = line.a;b1 = line.b;
% プロットで確認
if pl_ox == 1
    figure,loglog(period1,powerBiE_A)
    hold on
    loglog(10^(b1)*[1:1000].^(a1))
end
%% ホワイトイズ作成
%     rng('default');rng(1);R=rand(1,86400+1800*2);
%     r = (R-0.5);
%     n=length(r);
%     fft_r=fft(r); %高速フーリエ変換→フーリエ係数
%     P_2_L = (abs(fft_r(1:floor(n/2)))); %リニアスペクトル
%     P_2_A = (abs(fft_r(1:floor(n/2)))).^2; %ホワイトノイズのパワースペクトル
%     maxfreq=1/2;freq=(1:n/2)/(n/2)*maxfreq; %半分の周波数
%     period = 1./freq; %半分の周期
%     %% 近似直線作成
%     % 実測値と近い周期(60秒から120秒まで)で近似直線を取る
%     num = (period<120).*(period>=60);
%     ne_liner(1,log10([period(find(num==1))',P_2_A(find(num==1))']))
%     a2 = line.a;b2 = line.b;
%     % 切片を更新して，再度近似直線作成
%     P = P_2_A/10^(b2-b1);
%     ne_liner(1,log10([period(find(num==1))',P(find(num==1))']))
%     a2 = line.a;b2 = line.b;
%% 近似直線の傾きを等しくするための繰り返しコマンド
%     equal_kinji
%     %% 短周期変動の作成(逆フーリエ変換)
%     load('PVC.mat')
%     fugou = sign(fft_r);
%     white = real(ifft((fugou.*sqrt(P_2_A/sqrt(PVC/1010)/(10^(b2-b1)))))); 
%% 短周期変動を考慮したPV出力の作成
demand_1sec = row;
% demand_1sec = white+row;
demand_1sec(demand_1sec<0.001) = 0;
% プロットで確認
if pl_ox == 1
    re_PS(demand_1sec,[],[])
    figure,plot(demand_1sec);hold on;plot(row)
end
%% 需要予測作成(間引き：load_forecast_30min)
demand_30min = demand_1sec(1);
for t =  1:49
    demand_30min = [demand_30min;mean(demand_1sec(1800*t-900:1800*t+900))]; %1秒データの配列(30分窓抽出)
end
save demand_30min.mat demand_30min    
save demand_1sec.mat demand_1sec