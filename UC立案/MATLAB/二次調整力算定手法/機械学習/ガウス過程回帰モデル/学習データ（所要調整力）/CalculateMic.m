function mic = CalculateMic(X, Y, max_bins)
    % X and Y are the data vectors.
    % max_bins is the maximum number of bins to consider.

    n = length(X);
    mic = 0;  % Initialize the MIC value.

    % Iterate over number of bins from 2 up to max_bins
    for b = 2:max_bins
        % Create grid
        x_edges = linspace(min(X), max(X), b);
        y_edges = linspace(min(Y), max(Y), b);

        % Bin the data
        x_binned = discretize(X, x_edges);
        y_binned = discretize(Y, y_edges);

        % Calculate joint and marginal probabilities
        joint_prob = accumarray([x_binned, y_binned], 1, [b, b]) / n;
        x_prob = sum(joint_prob, 2);
        y_prob = sum(joint_prob, 1)';

        % Calculate mutual information
        MI = 0;
        for i = 1:b
            for j = 1:b
                if joint_prob(i, j) > 0
                    MI = MI + joint_prob(i, j) * log2(joint_prob(i, j) / (x_prob(i) * y_prob(j)));
                end
            end
        end

        % Normalize and update MIC if this is the highest value found
        norm_MI = MI / log2(min(b, b));
        if norm_MI > mic
            mic = norm_MI;
        end
    end
end