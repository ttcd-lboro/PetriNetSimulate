clearvars
clc
addpath('..')

CaseDataMatName = 'CaseData-simpleExample2';
NComponents = 3;

%% Define failure times

failDatTable = table('Size',[NComponents,4],'VariableTypes',{'int16','double','double','double'},'VariableNames',{'DataType','MTTF','EtaOrMu','BetaOrSigma'});
failDatTable.Datatype = [0,0,0]'; %Probability distribution types: 0 for exponential,1 for weibull, 2 for normal, 3 for no data - assume ttf=1e9s
failDatTable.MTTF = [20,15,10]'; %any units valid as long as phase durations consistent in initialiser script (hours is typical)
failDatTable.EtaOrMu = [0,0,0]';
failDatTable.BetaOrSigma = [0,0,0]'; 

%% Define logic -
%Define connections between places and transitions for the (single) phase
%For unphased missions, there is only 1 A matrix, and so use A.A{1} for all entries
A.pIds{1} = [1:7]; %look at A-matrix for phase 1 and declare place IDs
A.tIds{1} = [1:4]; %look at A-matrix for phase 1 and declare transition IDs
A.Ain{1} = [-1,0,0,0,0,0,0;
    0,-1,0,0,0,0,0;
    0,0,-1,0,0,0,0;
    0,0,0,-1,-1,-1, 0;];  %A-matrix for phase 1

A.Aout{1} = [0,0,0,1,0,0,0;
    0,0,0,0,1,0,0;
    0,0,0,0,0,1,0;
    0,0,0,0,0,0, 1;];  %A-matrix for phase 1

ASubnet = [];% decalare there are no subnets

%% Check programming validity

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

%% Save and Plot

save(CaseDataMatName,'A','ASubnet','failDatTable')
PlotAllNetsNoRun
exportgraphics(gcf,[CaseDataMatName,'Petrinet.png'])