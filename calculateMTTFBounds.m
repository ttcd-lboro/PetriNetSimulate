function [lambda_lower,lambda_upper] = calculateMTTFBounds(F, T, alpha, failDatTable)
% Inputs:
% F(c): Total failures observed (scalar)
% T: Total mission duration (scalar)
% alpha: Significance level (e.g., 0.05 for 95% confidence)
% flag: Distribution flag
nComponents=height(failDatTable);
lambda_lower = zeros(nComponents,1);
lambda_upper = lambda_lower;

for c=1:nComponents
    flag = failDatTable.Datatype(c);
    switch flag
        case 0 % Exponential Distribution
            lambda = F(c) / T;
            lambda_lower(c) = chi2inv(alpha/2, 2*F(c)) / (2 * T);
            lambda_upper(c) = chi2inv(1 - alpha/2, 2*(F(c)+1)) / (2 * T);
        case 1 % Weibull Distribution
            error('Not fully implemented')
            % Example parameters (beta, eta) for demonstration
            beta = 1.5; % Shape parameter
            eta = T / (F(c)^beta); % Scale parameter
            lambda = (beta / eta) * (T / eta)^(beta - 1);
            % Approximate confidence bounds (complex to compute exactly)
            % Confidence bounds require parametric bootstrap or MLE intervals
        case 2 % Normal Distribution
            % Assuming mean and standard deviation of failure times
            mu = T / F(c); % Mean time to failure
            sigma = sqrt(mu); % Adjust based on data (example: proportional to mean)
            z = norminv(1 - alpha/2); % Z-score for confidence
            lambda = F(c) / T;
            lambda_lower(c) = lambda - z * (sigma / sqrt(F(c)));
            lambda_upper(c) = lambda + z * (sigma / sqrt(F(c)));

    end
end
