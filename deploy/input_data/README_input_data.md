# input_data/ フォルダ — 必要なファイル一覧

このフォルダに以下のファイルを配置してください。  
**ファイルが不足していると、対応するスクリプトがエラーで停止します。**

---

## 年度別ファイル（YYYY = 2018, 2019 など）

以下のファイルは年度ごとに用意が必要です。

| ファイル名 | 変数名 | 内容・形式 | 使用するスクリプト |
|:---|:---|:---|:---|
| `data_YYYY.mat` | `data` | 日付配列 `[N行 × 列]`。各行が1日に対応し、2列目=月、3列目=日 | 全スクリプト（chose_data, PV_forecast_make, PV_make, PV_forecast_error_make, PV_forecast_error_PVup_make, SIGMA_get, SIGMA_get1, PV_real_form） |
| `PV_base_YYYY.mat` | `PV_base` | 各月の基準PV導入量 `[12×1]` または `[1×12]` [MW] | PV_forecast_make, PV_forecast_error_make |
| `PR_YYYY.mat` | `PR_value` | 各月のシステム性能係数（Performance Ratio）`[12×1]` | PV_forecast_make |
| `Radiation_fcst_YYYY.mat` | `data_all` | 予測日射量 `[365日 × 48点]` [W/m²]（30分間隔） | PV_forecast_make |
| `PV_capa_YYYY.mat` | `PV_capa` | 各月の実際のPV導入容量 `[12×1]` [MW] | PV_make, PV_forecast_error_PVup_make |
| `Pv_real_out_YYYY.mat` | `Pv_real_out` | 補正前のPV実績出力 `[365日 × 1440点]`（1分間隔） | PV_make, PV_real_form |
| `Load_YYYY.mat` | `data_all` | 電力需要 `[365日 × 48点]` [MW]（30分間隔） | PV_forecast_error_make, PV_compare |

---

## 固定ファイル（年度によらず1つだけ用意）

| ファイル名 | 変数名 | 内容・形式 | 使用するスクリプト |
|:---|:---|:---|:---|
| `douteki_lfc_ab.mat` | `ab` | LFC容量計算の係数 `[50行 × 2列]`（1列目: 傾き a、2列目: 切片 b） | douteki_LFC3 |
| `new_ave_PV.mat` | `new_ave_PV` | 平均的なPV出力カーブ `[48×1]` [MW]（30分間隔） | douteki_LFC3 |
| `new_ave_load.mat` | `new_ave_load` | 平均的な負荷カーブ `[48×1]` [MW]（30分間隔） | douteki_LFC3 |
| `PVC.mat` | `PVC` | PV設備容量（スカラー値）[MW] | mode1_no_sigma1（SIGMA_get1経由） |
| `time_label.mat` | `time_label` | 時刻ラベル（グラフのX軸表示用） | mode1_no_sigma, mode1_no_sigma1 |

---

## 各ファイルの詳細説明

### `data_YYYY.mat`
- **最重要ファイル**。ほぼ全スクリプトが参照する。
- 各行が1日に対応し、少なくとも `[年, 月, 日]` の3列が必要。
- `chose_data(year, month, day)` はこのファイルを使って「指定した日が何行目か」を返す。

### `PV_base_YYYY.mat`
- 月ごとの基準PV導入量（[MW]）。
- `PV_forecast_make` では予測日射量に掛け合わせてPV予測出力を計算する。
- `PV_forecast_error_make` では誤差の正規化（%換算）に使用する。

### `PR_YYYY.mat`
- システム性能係数（Performance Ratio）。月ごとの値。
- 一般的には 0.7〜0.85 程度の値。
- `PV_forecast_make` で `PV_forecast = Radiation × PV_base × PR` の計算に使用。

### `Radiation_fcst_YYYY.mat`
- 予測日射量データ。30分間隔（1日48点）× 365日。
- 気象予報データから作成する。

### `PV_capa_YYYY.mat`
- 実際のPV導入容量（月ごと）[MW]。
- `PV_make` では実績出力の補正係数として使用。
- `PV_forecast_error_PVup_make` では容量別誤差計算の基準値として使用。

### `Pv_real_out_YYYY.mat`
- 1分間隔（1日1440点）の生の実績PV出力データ。
- `PV_make` 内で外部関数 `Mabiki` を使って30分間隔（48点）にダウンサンプリングされる。
- **注意**: `Mabiki` 関数が別途必要。

### `Load_YYYY.mat`
- 電力需要データ。30分間隔（1日48点）× 365日 [MW]。
- `PV_forecast_error_make` で誤差率の計算基準として使用。

### `douteki_lfc_ab.mat`
- 動的LFC容量計算の回帰係数。
- `ab(t,1)` = 傾き a、`ab(t,2)` = 切片 b（t は時間断面インデックス 1〜50）。
- B部門大会の分析結果から導出された係数。

### `new_ave_PV.mat` / `new_ave_load.mat`
- 年間の「代表的な1日」のPV出力・負荷カーブ（48点）。
- `douteki_LFC3` で特定日のデータの代わりに使用される平均カーブ。

### `PVC.mat`
- PV設備容量（スカラー値）[MW]。
- `mode1_no_sigma1` でPV出力帯域の幅（`PVC/5`）を計算するために使用。

### `time_label.mat`
- グラフのX軸に表示する時刻ラベル。
- `mode1_no_sigma` / `mode1_no_sigma1` でσ計算グラフの描画に使用。

---

## チェックリスト

実行前に以下を確認してください。

```
input_data/
├── [ ] data_2018.mat
├── [ ] data_2019.mat
├── [ ] PV_base_2018.mat
├── [ ] PV_base_2019.mat
├── [ ] PR_2018.mat
├── [ ] PR_2019.mat
├── [ ] Radiation_fcst_2018.mat
├── [ ] Radiation_fcst_2019.mat
├── [ ] PV_capa_2018.mat
├── [ ] PV_capa_2019.mat
├── [ ] Pv_real_out_2018.mat
├── [ ] Pv_real_out_2019.mat
├── [ ] Load_2018.mat
├── [ ] Load_2019.mat
├── [ ] douteki_lfc_ab.mat
├── [ ] new_ave_PV.mat
├── [ ] new_ave_load.mat
├── [ ] PVC.mat
└── [ ] time_label.mat
```

> 2018年・2019年以外の年度を使う場合は、`main_run.m` の冒頭にある `YEARS = [2018, 2019]` を変更し、対応する年度のファイルを配置してください。
