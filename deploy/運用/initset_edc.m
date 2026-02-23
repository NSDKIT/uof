%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% iniset_edc.m EDCモデル(EDC計算)における初期設定
% 【このプログラムで実施すること】
%　・発電機の起動・停止時における制御モードの切替タイミングを補正
%　・発電機の停止時における上下限値の設定
%  ・初期断面の発電計画出力を等ラムダ法で配分し直し(需給インバランスも解消)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 自動給電発電機の対象数の定義
% このスクリプトは、経済負荷配分制御(EDC)モデルの初期設定を行います。
% 主な処理は以下の通りです。
% 1. 発電機の起動・停止タイミングにおける制御モードの補正
% 2. 発電機停止時のEDC出力上下限値の動的な設定
% 3. シミュレーション開始断面(t=0)における需給バランスの調整と、
%    経済負荷配分（等ラムダ法）による各発電機の初期出力の再計算

 AGCNum_E = 30;  % Simulink上でのLFC信号の端子数を定義

%% iniset.mで読み込んだ入力データベクトルをEDC計算用に転置

 P0 = Tieline_Base';              %連系線潮流計画値
 PMWD_SCHEDULE = g_out_input';    %AGC30の発電計画値
 P_CONSTANT = g_const_out_input'; %固定電源の発電計画値
 G_MODE = g_mode_input';          %発電機(AGC30)の制御モード
 GMW =GMW';                       %発電機(AGC30)の定格出力値
 Gmin = Gmin';                    %発電機(AGC30)の最低出力値

%% 発電計画で設定した起動・停止タイミングの補正
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 発電機起動停止時において、制御モード切替時に発電出力が不連続となることを防止
% するため、制御モードの切替タイミングを補正する
% 　　・起動タイミングの補正
%       （EDC制御周期でG_MODE=0であれば，その制御周期期間はG_MODE=0とする）
% 　　・停止タイミングの補正
%       （EDC制御周期でG_MODE>0，次のEDC制御周期手前でG_MODE=0であれば，
%                                       その制御周期期間はG_MODE=0とする）
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 発電機の起動・停止時における制御モードの補正
 G_MODE0 = G_MODE;
 iEDC = 300;  % EDC制御周期：1, 301, 601, ... （オフセットに注意）
 oEDC = 1;    % EDCのタイミングオフセット
 kEDC = find( mod(G_MODE0(:,1), iEDC) == oEDC );  % EDC制御を行う行番号を抽出

 for i=1:size(kEDC,1)
    for j=2:size(G_MODE0,2)
        if G_MODE0(kEDC(i), j) == 0  % EDC制御周期でG_MODE=0の場合
            G_MODE(kEDC(i) : min(end, kEDC(i)+iEDC-1), j) = 0;  % その制御周期期間はG_MODE=0とする
        end
        
        if (G_MODE0(kEDC(i), j) > 0) && (G_MODE0(min(end, kEDC(i)+iEDC-1), j) == 0)  % EDC制御周期でG_MODE>0，次のEDC制御周期手前でG_MODE=0
            G_MODE(kEDC(i) : min(end, kEDC(i)+iEDC-1), j) = 0;  % その制御周期期間はG_MODE=0とする
        end        
    end
 end
 
 
%% 発電機の停止時におけるEDC上下限値の設定
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 発電機停止時において、制御モード切替時に発電出力が不連続となることを防止
% するため、停止カーブに沿った上下限値を設定する
% 　　・出力上下限値の設定
%       （時間を最後から逆に溯り，停止に入るタイミングから出力上限を変化速度
%         見合いで増加し，起動終了のタイミングで出力上限を最小値にリセット)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


 % G_MODEが0で0，0以外で1
 G_MODE2 = (G_MODE(:, 2:end)~=0);

 % 停止を考慮した出力上限の設定
 % 最終時刻
 up_lim2(size(G_MODE2,1),:) = G_MODE2(end, :) .* GMW + not(G_MODE2(end, :)) .* Gmin;
 up_lim2(size(G_MODE2,1),:) = min(G_up_limit', up_lim2(size(G_MODE2,1),:));

 % 時間を最後から逆に溯り，停止に入るタイミングから出力上限を変化速度見合いで増加し，
 % 起動終了のタイミングで出力上限を最小値にリセット
 G_up_limit_time=get_Gupplanlimittime('G_up_plan_limit_time.csv');
for i = size(G_MODE2,1)-1:-1:1
     up_lim2(i, :) = up_lim2(i+1, :)+G_speed'/60 .* G_MODE2(i, :);
     
     up_lim2(i, :) = min(G_up_limit_time(i,:), up_lim2(i,:));
%      up_lim2(i, :) = min(G_up_limit', up_lim2(i,:));
     
     up_lim2(i, G_MODE2(i,:)==0) = Gmin( G_MODE2(i,:)==0 );
end

 % EDC制御が更新される直前に所望の出力に達する必要があるため，1周期分前倒し
 up_lim2(1:end-300,:) = up_lim2(301:end,:);
 up_lim2(end-299:end,:) = ones(300,1) * up_lim2(end, :);

 G_up_limit2 = horzcat(simtimevector, up_lim2);

%% 発電計画ツールで引き継いだ各発電計画値を等ラムダ法で再度配分し直す
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ・発電計画ツールは起動停止を決定することが目的であり、各発電機の計画値は、簡易
%　 な経済計算によって仮決定したもの。
% ・このため、シミュレーション開始前に、起動発電機で等ラムダ法を用いて、再度初期
%　 出力を配分しなおす。
% ・計画出力は、需要予測に基づき設定されているため、本来は、シミュレーション開始
%   時点で実需要と予測需要の誤差分だけ需給インバランスが生じる。
% ・このプログラムでは、評価のしやすさの観点から、初期断面での需給インバランスは
%   ゼロとした状態からシミュレーションを開始するように初期EDC計算を実施する。
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 初期EDC計算の実施

% 実績総需要(残余需要) 
 L_C = load_input(2,1)-PV_Out(2,1)-WT_Out(2,1);

% 燃料特性係数費[cP2：燃料費2乗の項、bP1：燃料費1乗の項、aP0：燃料費0乗の項]
 cP2 = G_cost( 1:30,1);
 bP1 = G_cost(31:60,1);
 aP0 = G_cost(61:90,1);
 cP2div = cP2*2; % 燃料費の2乗の項の微分係数
 bP1div = bP1;   % 燃料費の1乗の項の微分係数  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EDC初期値設定
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%発電機出力の状態設定[0:出力確定,1:出力未確定]
 G_out_status(1:size(cP2,1),1) = 1;  % 全発電機を出力未確定にセット
 G_out_put(1:size(cP2,1),1) = 0;     % 全発電機の出力を0にセット

%発電機モードによるEDC対象設定。EDC対象外[0,2]の発電機は，スケジュール運転に設定
 Glock_no = find (G_MODE(1,:) == 0 | G_MODE(1,:) == 2);
 G_out_status(Glock_no-1) = 0;
 G_out_put(Glock_no-1) = PMWD_SCHEDULE(1,Glock_no);  % スケジュール運転計画値

 P_cost(Glock_no-1,1) = 0;   % スケジュール運転時の発電単価を0に設定

 P_fix = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EDC総配分量計算
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 disp('EDC配分量（初期値）');
% sum_PMWD_SCHEDULE = sum(PMWD_SCHEDULE(1,2:31));%火力・揚水発電計画合計値  

 P_C = sum(P_CONSTANT(1,2:8));   % 固定電源（計画値）
 P_S = sum(G_out_put);           % スケジュール運転機（計画値）

% EDC総配分量 = 需要 - (スケジュール運転計画値 + 固定電源計画値 - 連系線利用計画（受け側＋）)
 P_L = L_C - (P_S + P_C + P0(1,2));
 haibun = P_L;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%　経済負荷配分
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

while sum(G_out_status) > 0 %全ユニット出力確定（ΣG_out_status=0）でループアウト
% 初期化
    clear G_choice
    clear G_No_up
    clear G_No_down   
    clear G_choice_L
    clear G_choice_H    

% 出力未確定の発電機のみでマトリクスを作成
    G_choice = find(G_out_status > 0);

    cP2dive = cP2div(G_choice);
    bP1dive = bP1div(G_choice);
    P_max = G_up_limit(G_choice);
    P_min = G_down_limit(G_choice,1);

    sumP_max = sum(G_up_limit(G_choice));
    sumP_min = sum(G_down_limit(G_choice,1));

% 等ラムダ計算繰り返し時のEDC配分量
    haibun = haibun  - P_fix
    
% 等ラムダ法による配分量計算
    Pr = 1./cP2dive;
    Pc = bP1dive./cP2dive;
    lambda = (haibun + sum(Pc) ) / sum(Pr); % n回目のラムダ

    P_calc = (lambda - bP1dive )./cP2dive ; % 負荷配分結果
    G_out_put(G_choice) = P_calc;

% 出力上下限範囲外となる発電機出力を上下限値に置換え
    G_No_up = find(P_max < P_calc);                 % 上限を超えている発電機を検索
    G_out_put(G_choice(G_No_up)) = P_max(G_No_up);  % 出力を上限に設定
    G_out_status(G_choice(G_No_up)) = 3;            % 出力上限で仮確定

    G_No_down = find(P_min > P_calc);                   % 下限を下まわっている発電機を検索
    G_out_put(G_choice(G_No_down)) = P_min(G_No_down);  % 出力を下限に設定
    G_out_status(G_choice(G_No_down)) = 5;              %  出力下限で仮確定

% P_L = ΣP(i)の場合，全ての発電機の計算結果を確定して最適配分終了
% 小数点以下の差分により無限ループとならないようよう閾値（配分残）1MWを設定
    if abs(haibun-sum(G_out_put(G_choice))) < 1;
        disp('最適配分終了')
        G_out_status(G_choice)=0;

% P_L < ΣP(i)の場合，出力下限となった発電機の出力を確定
    elseif sum(G_out_put(G_choice)) > haibun;
        disp('下限出力確定')
        G_choice_L = find(G_out_status == 5);
        G_out_status(G_choice_L) = 0;
        P_fix = sum(G_out_put(G_choice_L));

% ΣP(i)<Dの場合，出力上限となった発電機の出力を確定
    else % sum(G_out_put(G_choice)) < haibun;
        disp('上限出力確定')
        G_choice_H = find(G_out_status == 3);
        G_out_status(G_choice_H) = 0;
        P_fix = sum(G_out_put(G_choice_H));

    end    
    
% 未確定発電機の配分結果をリセット
    G_out_put(find(G_out_status>0)) = 0;
    G_out_status(find(G_out_status>0)) = 1;

% 発電単価
    P_cost = ((G_out_put.*G_out_put).*cP2+G_out_put.*bP1+aP0)./G_out_put;

end

PMWD_EDC = G_out_put;               % 火力・揚水発電機計画出力値
EDC_ERR =P_L + P_S - sum(G_out_put);      % EDC配分残
P_OUT = sum(G_out_put)+P_C+P0(1,2); % 発電機出力合計+P0
P_plan = sum(PMWD_SCHEDULE)+P_C;    % 発電機計画合計値

disp('EDC配分残')
disp(EDC_ERR)


PMWD_SCHEDULE(1,2:31) = G_out_put;

% EDCの初期値
 PMWD_EDC0 = zeros(1,30);
 PMWD_EDC0(1,[1:30]) = PMWD_SCHEDULE(1,2:31)'; 

