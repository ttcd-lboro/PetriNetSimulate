function [ComponentTTF] = GenerateTimesToFailure(failDatTable,warn)
nComponents=height(failDatTable);
ComponentTTF = zeros(nComponents,1);
for c=1:nComponents
    
    if failDatTable.Datatype(c) == 0 %exponentially distributed
        ComponentTTF(c)= -failDatTable.MTTF(c)*log(rand);
        
    elseif failDatTable.Datatype(c) == 1 %weibul distributed
        ComponentTTF(c)= 8760*failDatTable.EtaOrMu(c)*(-log(rand))^(1/failDatTable.BetaOrSigma(c));
        %8760 is number of years
        
    elseif failDatTable.Datatype(c) == 2 %normally distributed
        y=0;
        for i = 1:12
            y=y+rand;
        end
        ComponentTTF(c) = failDatTable.BetaOrSigma(c)*(y-6) + failDatTable.EtaOrMu(c);
        if ComponentTTF(c)<0
            ComponentTTF(c)=0; % A fix to account set negative failure times to just fail immediately
        end
        
    elseif failDatTable.Datatype(c) == 3 % no data present
        ComponentTTF(c)=1e9;
        if warn
            warning(['Component No. ',num2str(c),' has no failure data - assuming time to failure = 1e9 s'])
        end
        
    end
    
end

if sum(ComponentTTF<0)>0
    FailInd = find(ComponentTTF<0)
    ComponentTTF(FailInd)
    error("Negative time to failures")
end

end
