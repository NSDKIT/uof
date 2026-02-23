function K = gaussian_kernel(X1, X2, sigma)
    % X1: N1 x D 行列 (N1はデータポイント数, Dは特徴量の次元数)
    % X2: N2 x D 行列 (N2はデータポイント数, Dは特徴量の次元数)
    % sigma: ガウシアンカーネルの幅パラメータ
    
    % カーネル行列の初期化
    N1 = size(X1, 1);
    N2 = size(X2, 1);
    K = zeros(N1, N2);
    
    % ガウシアンカーネル行列の計算
    for i = 1:N1
        for j = 1:N2
            K(i, j) = exp(-norm(X1(i, :) - X2(j, :))^2 / (2 * sigma^2));
        end
    end
end