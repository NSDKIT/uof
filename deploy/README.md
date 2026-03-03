# 電力系統需給運用シミュレーション — 引き継ぎパッケージ

このフォルダを丸ごとコピーして、**`model.m` を実行するだけで**シミュレーションが動作します。

---

## 実行手順

### 1.1. メインシミュレーションの実行

**`deploy/` フォルダに必要なデータファイルが全て揃っている場合**は、以下の手順でシミュレーションを実行できます。

1.  **MATLAB を起動する**
2.  **このフォルダ（`deploy/`）をカレントディレクトリに設定する**
3.  **シミュレーション条件を設定する** (`model.m` の冒頭を編集)
4.  コマンドウィンドウで `model` と入力して **実行する**
5.  `results/` フォルダに保存された**結果を確認する**

### 1.2. 前処理の自動実行

`deploy/` フォルダに必要な `.mat` ファイルが不足している場合、`model.m` はシミュレーション条件 `lfc` の値に応じて、適切な前処理スクリプトを **自動的に実行** しようと試みます。

- **AGCモード (`lfc < 100`)**: AGC制御シミュレーションに特化した `_agc` 版のスクリプトが実行されます。
- **非AGCモード (`lfc >= 100`)**: 汎用の通常版スクリプトが実行されます。

> **注意**: 前処理の自動実行がエラーになる場合は、各前処理スクリプトが必要とする手動でのデータ配置（Excelファイルや気象データなど）が完了しているかを確認してください。詳細は各フォルダ内の `README.txt` やスクリプトのコメントに記載されています。

---

## フォルダ構成

```
deploy/
├── model.m                  ← ★ メインスクリプト（これを実行する）
├── setup_fixed_params.m     ← 固定パラメータ（PV/WT切替等）の設定
├── calc_reserve_capacity.m  ← GPRモデルで二次調整力（所要調整力）を全時間断面で算出
├── README.md                ← このファイル
│
├── 基本データ/              ← 入力データ（.mat）および生成スクリプト
│   ├── PV_base_2019.mat     ← 既設PV容量データ（月別）
│   ├── PR_2019.mat          ← システム出力係数（月別）
│   ├── MSM_bai_2019.mat     ← MSM倍数係数（月別）
│   ├── irr_fore_data.mat    ← 予測日射量データ（全日・全モード）
│   ├── D_30min.mat          ← 30分値需要データ（全日分）
│   ├── D_1sec.mat           ← 1秒値需要データ（元データから生成可能）
│   ├── irr_mea_data.mat     ← 実測日射量データ（元データから生成可能）
│   ├── PVC.mat              ← PV導入容量設定（初期値）
│   │
│   ├── PV実測値作成/        ← PV実測値データ生成スクリプト
│   │   ├── get_PV300_set.m  ← PV300の1秒値CSVからirr_mea_data.matを生成
│   │   └── 1秒値/           ← PV300の1秒値CSV配置用フォルダ（README.txtあり）
│   │       ├── area1/
│   │       ├── ...
│   │       └── area17/
│   │
│   └── 需要作成/            ← 需要データ生成スクリプト
│       ├── get_demand.m     ← 需給ExcelからD_1sec.matを生成
│       ├── csv_tieline_PV2018.m ← 北陸山元2018.xlsx読み込み関数
│       └── csv_tieline_PV2019.m ← 北陸山元2019.xlsx読み込み関数
│
├── UC立案/MATLAB/           ← 起動停止計画（UC）最適化スクリプト群
│   ├── run_unit_commitment.m    ← UC計算メインスクリプト
│   ├── load_uc_input_data.m     ← 発電機データ読み込み
│   ├── solve_lp_optimization.m  ← LP最適化実行
│   ├── gen_unit_combinations.m  ← 発電機組み合わせ生成
│   ├── check_startup_shutdown_time.m    ← 起動停止時間制約チェック
│   ├── rate_min.m           ← 発電機出力制約 ※要別途入手
│   ├── *.csv                ← 発電機パラメータCSV（テンプレート）
│   └── 二次調整力算定手法/
│       └── 機械学習/ガウス過程回帰モデル/
│           ├── MSM_ALL.mat      ← MSM気象データ（全日分）
│           ├── MSM_30X.mat      ← MSM気象データ（特殊日用）
│           ├── mdl_NotXAI_June0.mat       ← 非XAI-GPR学習済みモデル
│           ├── mdl_XAI_area1_December.mat ← XAI-GPR学習済みモデル（エリア1・12月）
│           ├── mdl_XAI_area13_December.mat ← XAI-GPR学習済みモデル（エリア13・12月）
│           └── 学習データ（所要調整力）/  ← 7月〜翌2月の学習データ（.mat）
│
├── 運用/                    ← Simulink モデルと初期設定スクリプト群
│   ├── AGC30_PVcut.slx      ← ★ Simulink メインモデル
│   ├── build_simulink_input_csv.m            ← 入力CSVファイル生成
│   ├── init_simulation_data.m    ← 入力.matファイル生成
│   ├── init_lfc_model.m         ← LFC モデルパラメータ設定
│   ├── init_edc_model.m         ← EDC モデル初期値計算
│   ├── init_thermal_model.m    ← 火力・GTCCモデル設定
│   ├── init_inertia_model.m     ← 慣性モデル設定
│   ├── init_tieline_model.m       ← 連系線潮流モデル設定
│   ├── init_other_area_model.m   ← 他エリアモデル設定
│   ├── apply_pv_lowpass_filter.m          ← PV出力ローパスフィルタ処理
│   ├── CC.mat               ← GTCCプラントモデル定数
│   ├── ST.mat               ← 汽力プラントモデル定数
│   └── 定数.xlsx            ← 発電機定数データ
│
├── PV実出力作成/            ← PV実出力計算スクリプト
│   ├── calc_pv_actual_output.m      ← 1日分のPV実績出力を計算（非AGCモード）
│   ├── calc_pv_actual_output_agc.m  ← 1日分のPV実績出力を計算（AGCモード）
│   ├── load_agc_rampdown_data.m     ← AGC用PVランプダウンデータをExcelから読み込む
│   ├── select_pv_curve.m            ← 日付に応じてPV曲線を選択・外挿
│   ├── collect_irradiance_by_area.m ← エリア別日射量データを収集・整理
│   ├── import_pv300_1sec.m          ← PV300の1秒値CSVをインポートする関数
│   ├── import_lat_lon.m             ← 緯度経度データをExcelからインポートする関数
│   ├── interpolate_to_1sec.m        ← 30分値データ...(content truncated)...
│   └── AGC_データ/            ← PV_ランプダウン.xlsx 配置用フォルダ
│
├── 予測PV出力作成/          ← PV予測出力計算スクリプト
│   ├── calc_pv_forecast_year.m      ← 年間PV予測出力を計算（非AGCモード）
│   ├── calc_pv_forecast_year_agc.m  ← 年間PV予測出力を計算（AGCモード）
│   ├── convert_msm_to_irradiance.m  ← MSMバイナリから日射量に変換（非AGCモード）
│   ├── convert_msm_to_irradiance_agc.m ← MSMバイナリから日射量に変換（AGCモード）
│   ├── run_wgrib2_extract_irradiance.m ← wgrib2でMSMバイナリから日射量抽出
│   ├── copy_msm_bin_to_wgrib2.m     ← MSMバイナリをwgrib2フォルダにコピー
│   └── TDBTDB.m                     ← MSMバイナリデータ処理のメインスクリプト
│
├── 需要実績・予測作成/      ← 需要実績・予測データ生成スクリプト
│   ├── build_demand_data_2018.m     ← 2018年需要データ生成
│   ├── build_demand_data_2019.m     ← 2019年需要データ生成
│   ├── build_demand_data_2019_agc.m ← 2019年需要データ生成（AGCモード）
│   └── calc_demand.m                ← 需要計算のメインスクリプト
│
├── wgrib2/                  ← wgrib2.exe と関連ファイル
│   ├── wgrib2.exe
│   ├── gmerge.exe
│   ├── smallest_4.exe
│   ├── get_TMP.m
│   └── cygwin1.dll 他DLL群
│
├── MSMデータ/               ← MSMバイナリデータ（.binファイル）配置用フォルダ
│
└── results/                 ← シミュレーション結果の保存先（自動生成）
```

---

## 環境設定（初回のみ）

`model.m` の冒頭にある **外部ツール・データフォルダ設定** セクションを、実行環境に合わせて変更してください。

```matlab
%% ── 外部ツール・データフォルダ設定 ──────────────────────────────────────
% ▼▼▼ 環境に合わせて変更してください ▼▼▼
% wgrib2.exe が置かれているフォルダ（MSMバイナリの処理に使用）
WGRIB2_DIR  = fullfile(ROOT_DIR, 'wgrib2');
% MSM気象データ（.binファイル）が格納されているフォルダ
MSM_DATA_DIR = fullfile(ROOT_DIR, 'MSMデータ');
% ▲▲▲ 設定ここまで ▲▲▲
```

| 変数名 | 説明 | デフォルト値 |
|---|---|---|
| `WGRIB2_DIR` | `wgrib2.exe` が置かれているフォルダ | `deploy/wgrib2/` |
| `MSM_DATA_DIR` | MSM気象データ（`.bin`ファイル）が格納されているフォルダ | `deploy/MSMデータ/` |

> **注意**: AGCモード（`lfc < 100`）で `PV_ランプダウン.xlsx` が必要な場合は、`ROOT_DIR/PV実出力作成/AGC_データ/` フォルダに配置してください。

---

## 別途入手が必要なファイル

以下のファイルはサイズが大きいか外部データのため `deploy/` には含まれていません。担当者から直接受け取り、指定のフォルダに配置してください。

| ファイル名 | 配置先 | 説明 |
|---|---|---|
| `北陸山元2018.xlsx` | `deploy/需要実績・予測作成/` | 需要実績データ（2018年） |
| `北陸山元2019.xlsx` | `deploy/需要実績・予測作成/` | 需要実績データ（2019年） |
| PV300の1秒値CSV | `deploy/基本データ/PV実測値作成/1秒値/areaX/YYYY_MM/` | PV300の1秒値データ（17エリア × 全日分） |
| MSMバイナリデータ（`.bin`） | `deploy/MSMデータ/` | 気象庁MSM数値予報データ |
| `rate_min.m` | `deploy/UC立案/MATLAB/` | 発電機出力制約スクリプト |
| `学習データ（4月〜6月）` | `deploy/UC立案/MATLAB/二次調整力算定手法/機械学習/ガウス過程回帰モデル/学習データ（所要調整力）/` | 4月〜6月の学習データ（.mat）|

---

## 必要な MATLAB ツールボックス

- **Simulink**（`AGC30_PVcut.slx` の実行に必須）
- **Optimization Toolbox**（LP最適化 `linprog` に必須）
- **Statistics and Machine Learning Toolbox**（ガウス過程回帰に必須）
- MATLAB R2019b 以降を推奨

---

## シミュレーション条件の変更方法

`model.m` の冒頭にある以下のセクションを変更してください：

```matlab
%% ── シミュレーション条件設定 ─────────────────────────────────────────────
YYYYMMDD_list = ["20190828"];  % 対象日付（複数日は行列で指定）
PVC_list      = [5300];        % PV 導入容量 [MW]
meth_num_list = [2];           % 解析手法番号
mode_list     = [1];           % PV パネル設置モード（1〜5）
sigma         = 2;             % 予測誤差パラメータ
lfc           = 8;             % LFC 制御パラメータ (100以上で非AGCモード)
```

---

## 実行フロー概要

```
model.m
 ├─ [1/5] 基本データ読み込み（基本データ/）
 ├─ [2/5] PV予測・実績・需要データ計算
 ├─ [3/5] UC計算（UC立案/MATLAB/run_unit_commitment.m）
 │         └─ ガウス過程回帰 → 二次調整力算定 → LP最適化 → CSV出力
 ├─ [4/5] Simulink シミュレーション（運用/AGC30_PVcut.slx）
 │         └─ init_*.m でパラメータ設定 → sim() 実行
 └─ [5/5] 結果保存（results/）
```

---

## 主要な出力変数

| 変数名 | 説明 |
|---|---|
| `dfout` | 周波数偏差の時系列データ [Hz] |
| `PV_Out` | PV 実績出力の時系列データ [pu] |
| `LFC_Output` | LFC 制御出力の時系列データ [pu] |
| `EDC_Output` | EDC 制御出力の時系列データ [pu] |
| `G_Out_UC` | UC 計算による発電機出力計画 [MW] |
| `Reserved_power` | 調整力の時系列データ [MW] |

---

## トラブルシューティング

**Q: `rate_min` が見つからないエラーが出る**
A: `deploy/UC立案/MATLAB/` フォルダに `rate_min.m` が配置されているか確認してください（別途入手が必要）。

**Q: `MSM_ALL.mat` が見つからないエラーが出る**
A: `deploy/UC立案/MATLAB/二次調整力算定手法/機械学習/ガウス過程回帰モデル/` に `MSM_ALL.mat` を配置してください。

**Q: `AGC30_PVcut.slx` が開けない**
A: MATLAB の Simulink がインストールされているか確認してください。

**Q: `D_1sec.mat` や `irr_mea_data.mat` が見つからないエラーが出る**
A: これらのファイルは `get_demand.m` や `get_PV300_set.m` を実行することで元データから生成されます。元となるExcelファイルやCSVファイルが指定の場所に配置されているか確認してください。

**Q: `北陸山元2019.xlsx` が見つからないエラーが出る**
A: `deploy/需要実績・予測作成/` フォルダに `北陸山元2019.xlsx` が配置されているか確認してください（別途入手が必要）。

**Q: PV300の1秒値CSVが見つからないエラーが出る**
A: `deploy/基本データ/PV実測値作成/1秒値/areaX/YYYY_MM/` フォルダに `dayX.csv` 形式でCSVファイルが配置されているか確認してください（別途入手が必要）。

---

*最終更新: 2026年3月*
