function [ComponentMTTF] = generateMTTF(failDatTable, warn)
    % Function to calculate MTTF for each component based on its failure data

    nComponents = height(failDatTable);
    ComponentMTTF = zeros(nComponents, 1);

    for c = 1:nComponents

        if failDatTable.Datatype(c) == 0 % Exponentially distributed
            % MTTF for exponential distribution is directly the provided MTTF
            ComponentMTTF(c) = failDatTable.MTTF(c);

        elseif failDatTable.Datatype(c) == 1 % Weibull distributed
            % MTTF for Weibull distribution: eta * Gamma(1 + 1/beta)
            eta = failDatTable.EtaOrMu(c); % Scale parameter
            beta = failDatTable.BetaOrSigma(c); % Shape parameter
            ComponentMTTF(c) = 8760 * eta * gamma(1 + 1 / beta); % Convert years to hours

        elseif failDatTable.Datatype(c) == 2 % Normally distributed
            % MTTF for normal distribution is the mean (mu or EtaOrMu here)
            mu = failDatTable.EtaOrMu(c); % Mean value
            ComponentMTTF(c) = max(mu, 0); % Ensure no negative MTTF values

        elseif failDatTable.Datatype(c) == 3 % No data present
            ComponentMTTF(c) = 1e9; % Assume very high MTTF
            if warn
                warning(['Component No. ', num2str(c), ' has no failure data - assuming MTTF = 1e9 s']);
            end
        end
    end

    % Check for invalid (negative) MTTFs
    if any(ComponentMTTF < 0)
        FailInd = find(ComponentMTTF < 0);
        error("Negative MTTFs detected for components: %s", mat2str(FailInd));
    end
end