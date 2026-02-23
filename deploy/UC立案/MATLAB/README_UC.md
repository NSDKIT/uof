# UC立案/MATLAB フォルダ

このフォルダには、発電機の起動停止計画（Unit Commitment）を最適化する
MATLABスクリプトが格納されます。

## 必要なファイル

このフォルダには以下のファイルが必要です（元のリポジトリから取得してください）:

- `new_optimization.m` : UC最適化メインスクリプト
- `LFC.mat`            : LFC関連データ
- その他 UC計算に必要なスクリプト・データファイル

## 出力ファイル

UC計算が完了すると、以下のCSVファイルが生成され、`運用/` フォルダにコピーされます:

- `G_Out.csv`               : 発電機出力計画
- `G_up_plan_limit.csv`     : LFC上げ調整力計画
- `G_down_plan_limit.csv`   : LFC下げ調整力計画
- `G_up_plan_limit_time.csv`: LFC上げ調整力時間計画
