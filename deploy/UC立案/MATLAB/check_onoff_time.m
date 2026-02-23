if time == 1
    hantei_on_time = ones(1,11);     % 非稼働機は対象外だから1，稼働機は制約を満たしてれば1
    hantei_off_time = ones(1,11); % 非停止機は対象外だから1，停止機は制約を満たしてれば1
else
    if isempty(a) ~= 0
        pre_on = (UC_planning(time-1,:)~=0); % 前時刻断面での起動状態の確認
%         pre_on = (UC_planning(time-1,:)>=Rate_Min(1:11,2)'-0.001); % 前時刻断面での起動状態の確認
        pre_off = pre_on==0;                                 % 前時刻断面での停止状態の確認
    %     now_on_off = (p>=Rate_Min(1:11,2)');                 % 現時刻断面での稼働状態の確認

    %     on_off_timing = pre_on-now_on_off;
            %  0: 起動停止状態に変化なし
            %  1: 停止
            % -1: 起動

        % -- 起動維持時間制約の対象発電機 --
        on_const_gen = (pre_on~=0);
        on_time = (on_time+pre_on).*pre_on;

        % -- 停止維持時間制約の対象発電機 --
        off_const_gen = (pre_off~=0);
        off_time = (off_time+pre_off).*pre_off;
    end
    hantei_on_time = (on_time==0)+(on_time>=gen_on);     % 非稼働機は対象外だから1，稼働機は制約を満たしてれば1
    hantei_off_time = (off_time==0)+(off_time>=gen_off); % 非停止機は対象外だから1，停止機は制約を満たしてれば1
end