# PV予測誤差分析ツール — deploy パッケージ

このフォルダを他の人に渡すだけで、**どの環境でもそのまま実行できる**パッケージです。

---

## クイックスタート

### 1. 事前準備

1. **このフォルダ (`deploy/`) をどこかに配置する**（例: `C:\Users\yourname\PV_analysis\deploy\`）
2. **`input_data/` フォルダに必要なデータを配置する**（後述の「必要な入力ファイル一覧」を参照）

### 2. MATLABで実行

```matlab
% MATLABのカレントディレクトリを deploy/ フォルダに設定する
cd('C:\Users\yourname\PV_analysis\deploy')

% 全処理を一括実行
main_run
```

これだけで全処理が順番に実行され、結果が `output/` フォルダに保存されます。

---

## フォルダ構成

```
deploy/
├── main_run.m                                   ← ★ エントリーポイント（ここを実行）
│
├── input_data/                                  ← 入力データを配置するフォルダ
│   ├── data_2018.mat                            ← 日付配列
│   ├── PV_base_2018.mat                         ← 基準PV導入量
│   └── ...（詳細は下記参照）
│
├── output/                                      ← 実行結果が自動的に保存されるフォルダ
│   ├── PV_forecast_YYYY.mat                     ← Step 1 の出力
│   ├── PV_YYYY.mat                              ← Step 2 の出力
│   ├── ERROR_YYYY.mat                           ← Step 3 の出力
│   ├── 予測PV出力誤差/                           ← Step 4 の出力
│   ├── 動的LFC容量決定手法/                      ← Step 5, 6 の出力
│   └── 時間粒度_気象分解能別予測誤差/             ← Step 5 (拡張版) の出力
│
│  【メイン処理 — 実行順序どおりに番号付き】
├── step1_generate_pv_forecast.m                 ← Step 1: 予測PV出力の生成
├── step2_generate_pv_actual.m                   ← Step 2: 実績PV出力の生成
├── step3_calc_forecast_error.m                  ← Step 3: 予測誤差の計算
├── step4_calc_error_by_capacity.m               ← Step 4: 容量別・日別誤差の生成
├── step5_calc_sigma_basic.m                     ← Step 5: σ計算（基本版）
├── step5_calc_sigma_by_output_band.m            ← Step 5: σ計算（出力帯域別・拡張版）
├── step6_calc_lfc_capacity.m                    ← Step 6: 動的LFC必要容量の計算
│
│  【ユーティリティ関数 — 他スクリプトから呼び出される】
├── util_get_row_index_by_date.m                 ← 日付→行番号変換
├── util_calc_sigma_per_band_basic.m             ← step5_calc_sigma_basic の補助
├── util_calc_sigma_per_band_extended.m          ← step5_calc_sigma_by_output_band の補助
├── util_fit_normal_distribution.m               ← 正規分布フィッティング・PDF描画
├── util_fit_normal_distribution_extended.m      ← 同上の拡張版（ヒストグラム重ね表示対応）
├── util_downsample_to_30min.m                   ← 1分→30分間隔へのダウンサンプリング
├── util_get_plot_colors.m                       ← グラフ描画用カラーパレット定義
├── util_set_xaxis_time_labels.m                 ← グラフX軸の時刻ラベル設定
│
│  【可視化スクリプト — 個別に実行して結果を確認】
├── viz_compare_forecast_vs_actual.m             ← 予測と実績の比較グラフ
├── viz_plot_error_bar_by_day.m                  ← 日別誤差の棒グラフ
├── viz_plot_actual_output_by_day.m              ← 特定日のPV実績出力グラフ
│
│  【評価スクリプト — 個別に実行して精度を確認】
├── eval_forecast_accuracy_boxplot.m             ← 予測精度の評価（箱ひげ図）
└── eval_calc_monthly_rmse.m                     ← 月別RMSE計算
```

---

## 必要な入力ファイル一覧

`input_data/` フォルダに以下のファイルを配置してください。

### 年度別ファイル（YYYY = 2018, 2019 など）

| ファイル名 | 内容 | 使用するスクリプト |
|:---|:---|:---|
| `data_YYYY.mat` | 日付配列 `[年, 月, 日, ...]` | 全スクリプト |
| `PV_base_YYYY.mat` | 各月の基準PV導入量 [MW] | step1, step3 |
| `PR_YYYY.mat` | 各月のシステム性能係数 | step1 |
| `Radiation_fcst_YYYY.mat` | 予測日射量 [W/m²] | step1 |
| `PV_capa_YYYY.mat` | 各月の実際のPV導入容量 [MW] | step2, step4 |
| `Pv_real_out_YYYY.mat` | 補正前のPV実績出力（1分間隔） | step2, viz_plot_actual_output_by_day |
| `Load_YYYY.mat` | 電力需要 [MW] | step3, viz_compare_forecast_vs_actual |

### 固定ファイル（年度によらず1つ）

| ファイル名 | 内容 | 使用するスクリプト |
|:---|:---|:---|
| `douteki_lfc_ab.mat` | LFC容量計算の回帰係数 (a, b) | step6 |
| `new_ave_PV.mat` | 平均的なPV出力カーブ（48点） | step6 |
| `new_ave_load.mat` | 平均的な負荷カーブ（48点） | step6 |
| `PVC.mat` | PV設備容量 [MW] | util_calc_sigma_per_band_extended |
| `time_label.mat` | 時刻ラベル（グラフ表示用） | util_calc_sigma_per_band_basic, util_calc_sigma_per_band_extended |

> `YYYY` は年度（例: 2018, 2019）に置き換えてください。  
> 詳細は `input_data/README_input_data.md` を参照してください。

---

## 処理フロー

```
input_data/
    data_YYYY.mat
    PV_base_YYYY.mat
    PR_YYYY.mat
    Radiation_fcst_YYYY.mat
         │
         ▼
[Step 1] step1_generate_pv_forecast(year)
         │
         └──→ output/PV_forecast_YYYY.mat

input_data/
    PV_capa_YYYY.mat
    Pv_real_out_YYYY.mat
         │
         ▼
[Step 2] step2_generate_pv_actual(year)
         │
         └──→ output/PV_YYYY.mat

output/PV_forecast_YYYY.mat
output/PV_YYYY.mat
input_data/Load_YYYY.mat
         │
         ▼
[Step 3] step3_calc_forecast_error(year)
         │
         └──→ output/ERROR_YYYY.mat

output/ERROR_YYYY.mat
         │
         ▼
[Step 4] step4_calc_error_by_capacity(year)
         │
         └──→ output/予測PV出力誤差/ERRORyyyymmdd.mat

output/ERROR_YYYY.mat
         │
         ▼
[Step 5] step5_calc_sigma_by_output_band(year, 1, [], [], PVC_bai)
         │
         └──→ output/動的LFC容量決定手法/error_sigma.mat
         └──→ output/時間粒度_気象分解能別予測誤差/データ/PV*倍/時刻断面_i.mat

input_data/douteki_lfc_ab.mat
input_data/new_ave_PV.mat
input_data/new_ave_load.mat
         │
         ▼
[Step 6] step6_calc_lfc_capacity(year, month, day, PVC_bai)
         │
         └──→ output/動的LFC容量決定手法/LFC_amount_yyyymmdd.mat
```

---

## 個別スクリプトの実行例

全処理が完了した後、以下のスクリプトで可視化・評価が可能です。

```matlab
% 2018年6月のPV予測と実績を比較するグラフ
viz_compare_forecast_vs_actual(2018, 6, 1.0)

% 2018年6月の日別誤差棒グラフ（基準容量）
viz_plot_error_bar_by_day(2018, 6, 1)

% 予測精度の評価（箱ひげ図）
eval_forecast_accuracy_boxplot

% 月別RMSE計算
eval_calc_monthly_rmse

% 特定日のPV実績出力確認
viz_plot_actual_output_by_day(2018)
```

---

## よくあるエラーと対処法

| エラーメッセージ | 原因 | 対処法 |
|:---|:---|:---|
| `input_data フォルダが見つかりません` | カレントディレクトリが違う | `cd('deploy/')` を実行 |
| `ファイルが見つかりません (data_2018.mat)` | input_data にファイルがない | `input_data/` にファイルを配置 |
| `未定義の関数 'util_downsample_to_30min'` | deploy/ フォルダがパスにない | MATLABのカレントディレクトリを `deploy/` に設定 |
| `変数 'ERROR' が未定義` | Step 3 が未実行 | `step3_calc_forecast_error(year)` を先に実行 |
| `変数 'data_all' が未定義` | Step 1 または Step 2 が未実行 | `main_run` で最初から実行し直す |
