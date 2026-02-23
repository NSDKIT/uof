LFC_gen=7:11;EDC_gen=1:11;

% -- 確認事項:発電機出力下限制約を満たすかどうか --
    hantei_min1 = p(1:11)>=Rate_Min(1:11,2)'-0.01;    % 最小出力以上かどうか判定
    hantei_min2 = p(1:11)<=0.01;                 % 停止発電機の判定
    hantei_min = hantei_min1+hantei_min2;  % 全て1になればOK

% -- 確認事項:LFC容量確保制約を満たすか --
    b_o=b_lfc(2:12);
    LFC_opt = sum((LFC_rated(LFC_gen+1)-b_o(LFC_gen)).*hantei_min1(LFC_gen)'); % 'hantei_min1(LFC_gen)'を乗ずる，稼働LFC機でのLFC確保量算出
    lfc_surplus = LFC_opt-LFC_capacity(1);       % 系統でのLFC確保量制約を満たしていれば正
    lfc_surplus =round(lfc_surplus,2);           % 正になればOK

% -- 確認事項:EDC容量確保制約を満たすか --
	EDC_C=(b_o-(p(:,EDC_gen))').*hantei_min1';   % 起動停止に関わらず，LFC確保量]
    EDC_opt=sum(EDC_C);
%     EDC_C=EDC_rated(EDC_gen+1)-(p(:,EDC_gen))';   % 起動停止に関わらず，LFC確保量
%     EDC_opt = sum(EDC_C.*(p(EDC_gen)~=0)'); % 'hantei_min1(EDC_gen)'を乗ずる，稼働EDC機でのEDC確保量算出
    edc_surplus = EDC_opt-EDC_capacity(1);       % 系統でのLFC確保量制約を満たしていれば正
    edc_surplus =round(edc_surplus,2);           % 正になればOK

% % -- 下げ代確認 --
% rate_min
% EDC_LFC_down=abs(sum((Rate_Min(1:11,2)-p').*Aeq'));