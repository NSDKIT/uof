%% PV_forecast_error_PVup_make.m
% # 役割
% 基準となるPV導入量での予測誤差(`ERROR_YYYY.mat`)を基に、
% PV導入量が変化した場合(基準の4倍まで)の予測誤差を計算します。
% 計算結果を日付ごと・容量ごとに分解し、別々の`.mat`ファイルとして保存します。
%
% # 実行方法
%
% ```matlab
% PV_forecast_error_PVup_make(year)
% % (例: PV_forecast_error_PVup_make(2018))
% ```
%
% # 前提条件
%
% - `PV_forecast_error_make.m` の実行が完了していること。
%
% # 入力
%
% - `ERROR_YYYY.mat`: 基準PV導入量での予測誤差データ
% - `data_YYYY.mat`: 日付データ
% - `PV_capa_YYYY.mat`: 各月の基準PV導入量データ
%
% # 出力
%
% - `予測PV出力誤差_YYYY` フォルダ内に、日別の誤差ファイル (`ERRORyyyymmdd.mat`) が多数生成されます。
%
% # 次のステップ
%
%   このスクリプトで生成された日別ファイルは、`PV_forecast_error_bar_make.m` などで可視化するために使用されます。
%
% # 内部処理
%
%   - `chose_data.m` を使用して、日付からファイル名を作成します。

function PV_forecast_error_PVup_make(year)
%% 基準PV導入量からそれの4倍までの導入した際の，各PV出力予測誤差
year1 = year;
load(['ERROR_',num2str(year),'.mat'])    % 基準PV導入量での予測誤差
ERROR1=ERROR;
load(['data_',num2str(year),'.mat'])     % 日付の選択を行うための配列
load(['PV_capa_',num2str(year),'.mat'])  % 各年，各月の基準PV導入量

M = [4:12 1:3];
for i = 1:12
    month = M(i);
    a = find(data(:,2)==month);         % 月毎に行番号取得
    ERROR2 = ERROR1(a,:);
    for day =1:length(a)
        E=ERROR2(day,:);                  % 任意の日付番号での予測誤差取得
        EEE=[];
        for PVC = PV_capa(i):20:PV_capa(i)*4 % 基準PV導入量からそれの4倍までのPV導入量
            EEE = [EEE abs(E'*PVC/PV_capa(i))]; % 820MWで固定されてるのは問題
        end
        ERROR = EEE;
        chose_data(year1,month,day)
        global a_day
        d = data(a_day,:);
        if d(2) < 4
            year = year1 + 1;
        else
            year = year1;
        end
        save(['ERROR',num2str(year),num2str(d(2)),num2str(d(3)),'.mat'],'ERROR')
        movefile(['ERROR',num2str(year),'*'],['予測PV出力誤差_',num2str(year1)])
    end
end
end