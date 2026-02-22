%% SIGMA_get1.m
% # 役割
% `SIGMA_get.m` と同様に、PV予測誤差の標準偏差(σ)を計算しますが、
% こちらはより詳細な条件分岐やデータ保存機能を持っています。
% 特に、計算途中のデータを `時間粒度_気象分解能別予測誤差` フォルダに
% 保存する機能が特徴的です。
%
% # 実行方法
%
% ```matlab
% SIGMA_get1(year, mode1, mode2, mode3, PVC_bai)
% % (例: SIGMA_get1(2018, 1, 2, 1, 1.5))
% ```
%
% # パラメータ (`SIGMA_get.m` と同様)
%
% - `year`: 対象年
% - `mode1`: σの計算方法 (`1`: 出力別, `2`: 全体)
% - `mode2`: 期間の選択 (`1`: 月別, `2`: 季節別)
% - `mode3`: 具体的な月や季節
% - `PVC_bai`: PV導入量の倍率
%
% # 入力
%
% - `ERROR_YYYY.mat`: 予測誤差データ
% - `data_YYYY.mat`: 日付データ
%
% # 出力
%
% - `error_sigma.mat`: 計算されたσの値を保存したファイル。
% - `時間粒度_気象分解能別予測誤差\データ\PV*倍` フォルダ内に、
%   各時間断面での誤差データ (`時刻断面_*.mat`) が保存されます。
%
% # 内部処理
%
% - `mode1=1` の場合、`mode1_no_sigma1.m` をループで呼び出します。

function SIGMA_get1(year,mode1,mode2,mode3,PVC_bai)
% mode1:1-予測PV出力の大きさによってσを変化する場合
%      :2-予測PV出力の大きさによってσを変化しない場合
% mode2:1-月選択
  % mode3:1-月の選択(1~12)
% mode2:2-季節選択
  % mode3:季節の選択(1:春(4~6月)，1:夏(7~9月)，1:秋(10~12月)，1:冬(1~3月))
close all
cd C:\Users\PowerSystemLab\Desktop\01_研究資料\05_実行ファイル\予測PV出力誤差
load(['ERROR_',num2str(year),'.mat'])
load(['data_',num2str(year),'.mat'])
if mode1 ~= 1
    if ~exist('mode2', 'var') || isempty(mode2)
        name = ['時間断面ごとに365日分'];
    else
        if mode2 == 1
            row = find(data(:,2)==mode3);
            name = [num2str(mode3),'月'];
        elseif mode2 == 2
            if mode3 == 1
                row1 = find(data(:,2)==4);
                row2 = find(data(:,2)==5);
                row3 = find(data(:,2)==6);
                row = [row1;row2;row3];
                name = ['spring'];
            elseif mode3 == 2
                row1 = find(data(:,2)==7);
                row2 = find(data(:,2)==8);
                row3 = find(data(:,2)==9);
                row = [row1;row2;row3];
                name = ['summer'];
            elseif mode3 == 3
                row1 = find(data(:,2)==10);
                row2 = find(data(:,2)==11);
                row3 = find(data(:,2)==12);
                row = [row1;row2;row3];
                name = ['automm'];
            elseif mode3 == 4
                row1 = find(data(:,2)==1);
                row2 = find(data(:,2)==2);
                row3 = find(data(:,2)==3);
                row = [row1;row2;row3];
                name = ['winter'];
            end
        end
    end
end
S = [];all_num = [];
for i = 1:50
    if mode1 == 1
        mode1_no_sigma1
        S = [S;s1 s2 s3 s4 s5 s6 s7 s8 s9 s10];
        all_num = [all_num;l];
        save(['時刻断面_',num2str(i),'.mat'],'e1','e2','e3','e4','e5','e6','e7','e8','e9','e10')
        mkdir(['C:\Users\PowerSystemLab\Desktop\01_研究資料\05_実行ファイル\予測PV出力誤差\時間粒度_気象分解能別予測誤差\データ\PV',num2str(PVC_bai),'倍'])
        movefile(['時刻断面_',num2str(i),'.mat'],['C:\Users\PowerSystemLab\Desktop\01_研究資料\05_実行ファイル\予測PV出力誤差\時間粒度_気象分解能別予測誤差\データ\PV',num2str(PVC_bai),'倍'])
    else
        if ~exist('mode2', 'var') || isempty(mode2)
            %% 時間帯毎に365日分
            KAKURITUBU_BUNNPU(i,(ERROR(:,i)),'b',[-15:0.01:15],[],[])
        else
            %% 時間帯毎に季節or月の日にち分
            KAKURITUBU_BUNNPU(i,(ERROR(row,i)),'b',[-15:0.01:15],[],[])
        end
        global sigma_s sigma_e
        S = [S;sigma_s sigma_e];
    end
end
assignin('base','all_num',all_num);
% close(1:60)
% if mode1 == 1
%     figure('Name','予測PV出力の大きさでσを比較')
%     hold on
%     get_color
%     for i = 1:8
%         plot(S(:,i),'Color',color(i,:))
%     end
%     ylim([0 5])
%     legend(['~200'],['~400'],['~600'],['~800'],['~1000'],['~1200'],['~1400'],['~1600'])
% else
%     figure('Name',name)
%     hold on
%     bar(S(:,1),'b')
%     bar(S(:,2),'r')
%     ylim([-4 4])
% end
% sec_time_30min
cd('C:\Users\PowerSystemLab\Desktop\01_研究資料\05_実行ファイル\動的LFC容量決定手法')
error_sigma = S;
save('error_sigma.mat','error_sigma')
end