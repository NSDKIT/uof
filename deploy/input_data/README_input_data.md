# input_data/ フォルダ — 必要なファイル一覧

このフォルダに以下のファイルを配置してください。  
**ファイルが不足していると、対応するスクリプトがエラーで停止します。**

---

## ファイル一覧

### 年度別ファイル（YYYY = 2018, 2019 など）

| ファイル名 | 内容 | 使用するスクリプト |
|:---|:---|:---|
| `data_YYYY.mat` | 日付配列 `[年, 月, 日, ...]` | 全スクリプト |
| `PV_base_YYYY.mat` | 各月の基準PV導入量 [MW] | `step1`, `step3` |
| `PR_YYYY.mat` | 各月のシステム性能係数 | `step1` |
| `Radiation_fcst_YYYY.mat` | 予測日射量 [W/m²] | `step1` |
| `PV_capa_YYYY.mat` | 各月の実際のPV導入容量 [MW] | `step2`, `step4` |
| `Pv_real_out_YYYY.mat` | 補正前のPV実績出力（1分間隔） | `step2`, `viz_plot_actual_output_by_day` |
| `Load_YYYY.mat` | 電力需要 [MW] | `step3`, `viz_compare_forecast_vs_actual` |

### 固定ファイル（年度によらず1つ）

| ファイル名 | 内容 | 使用するスクリプト |
|:---|:---|:---|
| `PVC.mat` | PV設備容量 [MW] | `util_calc_sigma_per_band_extended`（`step5`拡張版の補助） |
| `time_label.mat` | 時刻ラベル（グラフ表示用） | `util_calc_sigma_per_band_*` |

### 近似直線ファイル（LFC容量計算用）

`input_data/approximation_lines/` フォルダに、以下の構造で配置します。

```
approximation_lines/
├── 2018_5/   kinnji_data_20185_LFC_2%.mat 〜 LFC_10%.mat  （春季用）
├── 2018_8/   kinnji_data_20188_LFC_2%.mat 〜 LFC_10%.mat  （夏季用）
├── 2018_11/  kinnji_data_201811_LFC_2%.mat 〜 LFC_10%.mat （秋季用）
└── 2019_1/   kinnji_data_20191_LFC_2%.mat 〜 LFC_10%.mat  （冬季用）
```

| ファイルパス | 内容 | 使用するスクリプト |
|:---|:---|:---|
| `approximation_lines/{year}_{month}/kinnji_data_*_LFC_{i}%.mat` | LFC容量 `i` [%] のきの近似直線の傾き `a` と切片 `b` | `step6_calc_lfc_capacity` |

> `step6` は計算対象の月に応じて、季節に対応するフォルダを自動的に選択します。

---

## 各ファイルの詳細

- **`PVC.mat`**: `step5_calc_sigma_by_output_band`（拡張版）でPV出力帯域の幅（`PVC/5`）を計算するために使用します。`step5_calc_sigma_basic`（基本版）では使いません。
- **`Pv_real_out_YYYY.mat`**: 1分間隔の生データです。`step2` 内で `util_downsample_to_30min` を使って30分間隔にダウンサンプリングされます。

> `YYYY` は年度（例: 2018, 2019）に置き換えてください。  
> `main_run.m` の冒頭にある `YEARS = [2018, 2019]` を変更することで、他の年度も処理できます。
