%% PV_real_form.m
% # 役割
% 指定した年のPV「実績」出力データ(`Pv_real_out_YYYY.mat`)を月ごとに読み込み、
% 特定の日(スクリプト内でハードコーディング)の最大値を棒グラフで可視化します。
%
% 天候が悪かった日などを特定するために使用されると考えられます。
%
% # 実行方法
%
% ```matlab
% PV_real_form(year0)
% % (例: PV_real_form(2018))
% ```
%
% # パラメータ
%
% - `year0`: 対象年 (例: 2018)
%
% # 入力
%
% - `Pv_real_out_YYYY.mat`: PV実績出力データ
% - `data_YYYY.mat`: 日付データ
%
% # 出力
%
% - 12個のFigureウィンドウ。それぞれが各月に対応し、
%   指定された日の最大PV出力が棒グラフで表示されます。
%
% # 注意
%
% - 可視化対象の日付(変数`aa`)がスクリプト内に直接書き込まれており、固定です。
% - グラフの描画が `'bar'` になっているため、1日の出力カーブではなく最大値のみが表示されます。

function PV_real_form(year0)
close all
load(['Pv_real_out_',num2str(year0),'.mat'])
load(['data_',num2str(year0),'.mat'])
M = [4 5 6 7 8 9 10 11 12 1 2 3];
aa=[6,16,20,1,1,1,1,1,1
3,4,7,8,23,24,25,29,1
3,13,25,1,1,1,1,1,1
17,26,31,1,1,1,1,1,1
2,3,4,5,8,10,11,18,26
8,9,15,1,1,1,1,1,1
9,10,31,1,1,1,1,1,1
2,5,6,12,21,23,1,1,1
9,16,25,1,1,1,1,1,1
11,6,10,1,1,1,1,1,1
11,24,1,1,1,1,1,1,1
9,12,18,19,23,25,26,1,1
];
for m = 1:12
    month = M(m);
    if month < 4
        year = year0+1;
    else
        year = year0;
    end
    if month == 2
        if year == 2019
            L_D = 28;
        elseif year == 2020
            L_D = 29;
        end
    elseif month == 4 || month == 6 || month == 9 || month == 11
        L_D = 30;
    else
        L_D = 31;
    end
    a = data((find(data(:,2)==month)),:);
    aaa = aa(m,:);
    for ii = 1:9
        day = aaa(ii);
        b = a((find(a(:,3)==day)),:);
        figure(month)
        hold on
        subplot(5,7,day)
%         plot(Pv_real_out(b(1),:))
        bar(max(Pv_real_out(b(1),:)))
    end
end
end