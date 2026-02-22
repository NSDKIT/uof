%% SIGMA_get.m
% # 役割
% PV予測誤差の標準偏差(σ, シグマ)を計算するためのメインスクリプト。
% 様々なモード(`mode1`, `mode2`, `mode3`)に応じて、計算条件を切り替えることができます。
%
% # 実行方法
%
% ```matlab
% SIGMA_get(year, mode1, mode2, mode3, PVC_bai)
% % (例: SIGMA_get(2018, 1, 2, 1, 1.5))
% ```
%
% # パラメータ
%
% - `year`: 対象年 (例: 2018)
% - `mode1`: σの計算方法
%   - `1`: 予測PV出力の大きさ別にσを計算 (`mode1_no_sigma.m` を使用)
%   - `2`: 予測PV出力の大きさによらず、全体のσを計算
% - `mode2`: 期間の選択
%   - `1`: 月別
%   - `2`: 季節別
% - `mode3`: `mode2`で選択した具体的な月や季節
% - `PVC_bai`: PV導入量の倍率
%
% # 入力
%
% - `ERROR_YYYY.mat`: 予測誤差データ
% - `data_YYYY.mat`: 日付データ
%
% # 出力
%
% - `error_sigma.mat`: 計算されたσの値を保存したファイル。(注: `'動的LFC容量決定手法'` フォルダに保存される)
% - 複数のプロット図
%
% # 内部処理
%
% - `mode1=1` の場合、`mode1_no_sigma.m` をループで呼び出します。
% - `KAKURITUBU_BUNNPU.m` を使用して確率分布を計算・描画します。

function SIGMA_get(year,mode1,mode2,mode3,PVC_bai)
% mode1:1-予測PV出力の大きさによってσを変化する場合
%      :2-予測PV出力の大きさによってσを変化しない場合
% mode2:1-月選択
  % mode3:1-月の選択(1~12)
% mode2:2-季節選択
  % mode3:季節の選択(1:春(4~6月)，1:夏(7~9月)，1:秋(10~12月)，1:冬(1~3月))
close all
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
S = [];
all_num = [];
for i = 1:50
    if mode1 == 1
        mode1_no_sigma
        S = [S;s_e1-s_s1 s_e2-s_s2 s_e3-s_s3 s_e4-s_s4 s_e5-s_s5 s_e6-s_s6 s_e7-s_s7 s_e8-s_s8];
%         all_num = [all_num;e_l1 e_l2 e_l3 e_l4 e_l5];
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
% close(1:60)
if mode1 == 1
    figure('Name','予測PV出力の大きさでσを比較')
    hold on
    get_color
    for i = 1:8
        plot(S(:,i),'Color',color(i,:))
    end
    ylim([0 5])
    legend(['~200'],['~400'],['~600'],['~800'],['~1000'])
else
    figure('Name',name)
    hold on
    bar(S(:,1),'b')
    bar(S(:,2),'r')
    ylim([-4 4])
end
sec_time_30min
cd('C:\Users\PowerSystemLab\Desktop\01_研究資料\05_実行ファイル\動的LFC容量決定手法')
error_sigma = S;
save('error_sigma.mat','error_sigma')
end