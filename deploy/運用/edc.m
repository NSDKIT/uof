%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%EDCモデル
% 【このプログラムで実施すること】
%　・AGC30モデルにおけるEDC計算(経済負荷配分計算)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% フラグナンバーによる場合分け
function [sys,x0,str,ts]=edc(t,x,u,flag) 
switch flag
    case 0
        [sys,x0,str,ts]=mdlinitializesizes;
    case 3
        sys = mdloutputs(t,x,u);
    case {1,2,4,9}
    otherwise
        error(['unhandled flag = ',num2str(flag)]);
end

%% 変数サイズの初期設定
function [sys,x0,str,ts] = mdlinitializesizes()
sizes = simsizes;
sizes.NumContStates = 0;
sizes.NumDiscStates = 0;
sizes.NumOutputs = 103; %出力ポート数の指定
sizes.NumInputs = 279; %入力ポート数の指定
sizes.DirFeedthrough = 1;
sizes.NumSampleTimes = 1;
sys = simsizes(sizes);
str = [];
x0 = [];
ts = [300 1]; %ステップの刻み幅 300sec単位で計算(サンプル時間オフセット)

%% EDC計算
 function sys =mdloutputs(t,x,u)
%% Simulinkからのデータ読み込み
time = strcat(sprintf('%d',floor(t/3600)),':',sprintf('%d',floor(rem(t,3600)/60))); % 解析時間表示

L_C =u(1,1);                  % EDC予測機能で補正した最新の需要予測値
P0 = u(2,1);                  % 連系線利用計画値
PMWD_SCHEDULE = u(3:32,1);    % 発電計画出力（AGC30）
P_CONSTANT= u(33:39,1);       % 発電計画出力（固定電源出力）
G_MODE  = u(40:69,1);         % 発電機制御モード

cP2= u(70:99,1);              % 燃料費特性係数　cP2：燃料費2乗の項
bP1= u(100:129,1);            % 燃料費特性係数　bP1：燃料費1乗の項
aP0= u(130:159,1);            % 燃料費特性係数　aP0：燃料費0乗の項
cP2div=cP2*2;                 % 燃料費の2乗の項の微分係数
bP1div=bP1;                   % 燃料費の1乗の項の微分係数  
G_up_limit = u(160:189,1);    % 計画値上限出力
G_down_limit = u(190:219,1);  % 計画値下限出力

% GULT=csvread('G_up_plan_limit_time.csv'); % EDC計算における入力設定値
% GDLT=csvread('G_down_plan_limit_time.csv'); % EDC計算における入力設定値
% G_up_limit = GULT(t,:);
% G_down_limit = min(GULT(t,:),GDLT(t,:));
G_speed = u(220:249,1);       % 出力変化速度
G_out_pre = u(250:279,1);     % 前回EDC演算時の発電出力

%% EDC計算の初期設定
% 出力変化速度を考慮してEDC上下限値を設定
G_up_limit = min(G_up_limit, G_out_pre + G_speed*5);
G_down_limit = max(G_down_limit, G_out_pre - G_speed*5);

% 発電機の計算状態を未確定に設定[未確定：1，上限仮確定:3，下限仮確定:5，確定：0]
G_out_status(1:size(cP2,1),1) = 1;
% 発電機出力の初期値を0に設定
G_out_put(1:size(cP2,1),1) = 0;

% EDC対象外ユニットの出力をスケジュール値に設定して確定
Glock_no = find (G_MODE == 0 | G_MODE == 2);
G_out_status(Glock_no) = 0;
G_out_put(Glock_no) = PMWD_SCHEDULE(Glock_no);

% スケジュール運転ユニットの発電単価を0に設定
P_cost(Glock_no,1) = 0;

%% EDC総配分量の計算

% disp('EDC総配分量')
P_S = sum(G_out_put); % 火力・揚水発電計画合計値  
P_C = sum(P_CONSTANT);  % 発電計画固定合計
% 需要想定補正結果 -（スケジュール運転計画値 + 固定電源計画値 + 連系線利用計画（受け側＋）)
P_L = L_C - (P_S + P_C + P0);   % EDC総配分量
PL_calc = P_L;

%% 経済負荷配分計算
P_fix = 0;

while sum(G_out_status) > 0; % 全ユニット出力確定（G_out_status = 0）でループアウト
    clear G_choice
    clear G_No_up
    clear G_No_down
    clear G_choice_L
    clear G_choice_H

    % 出力未確定発電機の選択
    G_choice = find(G_out_status > 0);

    cP2dive = cP2div(G_choice);
    bP1dive = bP1div(G_choice);
    P_max = G_up_limit(G_choice);
    P_min = G_down_limit(G_choice);

    % EDC総配分量を等λ計算繰り返し用の変数に代入
    PL_calc = PL_calc - P_fix;
    
    % 配分量計算
    Pr = 1./cP2dive;
    Pc = bP1dive./cP2dive;
    lambda = (PL_calc + sum(Pc) ) / sum(Pr); % n回目のラムダ
    P_calc = (lambda - bP1dive )./cP2dive ; % 負荷配分結果

    G_out_put(G_choice) = P_calc;

    % 出力上下限範囲外となる発電機の出力を上下限値に置換え
    G_No_up = find(P_max < P_calc);    % 上限を超えている発電機を検索
    G_out_put(G_choice(G_No_up)) = P_max(G_No_up);    % 出力を上限に設定
    G_out_status(G_choice(G_No_up)) = 3;     % 出力上限で仮確定

    G_No_down = find(P_min > P_calc);    % 下限を下まわっている発電機を検索
    G_out_put(G_choice(G_No_down)) = P_min(G_No_down);  % 出力を下限に設定
    G_out_status(G_choice(G_No_down)) = 5;  %  出力下限で仮確定

    % P_L = ΣP(i)の場合，全ての発電機の計算結果を確定して最適配分終了
    % 小数点以下の残差による無限ループ対策。閾値:1[MW]
    if abs(sum(G_out_put(G_choice)) - PL_calc) < 1;
%         disp('最適配分終了')
        G_out_status(G_choice)=0;
        sum(G_out_put(G_choice));
        
    % P_L < ΣP(i)>D）の場合，出力下限となった発電機の出力を確定
    elseif PL_calc < sum(G_out_put(G_choice));
%         disp('下限出力確定')
        G_choice_L = find(G_out_status == 5);
        G_out_status(G_choice_L) = 0;
        P_fix = sum(G_out_put(G_choice_L));
        
    % P_L > ΣP(i)<Dの場合，出力上限となった発電機の出力を確定
    else PL_calc > sum(G_out_put(G_choice));
%         disp('上限出力確定')
        G_choice_H = find(G_out_status == 3);
        G_out_status(G_choice_H) = 0;
        P_fix = sum(G_out_put(G_choice_H));
        
    end
    
    %%%%%   未確定発電機の出力をリセット
    G_out_put(find(G_out_status>0)) = 0;
    G_out_status(find(G_out_status>0)) = 1;

    %%%%%　発電単価
    P_cost = ((G_out_put.*G_out_put).*cP2+G_out_put.*bP1+aP0)./G_out_put;

end

PMWD_EDC = G_out_put;   % 火力・揚水発電機出力合計
EDC_ERR =(P_L+P_S) - sum(G_out_put);    % EDC配分残
P_OUT = sum(G_out_put) + P_C + P0;  % 発電機出力合計+P0
P_plan = sum(PMWD_SCHEDULE) + P_C;  % 発電機計画合計値

% disp('配分残')
disp(EDC_ERR);
% EDC.nokori(t)=EDC_ERR;

sys=[PMWD_EDC;P_CONSTANT;P_L;EDC_ERR;P_OUT;P_cost;L_C;P_plan;G_MODE;P0];

