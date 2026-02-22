%% =========================================================
%  step6_calc_lfc_capacity.m  ―  動的LFC必要容量の計算
%  =========================================================
%
%  【役割】
%    PV予測出力と負荷予測から、動的に必要なLFC（負荷周波数制御）容量を
%    30分ごとに計算し、.mat ファイルとして保存する。
%
%  【実行方法】
%    >> step6_calc_lfc_capacity(2018, 6, 15, 1.0)   % 2018年6月15日・基準PV導入量
%    >> step6_calc_lfc_capacity(2018, 8, 1, 1.5)    % 2018年8月1日・PV1.5倍
%
%  【フォルダ構成の前提】
%    このスクリプトは deploy/ フォルダをカレントディレクトリとして実行する。
%    入力ファイルは input_data/ に、出力は output/動的LFC容量決定手法/ に保存される。
%
%  【パラメータ説明】
%    year   : 対象年（例: 2018）
%    month  : 対象月（例: 6）
%    day    : 対象日（例: 15）
%    PV_bai : PV導入量の倍率（例: 1.0=基準, 1.5=1.5倍）
%
%  【入力ファイル（input_data/ フォルダに配置すること）】
%    ┌──────────────────────────────┬──────────────────────────────────────┐
%    │ ファイル名                   │ 内容                                 │
%    ├──────────────────────────────┼──────────────────────────────────────┤
%    │ input_data/douteki_lfc_ab.mat│ LFC容量計算の係数（傾き a と切片 b） │
%    │ input_data/new_ave_PV.mat    │ 平均的なPV出力カーブ（48点）         │
%    │ input_data/new_ave_load.mat  │ 平均的な負荷カーブ（48点）           │
%    └──────────────────────────────┴──────────────────────────────────────┘
%
%  【出力ファイル（output/動的LFC容量決定手法/ フォルダに保存される）】
%    LFC_amount_yyyymmdd.mat
%      ・変数 LFC_amount: 30分ごとのLFC必要量 [MW]（50点）
%      ・上限: 10MW、下限: 2MW（2MW未満は2MWに切り上げ）
%
%  【LFC容量の計算式】
%    L(t) = a(t) × (PV予測出力(t) / 負荷予測(t)) × 100 × PV_bai + b(t)
%    ・a(t)=0 の時間帯は L=0
%    ・2MW 未満 → 2MW に切り上げ
%    ・10MW 超  → 10MW に切り上げ（上限）
%
%  【次のステップ（このファイルを使う処理）】
%    → output/動的LFC容量決定手法/ フォルダ内のシミュレーションスクリプト
% =========================================================

function step6_calc_lfc_capacity(year, month, day, PV_bai)

%% --- LFC係数の読み込み（相対パス: input_data フォルダ） ---
load(fullfile('input_data', 'douteki_lfc_ab.mat'))
% 変数: ab → [50行×2列]（1列目: 傾き a, 2列目: 切片 b）

%% --- 平均PV出力・負荷カーブの読み込み（相対パス: input_data フォルダ） ---
load(fullfile('input_data', 'new_ave_PV.mat'))       % 変数: new_ave_PV   → 平均的なPV出力カーブ（48点）
load(fullfile('input_data', 'new_ave_load.mat'))     % 変数: new_ave_load → 平均的な負荷カーブ（48点）

%% --- 平均カーブを使用（特定日のデータは現在コメントアウト中） ---
% 特定日のデータを使う場合は以下をコメントアウト解除:
% util_get_row_index_by_date(year, month, day)
% global a_day
% PV_f = data_all(a_day,:);
PV_f = new_ave_PV;    % 平均PV出力カーブを使用
L_f  = new_ave_load;  % 平均負荷カーブを使用

%% --- 30分ごとにLFC必要容量を計算 ---
% 計算式: L(t) = a(t) × (PV(t)/負荷(t)) × 100 × PV_bai + b(t)
L = [];
for t = 1:48
    if ab(t,1) == 0
        L = [L; 0];  % 係数 a=0 の時間帯はLFC=0
    else
        L = [L; ab(t,1) * PV_f(t) / L_f(t) * 100 * PV_bai + ab(t,2)];
    end
end
L = [L; 0; 0];  % 末尾に2点追加して50点に統一

%% --- LFC容量の上下限処理 ---
% 下限: 2MW 未満は 2MW に切り上げ
lfc_2 = (L < 2) * 2;

% 上限: 10MW 超は 10MW に切り上げ
l_10 = (L >= 2) .* (L) >= 10;
l    = (lfc_2 + (L >= 2) .* (L)) < 10;
lfc_10 = l_10 * 10;

% 最終的なLFC必要量 [MW]
LFC_amount = (lfc_2 + ((L) >= 2) .* (L)) .* l + lfc_10;

%% --- 結果の保存（相対パス: output/動的LFC容量決定手法/ フォルダ） ---
out_dir = fullfile('output', '動的LFC容量決定手法');
if ~exist(out_dir, 'dir')
    mkdir(out_dir)
end
filename = ['LFC_amount_', num2str(year), num2str(month,'%02d'), num2str(day,'%02d'), '.mat'];
save(fullfile(out_dir, filename), 'LFC_amount')
% → 保存先: output/動的LFC容量決定手法/LFC_amount_yyyymmdd.mat

end
