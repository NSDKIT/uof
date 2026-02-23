%% デバッグ用スクリプト - 最適化処理のエラー詳細を確認
clear; clc;

% 作業ディレクトリに移動
cd('C:\Users\PowerSystemLab\Desktop\01_研究資料\05_実行ファイル\program\全体実行')

% 必要なパスを追加
addpath(genpath('C:\Users\PowerSystemLab\Desktop\01_研究資料\01_matlab_mytool'))
fprintf('MATLABパスに01_matlab_mytoolを追加しました\n');

% 日付設定
year_l = 2019;
month_l = 8;
day_l = 28;
save('YMD.mat','year_l','month_l','day_l')

% 必要な設定
error_ox = 0;
save('error_ox.mat','error_ox')

meth_num = 2;  % 線形手法
save('meth_num.mat','meth_num')

sigma = 2;
save('sigma.mat','sigma')

mode = 1;  % 片面
save('mode.mat','mode')

lfc = 8;
save('lfclfc.mat','lfc')

PVC = 5300;
save('PVC.mat','PVC')

% 日付文字列の作成
start_date = datetime(2019, 4, 1);
end_date = datetime(2020, 3, 31);
date_range = start_date:end_date;
date_strings = datestr(date_range, 'yyyymmdd');
save('date_strings.mat','date_strings')

% DNの計算
YYYY = str2num(date_strings(:,1:4))==year_l;
MM = str2num(date_strings(:,5:6))==month_l;
DD = str2num(date_strings(:,7:8))==day_l;
DN = find(YYYY.*MM.*DD);

fprintf('DN = %d (日付インデックス)\n', DN);

% データの準備
if year_l==2020
    y=year_l-1;
else
    y=year_l;
end

fprintf('基本データの読み込み中...\n');
load(['基本データ/PV_base_',num2str(y),'.mat'])
PV_base=[PV_base(end-2:end,3)',PV_base(1:end-3,3)'];
load(['基本データ/PR_',num2str(y),'.mat'])
load(['基本データ/MSM_bai_',num2str(y),'.mat'])
load('基本データ/irr_fore_data.mat')
load('基本データ/D_1sec.mat')
load('基本データ/D_30min.mat')
load('基本データ/irr_mea_data.mat')

fprintf('予測PV出力の作成中...\n');
n_l=[1,mode];
PVF_30min_al=irr_fore_data(24*((DN-1)-1)+1:24*(DN-1),n_l(1))*MSM_bai(month_l)*PR(month_l)*PV_base(month_l)/1000;
PVF_30min_new=irr_fore_data(24*((DN-1)-1)+1:24*(DN-1),n_l(2))*MSM_bai(month_l)*PR(month_l)*PV_base(month_l)/1000;
PV_al=1100;
PVF_30min=PVF_30min_al*PV_al/PV_base(month_l)+PVF_30min_new*(PVC-PV_al)/PV_base(month_l);
x = 1:24;
xq_1min = 1:1/2:24;
PVF_30min = [interp1(x,PVF_30min,xq_1min),0,0,0];
PVF_30min(isnan(PVF_30min))=0;
save('PVF_30min.mat','PVF_30min')

fprintf('需要データの作成中...\n');
demand_1sec=D_1sec(DN,:)-500;
demand_30min=D_30min(DN,:)-500;
save('demand_30min.mat','demand_30min')
save('demand_1sec.mat','demand_1sec')

fprintf('PV実出力データの作成中...\n');
PV_1sec_al=irr_mea_data(86401*(DN-1):86401*DN,n_l(1))*PR(month_l)*PV_base(month_l)/1000;
PV_1sec_new=irr_mea_data(86401*(DN-1):86401*DN,n_l(2))*PR(month_l)*PV_base(month_l)/1000;
PV_1sec=PV_1sec_al*PV_al/PV_base(month_l)+PV_1sec_new*(PVC-PV_al)/PV_base(month_l);
save('PV_1sec.mat','PV_1sec')

fprintf('\n最適化処理を実行中...\n');
cd('UC立案/MATLAB')

try
    % 最適化を実行
    new_optimization
    fprintf('\n✓ 最適化が正常に完了しました！\n');
catch ME
    fprintf('\n✗ エラーが発生しました:\n');
    fprintf('エラーメッセージ: %s\n', ME.message);
    fprintf('\nエラー発生場所:\n');
    for k = 1:length(ME.stack)
        fprintf('  %s (行 %d)\n', ME.stack(k).name, ME.stack(k).line);
    end

    % 詳細なエラー情報
    fprintf('\nエラーの詳細:\n');
    fprintf('  識別子: %s\n', ME.identifier);
    if ~isempty(ME.cause)
        fprintf('  原因:\n');
        for c = 1:length(ME.cause)
            fprintf('    - %s\n', ME.cause{c}.message);
        end
    end
end

cd('../../')
fprintf('\n完了\n');
