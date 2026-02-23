% 列数（要素数）を指定
column_count = size(data4,2);

% 切り出す列数を指定
chunk_size = 1800;

% 切り出した結果を格納するための変数を初期化
max_values = [];

% 列ごとに最大値を計算
for i = 1:chunk_size:column_count
    % 切り出す範囲を指定
    start_index = i;
    end_index = min(i + chunk_size - 1, column_count);
    
    % 切り出した部分行列の最大値を計算
    chunk = data4(start_index:end_index);
    max_value = max(chunk);
    
    % 結果を保存
    max_values = [max_values, max_value];
end