clearvars
clc
addpath('..')

dataPath = 'RawInputData';
CaseDataMatName = 'CaseData-repairableExample'; 

%% Read component Data
failDatTable = readtable([dataPath,'/ComponentFailureData.xlsx'], 'Range', 'G1:M3');
repairRateTable = readtable([dataPath,'/RepairRateData.xlsx'], 'Range', 'A1:B3');
InitMarking = readmatrix([dataPath,'/InitialMarking.xlsx'], 'Range', 'A2:A4');
NPhases = 1;
NSubnets = 0;

%% Read A matrices, place IDs and transition IDs
P=1;
A.Ain{P} = readmatrix([dataPath,'/Ain.xlsx'],'Range','G3:M10');
A.Aout{P} = readmatrix([dataPath,'/Aout.xlsx'],'Range','G3:M10');
A.pIds{P} = readmatrix([dataPath,'/Ain.xlsx'],'Range','G2:M2');
A.tIds{P} = readmatrix([dataPath,'/Aout.xlsx'],'Range','F3:F10');

%% Process A Matrices
%Verify readin
nerrors = 0;
for P=1:NPhases
    if any(A.Ain{P}>0)
        error('Output arcs declared in Ain')
    elseif any(A.Aout{P}<0)
        error('Input arcs declared in Aout')
    end
    if any(isnan(A.Ain{P}),'all')||any(isnan(A.Aout{P}),'all')
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

for i = 1:length(A.Ain)
    [nTrans,nPlaces] = size(A.Ain{i});
    if any(A.Ain{i}>0)
        error('Output arcs declared in Ain')
    elseif any(A.Aout{i}<0)
        error('Input arcs declared in Aout')
    end
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
    save([CaseDataMatName,'.mat'],'failDatTable','repairRateTable','InitMarking','A')
end

%% Save and Plot
PlotAllNetsNoRun
%layout(get(gca,'Children'),'auto') %options for better layout of places:
%'auto','circle','force','layered','subspace','force3','subspace3'
%default is layout(get(gca,'Children'),'layered','Direction','up')
exportgraphics(gcf,[CaseDataMatName,'_phasePNs.png'])
