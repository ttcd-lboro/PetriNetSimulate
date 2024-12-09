clearvars
clc
addpath('..')

dataPath = 'RawInputData';
InputConnectivityMatName = 'InputConnectivity-sophisticatedSim'; 

%% Read component Data
failDatTable = readtable([dataPath,'/ComponentFailureData.xlsx'], 'Range', 'G1:J41');
NPhases = 5;
NSubnets = 2;

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

ASubnets.A{1} = readmatrix([dataPath,'/A-Subnet-1.xlsx'],'Range','G3:J5');
ASubnets.pIds{1} = readmatrix([dataPath,'/A-Subnet-1.xlsx'],'Range','G2:J2');
ASubnets.tIds{1} = readmatrix([dataPath,'/A-Subnet-1.xlsx'],'Range','F3:F5');

ASubnets.A{2} = readmatrix([dataPath,'/A-Subnet-2.xlsx'],'Range','G3:N7');
ASubnets.pIds{2} = readmatrix([dataPath,'/A-Subnet-2.xlsx'],'Range','G2:N2');
ASubnets.tIds{2} = readmatrix([dataPath,'/A-Subnet-2.xlsx'],'Range','F3:F7');

%% Define links between component net output places and phase net places input places for token copying
ComponentNetToPhaseNetIDs_allPhasesRaw{1} = readmatrix([dataPath,'/A-Phase-1.xlsx'],'Range','Y2:Z100');
ComponentNetToPhaseNetIDs_allPhasesRaw{2} = readmatrix([dataPath,'/A-Phase-2.xlsx'],'Range','AP2:AQ100');
ComponentNetToPhaseNetIDs_allPhasesRaw{3} = readmatrix([dataPath,'/A-Phase-3.xlsx'],'Range','N2:O100');
ComponentNetToPhaseNetIDs_allPhasesRaw{4} = readmatrix([dataPath,'/A-Phase-4.xlsx'],'Range','AS2:AT100');
ComponentNetToPhaseNetIDs_allPhasesRaw{5} = readmatrix([dataPath,'/A-Phase-5.xlsx'],'Range','AI2:AJ100');

SubnetToPhaseNetIDsRaw{1} = readmatrix([dataPath,'/A-Subnet-1.xlsx'],'Range','T2:U100');
SubnetToPhaseNetIDsRaw{2} = readmatrix([dataPath,'/A-Subnet-2.xlsx'],'Range','T2:U100');

%% Process Links
ComponentNetToPhaseNetIDs_allPhases = cell(size(ComponentNetToPhaseNetIDs_allPhasesRaw));
SubnetToPhaseNetIDs = cell(size(SubnetToPhaseNetIDsRaw));

for P=1:NPhases
    ComponentNetToPhaseNetIDs_allPhases{P}(:,1) = ComponentNetToPhaseNetIDs_allPhasesRaw{P}(~isnan(ComponentNetToPhaseNetIDs_allPhasesRaw{P}(:,1)),1);
    ComponentNetToPhaseNetIDs_allPhases{P}(:,2) = ComponentNetToPhaseNetIDs_allPhasesRaw{P}(~isnan(ComponentNetToPhaseNetIDs_allPhasesRaw{P}(:,2)),2); 
end
for SId=1:NSubnets
    SubnetToPhaseNetIDs{SId}(:,1) = SubnetToPhaseNetIDsRaw{SId}(~isnan(SubnetToPhaseNetIDsRaw{SId}(:,1)),1);
    SubnetToPhaseNetIDs{SId}(:,2) = SubnetToPhaseNetIDsRaw{SId}(~isnan(SubnetToPhaseNetIDsRaw{SId}(:,2)),2);
end

%append subnet transfer place ids to component transfer place ids list
for P=1:NPhases
    for SId=1:NSubnets
        ComponentNetToPhaseNetIDs_allPhases{P} = [ComponentNetToPhaseNetIDs_allPhases{P};SubnetToPhaseNetIDs{SId}];
    end
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
