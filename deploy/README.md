# 電力系統需給運用シミュレーション — 引き継ぎパッケージ

このフォルダを丸ごとコピーして、**`model.m` を実行するだけで**シミュレーションが動作します。

---

## 実行手順

1. **MATLAB を起動する**
2. **このフォルダ（`deploy/`）をカレントディレクトリに設定する**
   - MATLAB の「Current Folder」パネルで `deploy/` フォルダを選択、または
   - コマンドウィンドウで `cd('C:\path\to\deploy')` と入力
3. **シミュレーション条件を設定する**
   - `model.m` をエディタで開き、冒頭の「シミュレーション条件設定」セクションを変更する
4. **実行する**
   - コマンドウィンドウで `model` と入力して Enter を押す
5. **結果を確認する**
   - `results/` フォルダに `.mat` ファイルが保存される

---

## フォルダ構成

```
deploy/
├── model.m                  ← ★ メインスクリプト（これを実行する）
├── new_dataload.m            ← データ読み込みサブスクリプト
├── mdl_eval_all_time.m       ← GPR モデル評価スクリプト
├── README.md                 ← このファイル
│
├── 基本データ/               ← 入力データ（.mat）
│   ├── PV_base_2019.mat      ← 既設PV容量データ（月別）
│   ├── PR_2019.mat           ← システム出力係数（月別）
│   ├── MSM_bai_2019.mat      ← MSM倍数係数（月別）
│   ├── irr_fore_data.mat     ← 予測日射量データ（全日・全モード）
│   ├── D_30min.mat           ← 30分値需要データ（全日分）
│   ├── D_1sec.mat            ← 1秒値需要データ ※要別途入手（容量大）
│   └── irr_mea_data.mat      ← 実測日射量データ ※要別途入手（容量大）
│
├── UC立案/MATLAB/            ← 起動停止計画（UC）最適化スクリプト群
│   ├── new_optimization.m    ← UC計算メインスクリプト
│   ├── ass_data.m            ← 発電機データ読み込み
│   ├── execute_UC.m          ← LP最適化実行
│   ├── make_kumiawase.m      ← 発電機組み合わせ生成
│   ├── check_onoff_time.m    ← 起動停止時間制約チェック
│   ├── rate_min.m            ← 発電機出力制約 ※要別途入手
│   ├── *.csv                 ← 発電機パラメータCSV（テンプレート）
│   └── 二次調整力算定手法/
│       └── 機械学習/ガウス過程回帰モデル/
│           ├── mdl.mat       ← 学習済みGPRモデル
│           ├── MSM_ALL.mat   ← MSM気象データ ※要別途入手
│           ├── MSM_30X.mat   ← MSM気象データ（特殊日用）※要別途入手
│           └── 学習データ（所要調整力）/  ← GitHubで管理（月別.mat）
│
├── 運用/                     ← Simulink モデルと初期設定スクリプト群
│   ├── AGC30_PVcut.slx       ← ★ Simulink メインモデル
│   ├── make_csv.m            ← 入力CSVファイル生成
│   ├── initset_dataload.m    ← 入力.matファイル生成
│   ├── initset_lfc.m         ← LFC モデルパラメータ設定
│   ├── initset_edc.m         ← EDC モデル初期値計算
│   ├── initset_thermals.m    ← 火力・GTCCモデル設定
│   ├── initset_inertia.m     ← 慣性モデル設定
│   ├── initset_trfpP.m       ← 連系線潮流モデル設定
│   ├── initset_otherarea.m   ← 他エリアモデル設定
│   ├── lowpass_PV.m          ← PV出力ローパスフィルタ処理
│   └── 定数.xlsx             ← 発電機定数データ
│
└── results/                  ← シミュレーション結果の保存先（自動生成）
```

---

## 別途入手が必要なファイル

以下のファイルはサイズが大きいか外部データのため `deploy/` に含まれていません。
担当者から直接受け取り、指定のフォルダに配置してください。

| ファイル名 | 配置先 | 説明 |
|---|---|---|
| `D_1sec.mat` | `基本データ/` | 1秒値需要データ（全日分）|
| `irr_mea_data.mat` | `基本データ/` | 実測日射量データ（全日分）|
| `MSM_ALL.mat` | `UC立案/MATLAB/二次調整力算定手法/機械学習/ガウス過程回帰モデル/` | MSM気象データ（全日分）|
| `MSM_30X.mat` | `UC立案/MATLAB/二次調整力算定手法/機械学習/ガウス過程回帰モデル/` | MSM気象データ（特殊日用）|
| `rate_min.m` | `UC立案/MATLAB/` | 発電機出力制約スクリプト |
| `学習データ（所要調整力）/月別.mat` | `UC立案/MATLAB/二次調整力算定手法/機械学習/ガウス過程回帰モデル/学習データ（所要調整力）/` | GitHubから `git clone` で取得可能 |

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
YYYYMMDD_list = ['20190828'];  % 対象日付（複数日は行列で指定）
PVC_list      = [5300];        % PV 導入容量 [MW]
meth_num_list = [2];           % 解析手法番号
mode_list     = [1];           % PV パネル設置モード（1〜5）
sigma         = 2;             % 予測誤差パラメータ
lfc           = 8;             % LFC 制御パラメータ
```

---

## 実行フロー概要

```
model.m
 ├─ [1/5] 基本データ読み込み（基本データ/）
 ├─ [2/5] PV予測・実績・需要データ計算
 ├─ [3/5] UC計算（UC立案/MATLAB/new_optimization.m）
 │         └─ ガウス過程回帰 → 二次調整力算定 → LP最適化 → CSV出力
 ├─ [4/5] Simulink シミュレーション（運用/AGC30_PVcut.slx）
 │         └─ initset_*.m でパラメータ設定 → sim() 実行
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
A: `UC立案/MATLAB/` フォルダに `rate_min.m` が配置されているか確認してください（別途入手が必要）。

**Q: `MSM_ALL` が見つからないエラーが出る**
A: `UC立案/MATLAB/二次調整力算定手法/機械学習/ガウス過程回帰モデル/` に `MSM_ALL.mat` を配置してください。

**Q: `AGC30_PVcut.slx` が開けない**
A: MATLAB の Simulink がインストールされているか確認してください。

**Q: データが読み込めない**
A: `基本データ/` フォルダに必要な `.mat` ファイルが全て揃っているか確認してください。

---

*最終更新: 2026年2月*
