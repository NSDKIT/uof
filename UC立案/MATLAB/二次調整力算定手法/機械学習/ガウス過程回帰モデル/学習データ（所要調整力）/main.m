close all;clear

d_PV_error_30min_all = [];
d_lfc_use_30min_all = [];

for mm = [12]
    if mm <= 2
        yyyy = 2020;
    else
        yyyy = 2019;
    end
    % % 年と月を指定
    % yyyy = 2019;
    % mm = 8;

    % データの集計と解析(analysis.m)
    [d_PV_error_30min_all_mm, d_lfc_use_30min_all_mm] = gather(yyyy,mm);

    d_PV_error_30min_all = [d_PV_error_30min_all; d_PV_error_30min_all_mm];
    d_lfc_use_30min_all = [d_lfc_use_30min_all; d_lfc_use_30min_all_mm];
    
    % figure(11);title('予測誤差(xaxis) vs 調整力利用量(yaxis)')
    % figure(12);title('予測誤差(red) vs 調整力利用量(black)')
end

[r,l] = find(d_lfc_use_30min_all>2000);
d_PV_error_30min_all(r,:) = [];
d_lfc_use_30min_all(r,:) = [];

%% 統計解析
data = d_lfc_use_30min_all;

% 各列の平均値を計算
column_means = mean(data);

% 各列の標準偏差を計算
column_variances = std(data);