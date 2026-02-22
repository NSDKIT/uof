%% PV_make.m
% # 役割
% 実際のPV設備容量や出力実績データから、予測値と比較するための「実績出力」データを作成します。
% 過去のデータは基準導入量(例: 819MW)で正規化されていたため、
% このスクリプトで毎月の実際の導入量に合わせて補正をかけます。
%
% # 実行方法
%
% ```matlab
% PV_make(year)
% % (例: PV_make(2018))
% ```
%
% # 入力
%
% - `data_YYYY.mat`: 日付や時刻などの基本データ
% - `PV_capa_YYYY.mat`: 各月の実際のPV導入容量データ
% - `Pv_real_out_YYYY.mat`: (補正前の)PV出力実績値
%
% # 出力
%
% - `PV_YYYY.mat`: 導入量で補正されたPV実績出力データ
%
% # 次のステップ
%
% このスクリプトで生成されたファイルは、`PV_forecast_error_make.m` で予測誤差を計算するために使用されます。

function PV_make(year)
%% 各年度のPV実測値が2018年5月の基準PV導入量819MWで統一させていた - ①
%% 実際は，基準PV導入量は3カ月ごとに更新されている(資源エネルギー庁のサイトより) - ②
%% そのため，①を②で修正する必要がある
load(['PV_capa_',num2str(year),'.mat']) % ②
load(['PV_real_out_',num2str(year),'.mat'])      % ①
load(['data_',num2str(year),'.mat'])    % 日付の選択を行うための配列
data_all = [];
for i = 1:min(size(Pv_real_out))
Mabiki(Pv_real_out(i,:),1440,30)
% M = [4:12 1:3];                         % 4月から12月、1月から3月
% PV_o = [];
% for i = 1:12
%     month = M(i);
%     a = find(data(:,2)==month);         % 月毎に行番号取得
%     b = data_all(a,:);                  % ①取得
%     PV_o = [PV_o;b*PV_capa(i)/819];
% end
global DATA
data_all = [data_all;DATA];
end
save(['PV_',num2str(year),'.mat'],'data_all')
end