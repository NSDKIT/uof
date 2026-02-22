# PV予測誤差分析ツール — deploy パッケージ

このフォルダを他の人に渡すだけで、**どの環境でもそのまま実行できる**パッケージです。

---

## クイックスタート

### 1. 事前準備

1. **このフォルダ (`deploy/`) をどこかに配置する**（例: `C:\Users\yourname\PV_analysis\deploy\`）
2. **`input_data/` フォルダに必要なデータを配置する**（後述の「必要な入力ファイル一覧」を参照）
3. **外部関数をMATLABパスに追加する**（後述の「外部依存関数」を参照）

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
├── main_run.m                   ← ★ エントリーポイント（ここを実行）
│
├── input_data/                  ← 入力データを配置するフォルダ
│   ├── data_2018.mat            ← 日付配列
│   ├── PV_base_2018.mat         ← 基準PV導入量
│   ├── ...（詳細は下記参照）
│
├── output/                      ← 実行結果が自動的に保存されるフォルダ
│   ├── PV_forecast_YYYY.mat     ← Step 1 の出力
│   ├── PV_YYYY.mat              ← Step 2 の出力
│   ├── ERROR_YYYY.mat           ← Step 3 の出力
│   ├── 予測PV出力誤差/           ← Step 4 の出力
│   ├── 動的LFC容量決定手法/      ← Step 5, 6 の出力
│   └── 時間粒度_気象分解能別予測誤差/ ← Step 5 (SIGMA_get1) の出力
│
├── PV_forecast_make.m           ← Step 1: 予測PV出力の生成
├── PV_make.m                    ← Step 2: 実績PV出力の生成
├── PV_forecast_error_make.m     ← Step 3: 予測誤差の計算
├── PV_forecast_error_PVup_make.m← Step 4: 容量別・日別誤差の生成
├── SIGMA_get.m                  ← Step 5: σ計算（基本版）
├── SIGMA_get1.m                 ← Step 5: σ計算（拡張版）
├── douteki_LFC3.m               ← Step 6: 動的LFC必要容量の計算
│
├── chose_data.m                 ← ユーティリティ（日付→行番号変換）
├── mode1_no_sigma.m             ← SIGMA_get の補助スクリプト
├── mode1_no_sigma1.m            ← SIGMA_get1 の補助スクリプト
│
├── PV_compare.m                 ← 可視化: 予測と実績の比較グラフ
├── PV_forecast_error_bar_make.m ← 可視化: 日別誤差の棒グラフ
├── PV_real_form.m               ← 可視化: 特定日のPV実績出力
├── yosoku_seido.m               ← 評価: 予測精度（箱ひげ図）
└── MAE.m                        ← 評価: 月別RMSE計算
```

---

## 必要な入力ファイル一覧

`input_data/` フォルダに以下のファイルを配置してください。

| ファイル名 | 内容 | 使用するスクリプト |
|:---|:---|:---|
| `data_YYYY.mat` | 日付配列 `[年, 月, 日, ...]` | 全スクリプト |
| `PV_base_YYYY.mat` | 各月の基準PV導入量 [MW] | PV_forecast_make, PV_forecast_error_make |
| `PR_YYYY.mat` | 各月のシステム性能係数 | PV_forecast_make |
| `Radiation_fcst_YYYY.mat` | 予測日射量 [W/m²] | PV_forecast_make |
| `PV_capa_YYYY.mat` | 各月の実際のPV導入容量 [MW] | PV_make, PV_forecast_error_PVup_make |
| `Pv_real_out_YYYY.mat` | 補正前のPV実績出力 | PV_make, PV_real_form |
| `Load_YYYY.mat` | 電力需要 [MW] | PV_forecast_error_make, PV_compare |
| `douteki_lfc_ab.mat` | LFC容量計算の係数 (a, b) | douteki_LFC3 |
| `new_ave_PV.mat` | 平均的なPV出力カーブ（48点） | douteki_LFC3 |
| `new_ave_load.mat` | 平均的な負荷カーブ（48点） | douteki_LFC3 |
| `PVC.mat` | PV設備容量 [MW] | mode1_no_sigma1 |
| `time_label.mat` | 時刻ラベル（グラフ表示用） | mode1_no_sigma, mode1_no_sigma1 |

> `YYYY` は年度（例: 2018, 2019）に置き換えてください。

---

## 外部依存関数

以下の関数はこのリポジトリに含まれていません。  
MATLABのパスに追加されていることを確認してください。

| 関数名 | 役割 | 使用するスクリプト |
|:---|:---|:---|
| `Mabiki(data, n)` | 1440点のデータをn点にダウンサンプリング | PV_make |
| `KAKURITUBU_BUNNPU(...)` | 確率分布計算（σ取得） | SIGMA_get, mode1_no_sigma |
| `KAKURITUBU_BUNNPU1(...)` | 確率分布計算（拡張版） | mode1_no_sigma1 |
| `sec_time_30min` | X軸の時刻ラベルを30分間隔に設定 | PV_compare, PV_forecast_error_bar_make |
| `get_color` | グラフの色設定 | SIGMA_get |

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
[Step 1] PV_forecast_make(year)
         │
         └──→ output/PV_forecast_YYYY.mat

input_data/
    PV_capa_YYYY.mat
    Pv_real_out_YYYY.mat
         │
         ▼
[Step 2] PV_make(year)
         │
         └──→ output/PV_YYYY.mat

output/PV_forecast_YYYY.mat
output/PV_YYYY.mat
input_data/Load_YYYY.mat
         │
         ▼
[Step 3] PV_forecast_error_make(year)
         │
         └──→ output/ERROR_YYYY.mat

output/ERROR_YYYY.mat
         │
         ▼
[Step 4] PV_forecast_error_PVup_make(year)
         │
         └──→ output/予測PV出力誤差/ERRORyyyymmdd.mat

output/ERROR_YYYY.mat
         │
         ▼
[Step 5] SIGMA_get1(year, 1, [], [], PVC_bai)
         │
         └──→ output/動的LFC容量決定手法/error_sigma.mat
         └──→ output/時間粒度_気象分解能別予測誤差/データ/PV*倍/時刻断面_i.mat

input_data/douteki_lfc_ab.mat
input_data/new_ave_PV.mat
input_data/new_ave_load.mat
         │
         ▼
[Step 6] douteki_LFC3(year, month, day, PVC_bai)
         │
         └──→ output/動的LFC容量決定手法/LFC_amount_yyyymmdd.mat
```

---

## 個別スクリプトの実行例

全処理が完了した後、以下のスクリプトで可視化・評価が可能です。

```matlab
% 2018年6月のPV予測と実績を比較するグラフ
PV_compare(2018, 6, 1.0)

% 2018年6月の日別誤差棒グラフ（基準容量）
PV_forecast_error_bar_make(2018, 6, 1)

% 予測精度の評価（箱ひげ図）
yosoku_seido

% 月別RMSE計算
MAE

% 特定日のPV実績出力確認
PV_real_form(2018)
```

---

## よくあるエラーと対処法

| エラーメッセージ | 原因 | 対処法 |
|:---|:---|:---|
| `input_data フォルダが見つかりません` | カレントディレクトリが違う | `cd('deploy/')` を実行 |
| `ファイルが見つかりません (data_2018.mat)` | input_data にファイルがない | input_data/ にファイルを配置 |
| `未定義の関数 'Mabiki'` | 外部関数がパスにない | MATLABパスに外部関数フォルダを追加 |
| `変数 'ERROR' が未定義` | Step 3 が未実行 | `PV_forecast_error_make(year)` を先に実行 |
