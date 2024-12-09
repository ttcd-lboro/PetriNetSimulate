clearvars
clc
addpath('..')

dataPath = 'RawInputData';
InputConnectivityMatName = 'InputConnectivity-stockwellSim'; 

%% Read component Data
failDatTable = readtable([dataPath,'/ComponentFailureData.xlsx'], 'Range', 'G1:J23');
NPhases = 4;
NSubnets = 1;

%% Read A matrices, place IDs and transition IDs

P=1;
A.A{P} = readmatrix([dataPath,'/A-Phase-1.xlsx'],'Range','G3:L7');
A.pIds{P} = readmatrix([dataPath,'/A-Phase-1.xlsx'],'Range','G2:L2');
A.tIds{P} = readmatrix([dataPath,'/A-Phase-1.xlsx'],'Range','F3:F7');

P=2;
A.A{P} = readmatrix([dataPath,'/A-Phase-2.xlsx'],'Range','G3:S14');
A.pIds{P} = readmatrix([dataPath,'/A-Phase-2.xlsx'],'Range','G2:S2');
A.tIds{P} = readmatrix([dataPath,'/A-Phase-2.xlsx'],'Range','F3:F14');

P=3;
A.A{P} = readmatrix([dataPath,'/A-Phase-3.xlsx'],'Range','G3:K6');
A.pIds{P} = readmatrix([dataPath,'/A-Phase-3.xlsx'],'Range','G2:K2');
A.tIds{P} = readmatrix([dataPath,'/A-Phase-3.xlsx'],'Range','F3:F6');

P=4;
A.A{P} = readmatrix([dataPath,'/A-Phase-4.xlsx'],'Range','G3:K6');
A.pIds{P} = readmatrix([dataPath,'/A-Phase-4.xlsx'],'Range','G2:K2');
A.tIds{P} = readmatrix([dataPath,'/A-Phase-4.xlsx'],'Range','F3:F6');

ASubnets.A{1} = [];
ASubnets.pIds{1} = []; 
ASubnets.tIds{1} = []; 

for n=1:length(A.A)
    A.A{n}(isnan(A.A{n})) = 0;
end

%% Define links between component net output places and phase net places input places for token copying
ComponentNetToPhaseNetIDs_allPhasesRaw{1} = readmatrix([dataPath,'/A-Phase-1.xlsx'],'Range','Y2:Z100');
ComponentNetToPhaseNetIDs_allPhasesRaw{2} = readmatrix([dataPath,'/A-Phase-2.xlsx'],'Range','AC2:AD100');
ComponentNetToPhaseNetIDs_allPhasesRaw{3} = readmatrix([dataPath,'/A-Phase-3.xlsx'],'Range','N2:O100');
ComponentNetToPhaseNetIDs_allPhasesRaw{4} = readmatrix([dataPath,'/A-Phase-4.xlsx'],'Range','AB2:AC100');

%SubnetToPhaseNetIDsRaw{1} = readmatrix([dataPath,'/A-Subnet-1.xlsx'],'Range','T2:U100');
%SubnetToPhaseNetIDsRaw{2} = readmatrix([dataPath,'/A-Subnet-2.xlsx'],'Range','T2:U100');

%% Process Links
ComponentNetToPhaseNetIDs_allPhases = cell(size(ComponentNetToPhaseNetIDs_allPhasesRaw));
for P=1:NPhases
    ComponentNetToPhaseNetIDs_allPhases{P}(:,1) = ComponentNetToPhaseNetIDs_allPhasesRaw{P}(~isnan(ComponentNetToPhaseNetIDs_allPhasesRaw{P}(:,1)),1);
    ComponentNetToPhaseNetIDs_allPhases{P}(:,2) = ComponentNetToPhaseNetIDs_allPhasesRaw{P}(~isnan(ComponentNetToPhaseNetIDs_allPhasesRaw{P}(:,2)),2); 
end

%% Process A Matrices
%Verify readin
nerrors = 0;
for P=1:NPhases
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
    save([InputConnectivityMatName,'.mat'],'failDatTable','A','ComponentNetToPhaseNetIDs_allPhases','ComponentNetToPhaseNetIDs_allPhases','ASubnets')
end

%% Save and Plot
PlotAllNetsNoRun
exportgraphics(gcf,[InputConnectivityMatName,'_phasePNs.png'])
