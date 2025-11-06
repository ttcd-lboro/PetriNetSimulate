clearvars
clc
addpath('..')

InputConnectivityMatName = 'InputConnectivity-SinglePhaseCase';
NComponents = 3;

%% Define failure times

failDatTable = table('Size',[NComponents,4],'VariableTypes',{'int16','double','double','double'},'VariableNames',{'DataType','MTTF','EtaOrMu','BetaOrSigma'});
failDatTable.Datatype = [0,0,0]'; %Probability distribution types: 0 for exponential,1 for weibull, 2 for normal, 3 for no data - assume ttf=1e9s
failDatTable.MTTF = [20,15,10]'; %any units valid as long as phase durations consistent in initialiser script (hours is typical)
failDatTable.EtaOrMu = [0,0,0]';
failDatTable.BetaOrSigma = [0,0,0]'; 

%% Define links between component net output places and phase net places input places for token copying
%Phase 1    
ComponentNetToPhaseNetIDs_allPhases{1}(:,1) = (4:6); % component net output places
ComponentNetToPhaseNetIDs_allPhases{1}(:,2) = (10:12); % phase net input places (starts arbitrarily at 10 since closest round number after component net numbering (1:3)

%% Define logic
%Define connections between places and transitions for the (single) phase
A.pIds{1} = (10:13); %look at A-matrix for phase 1 and insert place IDs (starts arbitrarily at 10 since closest round number after component net numbering (1:3)
A.tIds{1} = 4; %look at A-matrix for phase 1 and insert transitions IDs
A.A{1} = [-1,-1,-1, 1];  %A-matrix for phase 1

ASubnet = [];% decalare there are no subnets

%% Check programming validity

for i = 1:length(A.A)
    [nTrans,nPlaces] = size(A.A{i});
    if numel(A.pIds{i})~= nPlaces
        error('Number of Place IDs and number of places in A-matrix do not allign')
    elseif   numel(A.tIds{i})~= nTrans
        error('Number of Tranition IDs and number of transitions in A-matrix do not allign')
    end
end

%% Save and Plot

save(InputConnectivityMatName,'A','ASubnet','failDatTable','ComponentNetToPhaseNetIDs_allPhases')
PlotAllNetsNoRun
exportgraphics(gcf,[InputConnectivityMatName,'_phasePNs.png'])