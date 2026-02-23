function [d_PV_error_30min_all, d_lfc_use_30min_all] = gather(yyyy, mm)
    % 月の英語表記を取得（3文字の短縮形）
    switch mm
        case 1; month_en = 'Jan';
        case 2; month_en = 'Feb';
        case 3; month_en = 'Mar';
        case 4; month_en = 'Apr';
        case 5; month_en = 'May';
        case 6; month_en = 'Jun';
        case 7; month_en = 'Jul';
        case 8; month_en = 'Aug';
        case 9; month_en = 'Sep';
        case 10; month_en = 'Oct';
        case 11; month_en = 'Nov';
        case 12; month_en = 'Dec';
        otherwise; error('無効な月です');
    end
    
    % 月の初日を取得
    startDate = datetime(yyyy, mm, 1);
    % 月の最後の日を計算
    endDate = dateshift(startDate, 'end', 'month');
    % 日付リストを生成
    dateList = startDate:endDate;
    % 日付リストをchar配列に変換（スラッシュなし）
    yyyymmdd = datestr(dateList, 'yyyymmdd');
    file_yyyymm = yyyymmdd(1,1:6);
    
    file_path = [file_yyyymm,'_',month_en];
    
    d_PV_error_30min_all = [];
    d_lfc_use_30min_all = [];
    for d = 1:size(yyyymmdd,1)

        file_data_path = ['PV_',yyyymmdd(d,:),'.mat'];
        [~, ~, d_lfc_use, d_pv_error, d_lfc_use_30min, d_pv_error_30min, message_index] = analysis(fullfile(file_path,file_data_path));

        % figure(11);hold on;scatter(d_pv_error_30min,d_lfc_use_30min,'k.')
        % 
        % figure(12);hold on;plot(d_lfc_use, 'k', 'LineWidth', .5);plot(d_pv_error, 'r', 'LineWidth', .5)
        
        if find(message_index) == 1
            d_PV_error_30min_all(d,:) = d_pv_error_30min;
            d_lfc_use_30min_all(d,:) = d_lfc_use_30min;
        end
    end
end