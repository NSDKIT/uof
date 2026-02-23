# deploy フォルダ ─ 引き継ぎ用実行パッケージ

このフォルダを丸ごとコピーして渡すことで、他の PC 環境でもそのまま
シミュレーションを実行できます。

---

## フォルダ構成

```
deploy/
├── run_simulation.m        ← ★ これを実行するだけでOK（メインスクリプト）
├── README.md               ← このファイル
├── 基本データ/              ← PV・需要の入力データ（.mat）※別途配置が必要
│   ├── PV_base_2019.mat
│   ├── PR_2019.mat
│   ├── MSM_bai_2019.mat
│   ├── irr_fore_data.mat
│   ├── irr_mea_data.mat    ※容量大のため .gitignore 対象
│   ├── D_1sec.mat          ※容量大のため .gitignore 対象
│   └── D_30min.mat
├── UC立案/MATLAB/           ← 起動停止計画（UC）の最適化スクリプト
│   ├── new_optimization.m  ※別途配置が必要
│   └── LFC.mat             ※別途配置が必要
├── 運用/                    ← Simulink モデルと初期設定スクリプト群
│   ├── AGC30_PVcut.slx     ← Simulink メインモデル
│   ├── 定数.xlsx            ← 発電機物理パラメータ定義
│   ├── initset_dataload.m  ← データ読み込み・入力ファイル作成
│   ├── initset_edc.m       ← EDC 初期設定（等ラムダ法）
│   ├── initset_lfc.m       ← LFC 初期設定
│   ├── initset_thermals.m  ← 汽力・GTCC プラント初期設定
│   ├── initset_inertia.m   ← 慣性モデル設定
│   ├── initset_trfpP.m     ← 連系線潮流モデル設定
│   ├── initset_otherarea.m ← 他エリアモデル設定
│   ├── make_csv.m          ← Simulink 入力 CSV 作成
│   ├── lowpass_PV.m        ← PV 出力ローパスフィルタ処理
│   └── （その他サポートスクリプト）
└── results/                ← シミュレーション結果の保存先（自動生成）
```

---

## 実行手順

### 1. 必要なデータを配置する

以下のデータファイルを `基本データ/` フォルダに配置してください。
容量が大きいため GitHub には含まれていません。

| ファイル名 | 説明 |
|---|---|
| `D_1sec.mat` | 1秒値需要データ（全日分） |
| `irr_mea_data.mat` | 実測日射量データ（全日分） |

### 2. シミュレーション条件を設定する

`run_simulation.m` をテキストエディタまたは MATLAB エディタで開き、
「シミュレーション条件設定」セクションの以下の変数を変更してください。

```matlab
YYYYMMDD = ['20190828'];   % 対象日付（YYYYMMDD 形式）
PVC_list = [5300];         % PV 導入容量 [MW]
meth_num = 2;              % 解析手法番号（1〜4）
mode     = 1;              % PV パネル設置モード（1〜5）
sigma    = 2;              % 予測誤差の標準偏差パラメータ
```

### 3. MATLAB で実行する

1. MATLAB を起動する
2. `deploy/` フォルダをカレントディレクトリに設定する
3. コマンドウィンドウで以下を入力して Enter を押す

```matlab
run_simulation
```

### 4. 結果を確認する

シミュレーションが完了すると、`results/` フォルダに以下の形式で
結果ファイルが保存されます。

```
nSigma_2_Method_2_PVcapacity_5300_2019-8-28.mat
```

---

## 主要な変数の説明

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

**Q: `new_optimization` が見つからないエラーが出る**
A: `UC立案/MATLAB/` フォルダに `new_optimization.m` が配置されているか確認してください。

**Q: `AGC30_PVcut.slx` が開けない**
A: MATLAB の Simulink がインストールされているか確認してください。

**Q: データが読み込めない**
A: `基本データ/` フォルダに必要な `.mat` ファイルが全て揃っているか確認してください。
