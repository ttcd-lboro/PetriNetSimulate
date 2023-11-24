clearvars
clc
InputConnectivityMatName = 'InputConnectivity-exampleSim';
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
ComponentNetToPhaseNetIDs_allPhases{1}(:,2) = (10:12); % phase net input places

%Phase 2
ComponentNetToPhaseNetIDs_allPhases{2}(:,1) = (4:6); % component net output places
ComponentNetToPhaseNetIDs_allPhases{2}(:,2) = (14:16); % phase net input places

%Phase 3
ComponentNetToPhaseNetIDs_allPhases{3}(:,1) = (4:6); % component net output places
ComponentNetToPhaseNetIDs_allPhases{3}(:,2) = (19:21); % phase net input places

%% Define logic
%Phase 1
A.pIds{1} = (10:13); %look at A-matrix for phase 1 and insert place IDs
A.tIds{1} = 4; %look at A-matrix for phase 1 and insert transitions IDs
A.A{1} = [-1,-1,-1, 1];  %A-matrix for phase 1

%Phase 2
A.pIds{2} = (14:18); %look at A-matrix for phase 2 and insert place IDs
A.tIds{2} = [5,6]; %look at A-matrix for phase 2 and insert transitions IDs
A.A{2} = [0,-1,-1,1,0; -1,0,0,-1,1]; %A-matrix for phase 2

%Phase 3
A.pIds{3} = (19:22); %look at A-matrix for phase 3 and insert place IDs
A.tIds{3} = (7:9); %look at A-matrix for phase 3 and insert transitions IDs
A.A{3} = [-1,0,0,1;0,-1,0,1;0,0,-1,1]; %A-matrix for phase 3

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
try 
    plotAllNetsNoRun
catch
    addpath('additionalTools')
    plotAllNetsNoRun
end
exportgraphics(gcf,[InputConnectivityMatName,'_phasePNs.png'])