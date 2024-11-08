clearvars
clc
addpath('..')

dataPath = 'RawInputData';
InputConnectivityMatName = 'InputConnectivity-sophisticatedSim'; 

%% Read component Data
failDatTable = readtable([dataPath,'/ComponentFailureData.xlsx'], 'Range', 'G1:J41');

%% Define links between component net output places and phase net places input places for token copying

ComponentNetToPhaseNetIDs_allPhasesRaw{1} = readmatrix([dataPath,'/A-Phase-1.xlsx'],'Range','Y2:Z100');
ComponentNetToPhaseNetIDs_allPhasesRaw{2} = readmatrix([dataPath,'/A-Phase-2.xlsx'],'Range','AP2:AQ100');
ComponentNetToPhaseNetIDs_allPhasesRaw{3} = readmatrix([dataPath,'/A-Phase-3.xlsx'],'Range','N2:O100');
ComponentNetToPhaseNetIDs_allPhasesRaw{4} = readmatrix([dataPath,'/A-Phase-4.xlsx'],'Range','AS2:AT100');
ComponentNetToPhaseNetIDs_allPhasesRaw{5} = readmatrix([dataPath,'/A-Phase-5.xlsx'],'Range','AI2:AJ100');

for P=1:5
    ComponentNetToPhaseNetIDs_allPhases{P}(:,1) = ComponentNetToPhaseNetIDs_allPhasesRaw{P}(~isnan(ComponentNetToPhaseNetIDs_allPhasesRaw{P}(:,1)),1);
    ComponentNetToPhaseNetIDs_allPhases{P}(:,2) = ComponentNetToPhaseNetIDs_allPhasesRaw{P}(~isnan(ComponentNetToPhaseNetIDs_allPhasesRaw{P}(:,2)),2); 
end

SubnetToPhaseNetIDsRaw = readmatrix([dataPath,'/A-Subnets.xlsx'],'Range','T2:U100');
SubnetToPhaseNetIDs(:,1) = SubnetToPhaseNetIDsRaw(~isnan(SubnetToPhaseNetIDsRaw(:,1)),1);
SubnetToPhaseNetIDs(:,2) = SubnetToPhaseNetIDsRaw(~isnan(SubnetToPhaseNetIDsRaw(:,2)),2);
%append subnet transfer place ids to component transfer place ids list

for P=1:5
    ComponentNetToPhaseNetIDs_allPhases{P} = [ComponentNetToPhaseNetIDs_allPhases{P};SubnetToPhaseNetIDs]; 
end

%% Read A matrices, place IDs and transition IDs

P=1;
A.A{P} = readmatrix([dataPath,'/A-Phase-1.xlsx'],'Range','G3:R11');
A.pIds{P} = readmatrix([dataPath,'/A-Phase-1.xlsx'],'Range','G2:R2');
A.tIds{P} = readmatrix([dataPath,'/A-Phase-1.xlsx'],'Range','F3:F11');

P=2;
A.A{P} = readmatrix([dataPath,'/A-Phase-2.xlsx'],'Range','G3:AM28');
A.pIds{P} = readmatrix([dataPath,'/A-Phase-2.xlsx'],'Range','G2:AM2');
A.tIds{P} = readmatrix([dataPath,'/A-Phase-2.xlsx'],'Range','F3:F28');

P=3;
A.A{P} = readmatrix([dataPath,'/A-Phase-3.xlsx'],'Range','G3:K5');
A.pIds{P} = readmatrix([dataPath,'/A-Phase-3.xlsx'],'Range','G2:K2');
A.tIds{P} = readmatrix([dataPath,'/A-Phase-3.xlsx'],'Range','F3:F5');

P=4;
A.A{P} = readmatrix([dataPath,'/A-Phase-4.xlsx'],'Range','G3:AQ31');
A.pIds{P} = readmatrix([dataPath,'/A-Phase-4.xlsx'],'Range','G2:AQ2');
A.tIds{P} = readmatrix([dataPath,'/A-Phase-4.xlsx'],'Range','F3:F31');

P=5;
A.A{P} = readmatrix([dataPath,'/A-Phase-5.xlsx'],'Range','G3:AB20');
A.pIds{P} = readmatrix([dataPath,'/A-Phase-5.xlsx'],'Range','G2:AB2');
A.tIds{P} = readmatrix([dataPath,'/A-Phase-5.xlsx'],'Range','F3:F20');

ASubnet.A = readmatrix([dataPath,'/A-Subnets.xlsx'],'Range','G3:R10');
ASubnet.pIds = readmatrix([dataPath,'/A-Subnets.xlsx'],'Range','G2:R2');
ASubnet.tIds = readmatrix([dataPath,'/A-Subnets.xlsx'],'Range','F3:F10');

%% Process
%Verify readin
nerrors = 0;
for P=1:5
    if sum(isnan(A.A{P}))>0
        disp(['Issue with A matrix for phase ',num2str(P),'. Check A excel readin indices'])
        nerrors = nerrors +1;
    end
    if sum(isnan(A.pIds{P}))>0
        disp(['Issue with place ids matrix for phase ',num2str(P),'. Check A excel readin indices'])
        nerrors = nerrors +1;
    end
    if sum(isnan(A.tIds{P}))>0
        disp(['Issue with transition ids for phase ',num2str(P),'. Check A excel readin indices'])
        nerrors = nerrors +1;
    end
end

for i = 1:length(A.A)
    [nTrans,nPlaces] = size(A.A{i});
    if numel(A.pIds{i})~= nPlaces
        error('Number of Place IDs and number of places in A-matrix do not allign')
    elseif   numel(A.tIds{i})~= nTrans
        error('Number of Tranition IDs and number of transitions in A-matrix do not allign')
    end
end

%% Check read in
if nerrors>0
    error(['Checks complete - ', num2str(nerrors), ' errors found'])
else
    disp('Checks complete - read in successful')
    save([InputConnectivityMatName,'.mat'],'failDatTable','A','ComponentNetToPhaseNetIDs_allPhases','ComponentNetToPhaseNetIDs_allPhases','ASubnet')
end

%% Save and Plot
PlotAllNetsNoRun
exportgraphics(gcf,[InputConnectivityMatName,'_phasePNs.png'])
