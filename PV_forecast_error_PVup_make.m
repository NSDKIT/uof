%% =========================================================
%  PV_forecast_error_PVup_make.m  ―  容量別・日別予測誤差ファイルの生成
%  =========================================================
%
%  【役割】
%    基準PV導入量での予測誤差（ERROR_YYYY.mat）を基に、
%    PV導入量が「基準値〜基準値の4倍」まで変化した場合の誤差を計算し、
%    日付ごとに個別の .mat ファイルとして保存する。
%    将来のPV導入量増加シナリオを見据えた分析に使用する。
%
%  【実行方法】
%    >> PV_forecast_error_PVup_make(2018)
%    >> PV_forecast_error_PVup_make(2019)
%
%  【前提条件（先に実行しておくこと）】
%    PV_forecast_error_make(year)  → ERROR_YYYY.mat が存在すること
%
%  【入力ファイル（事前に同フォルダへ配置すること）】
%    ┌──────────────────────────┬──────────────────────────────────────┐
%    │ ファイル名               │ 内容                                 │
%    ├──────────────────────────┼──────────────────────────────────────┤
%    │ ERROR_YYYY.mat           │ 基準PV導入量での予測誤差（PV_forecast_error_makeで生成）│
%    │ data_YYYY.mat            │ 日付配列                             │
%    │ PV_capa_YYYY.mat         │ 各月の基準PV導入容量 [MW]            │
%    └──────────────────────────┴──────────────────────────────────────┘
%
%  【出力ファイル】
%    予測PV出力誤差_YYYY フォルダ内に以下のファイルが生成される:
%      ERRORyyyymmdd.mat  （例: ERROR20180601.mat）
%        ・変数 ERROR: [48行 × 容量ステップ数列]
%        ・行: 時間断面（30分×48コマ）
%        ・列: PV導入量（基準値から20MW刻みで4倍まで）
%
%  【次のステップ（このファイルを使う処理）】
%    → PV_forecast_error_bar_make.m  （日別誤差の棒グラフ可視化）
%    → PV_compare.m                  （予測と実績の比較可視化）
%
%  【依存する関数】
%    chose_data(year, month, day)  ← 同フォルダ内の chose_data.m
%      → 日付から data 配列の行番号（通算日）を取得するユーティリティ
%
%  【注意事項】
%    - 出力先フォルダ「予測PV出力誤差_YYYY」は事前に作成しておくこと。
%      （存在しない場合 movefile がエラーになる）
%    - 1月〜3月のデータは year+1 として扱われる（4月始まり年度のため）。
%    - chose_data.m 内に絶対パスがハードコーディングされているため、
%      実行環境に合わせてパスを修正すること（詳細は chose_data.m 参照）。
% =========================================================

function PV_forecast_error_PVup_make(year)

year1 = year;  % 元の年度を保持（1〜3月処理で year を上書きするため）

%% --- データ読み込み ---
load(['ERROR_',num2str(year),'.mat'])    % 変数: ERROR   → 基準PV導入量での予測誤差
ERROR1 = ERROR;
load(['data_',num2str(year),'.mat'])     % 変数: data    → 日付配列
load(['PV_capa_',num2str(year),'.mat'])  % 変数: PV_capa → 各月の基準PV導入容量 [MW]

%% --- 月順序の定義（4月始まり） ---
M = [4:12 1:3];

%% --- 月ごと・日ごとに容量別誤差を計算して保存 ---
for i = 1:12
    month = M(i);
    a = find(data(:,2)==month);   % 当月の行番号を取得
    ERROR2 = ERROR1(a,:);         % 当月分の誤差を抽出

    for day = 1:length(a)
        E = ERROR2(day,:);        % 当日の誤差（1行×50列）

        % PV導入量を基準値〜4倍まで20MW刻みで変化させ、各導入量での誤差を計算
        % 列方向に導入量ステップが並ぶ行列 EEE を構築
        EEE = [];
        for PVC = PV_capa(i) : 20 : PV_capa(i)*4
            % 絶対誤差 [MW] = 誤差率 × (PVC / 基準容量)
            EEE = [EEE, abs(E' * PVC / PV_capa(i))];
        end
        ERROR = EEE;

        % 日付の行番号を取得（chose_data はグローバル変数 a_day に結果を返す）
        chose_data(year1, month, day)
        global a_day
        d = data(a_day,:);  % d = [年, 月, 日, ...]

        % 1〜3月は翌年扱い（4月始まり年度のため）
        if d(2) < 4
            year = year1 + 1;
        else
            year = year1;
        end

        % ファイル名: ERRORyyyymmdd.mat（例: ERROR20180601.mat）
        save(['ERROR', num2str(year), num2str(d(2)), num2str(d(3)), '.mat'], 'ERROR')

        % 生成したファイルを専用フォルダへ移動
        movefile(['ERROR', num2str(year), '*'], ['予測PV出力誤差_', num2str(year1)])
    end
end

end
