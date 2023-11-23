
%% Read component Data
dataPath = '../RawInputData';
outMatTitle = '../InputConnectivity-mySim1'; 
failDatTable = readtable([dataPath,'/ComponentFailureData.xlsx'], 'Range', 'G1:J41');


%% Read A matrices, place IDs and transition IDs

n=1;
A.A{n} = readmatrix([dataPath,'/A-Phase-1.xlsx'],'Range','G3:R11');
A.pIds{n} = readmatrix([dataPath,'/A-Phase-1.xlsx'],'Range','G2:R2');
A.tIds{n} = readmatrix([dataPath,'/A-Phase-1.xlsx'],'Range','F3:F11');

n=2;
A.A{n} = readmatrix([dataPath,'/A-Phase-2.xlsx'],'Range','G3:AM28');
A.pIds{n} = readmatrix([dataPath,'/A-Phase-2.xlsx'],'Range','G2:AM2');
A.tIds{n} = readmatrix([dataPath,'/A-Phase-2.xlsx'],'Range','F3:F28');

n=3;
A.A{n} = readmatrix([dataPath,'/A-Phase-3.xlsx'],'Range','G3:K5');
A.pIds{n} = readmatrix([dataPath,'/A-Phase-3.xlsx'],'Range','G2:K2');
A.tIds{n} = readmatrix([dataPath,'/A-Phase-3.xlsx'],'Range','F3:F5');

n=4;
A.A{n} = readmatrix([dataPath,'/A-Phase-4.xlsx'],'Range','G3:AQ31');
A.pIds{n} = readmatrix([dataPath,'/A-Phase-4.xlsx'],'Range','G2:AQ2');
A.tIds{n} = readmatrix([dataPath,'/A-Phase-4.xlsx'],'Range','F3:F31');

n=5;
A.A{n} = readmatrix([dataPath,'/A-Phase-5.xlsx'],'Range','G3:AB20');
A.pIds{n} = readmatrix([dataPath,'/A-Phase-5.xlsx'],'Range','G2:AB2');
A.tIds{n} = readmatrix([dataPath,'/A-Phase-5.xlsx'],'Range','F3:F20');

AHydraulicsSubnet.A = readmatrix([dataPath,'/A-HydraulicsSubnets.xlsx'],'Range','G3:R10');
AHydraulicsSubnet.pIds = readmatrix([dataPath,'/A-HydraulicsSubnets.xlsx'],'Range','G2:R2');
AHydraulicsSubnet.tIds = readmatrix([dataPath,'/A-HydraulicsSubnets.xlsx'],'Range','F3:F10');


ComponentNetOutputPlaces_allPhases{1} = readmatrix([dataPath,'/A-Phase-1.xlsx'],'Range','Z2:Z100');
ComponentNetInputPlaces_allPhases{1} = readmatrix([dataPath,'/A-Phase-1.xlsx'],'Range','Y2:Y100');

ComponentNetOutputPlaces_allPhases{2} = readmatrix([dataPath,'/A-Phase-2.xlsx'],'Range','AQ2:AQ100');
ComponentNetInputPlaces_allPhases{2} = readmatrix([dataPath,'/A-Phase-2.xlsx'],'Range','AP2:AP100');

ComponentNetOutputPlaces_allPhases{3} = readmatrix([dataPath,'/A-Phase-3.xlsx'],'Range','O2:O100');
ComponentNetInputPlaces_allPhases{3} = readmatrix([dataPath,'/A-Phase-3.xlsx'],'Range','N2:N100');

ComponentNetOutputPlaces_allPhases{4} = readmatrix([dataPath,'/A-Phase-4.xlsx'],'Range','AT2:AT100');
ComponentNetInputPlaces_allPhases{4} = readmatrix([dataPath,'/A-Phase-4.xlsx'],'Range','AS2:AS100');

ComponentNetOutputPlaces_allPhases{5} = readmatrix([dataPath,'/A-Phase-5.xlsx'],'Range','AJ2:AJ100');
ComponentNetInputPlaces_allPhases{5} = readmatrix([dataPath,'/A-Phase-5.xlsx'],'Range','AI2:AI100');

SubnetOutputNetPlaceNos = readmatrix([dataPath,'/A-HydraulicsSubnets.xlsx'],'Range','Z2:Z100');
SubnetInputNetPlaceNos = readmatrix([dataPath,'/A-HydraulicsSubnets.xlsx'],'Range','Y2:Y100');
SubnetOutputNetPlaceNos = SubnetOutputNetPlaceNos(~isnan(SubnetOutputNetPlaceNos));
SubnetInputNetPlaceNos = SubnetInputNetPlaceNos(~isnan(SubnetInputNetPlaceNos));

%% Process
%Verify readin
nerrors = 0;
for n=1:5
    if sum(isnan(A.A{n}))>0
        disp(['Issue with A matrix for phase ',num2str(n),'. Check A excel readin indices'])
        nerrors = nerrors +1;
    end
    if sum(isnan(A.pIds{n}))>0
        disp(['Issue with place ids matrix for phase ',num2str(n),'. Check A excel readin indices'])
        nerrors = nerrors +1;
    end
    if sum(isnan(A.tIds{n}))>0
        disp(['Issue with transition ids for phase ',num2str(n),'. Check A excel readin indices'])
        nerrors = nerrors +1;
    end
end


for n=1:5
    ComponentNetOutputPlaces_allPhases{n} = ComponentNetOutputPlaces_allPhases{n}(~isnan(ComponentNetOutputPlaces_allPhases{n}));
    ComponentNetInputPlaces_allPhases{n} = ComponentNetInputPlaces_allPhases{n}(~isnan(ComponentNetInputPlaces_allPhases{n}));
    
    ComponentNetOutputPlaces_allPhases{n} = [ComponentNetOutputPlaces_allPhases{n},SubnetOutputNetPlaceNos]; 
    ComponentNetInputPlaces_allPhases{n} = [ComponentNetInputPlaces_allPhases{n},SubnetInputNetPlaceNos]; 
end

%% Check read in
if nerrors>0
    error(['Checks complete - ', num2str(nerrors), ' errors found'])
else
    disp('Checks complete - read in successful')
    save([outMatTitle,'.mat'],'failDatTable','A','ComponentNetInputPlaces_allPhases','ComponentNetOutputPlaces_allPhases','AHydraulicsSubnet')
end
clearvars
