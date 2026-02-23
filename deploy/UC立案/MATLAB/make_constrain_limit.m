% -- 発電機出力上下限制約 --
    ub0 = Rate_Min(1:11,1);
    lb0 = Rate_Min(1:11,2).*Aeq';

% -- 発電機出力変化速度上下限制約 --
    % 時刻断面2以降は前の最適解に依存
    if time == 1
        ub1 = ub0;
        lb1 = lb0;
    else
        ub1 = UC_planning(time-1,:)'+output_speed;
        lb1 = UC_planning(time-1,:)'-output_speed;
    end
    
% -- LFC容量確保制約を満たすべく必要な制約 (初めは，発電機出力上下限制約にする) --
    ub2 = ub0;
    lb2 = zeros(11,1);
% -- 起動維持時間制約を満たすべく必要な制約 (初めは，発電機出力上下限制約にする) --
    ub3 = ub0;
    lb3 = zeros(11,1);
% -- 停止維持時間制約を満たすべく必要な制約 (初めは，発電機出力上下限制約にする) --
    ub4 = ub0;
    lb4 = zeros(11,1);
    
    ub=horzcat(ub0,ub1,ub2,ub3);
    lb=horzcat(lb0,lb1,lb2,lb3);
    
    lb=max(lb')';                                       % 下限制約:最大下限を取る
    ub=min(ub')';                                       % 上限制約:最小上限を取る