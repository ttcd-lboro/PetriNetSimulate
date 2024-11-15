%% Inputs

%InputConnectivityMatName = 'InputConnectivity-mySim1'; //define InputConnectivityMatName

%% Code: Do not modify %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath('../')
myMatName = [InputConnectivityMatName,'.mat'];
myMatFile = matfile(myMatName); myMatFileVars = who(myMatFile);
load(myMatName,'A'); % read in A matrices for all phases with their associated (glboal) place and transition IDs.

%close all
figNo = 100;
sz = size(A.A);
if max(sz)>4
    nCols = ceil((1+max(sz))/3);
else
    nCols = 2;
end
nRows = ceil((1+max(sz))/nCols);
figure(figNo)
T1=tiledlayout(nRows,nCols,'TileSpacing','compact','Padding','compact');


%% Fig 1: Locally indexed nets
for P=1:length(A.A)
    nexttile
    PlotNet(A.A{P},A.pIds{P},A.tIds{P},['Phase ',num2str(P)],figNo);
end

if sum(contains(myMatFileVars,'ASubnet'))==1
    load(myMatName,'ASubnet'); % read in A matrices for all phases with their associated (glboal) place and transition IDs.
    if ~isempty(ASubnet)
        nexttile
        PlotNet(ASubnet.A,ASubnet.pIds,ASubnet.tIds,'Subnet Petri Nets',figNo);
    end
end

title(T1,'Phase Petri Nets')

%% Fig 2: Globally indexed nets - (IF AGlobal already constructed by PetriNetSimulator)

if sum(contains(myMatFileVars,'AGlobal'))==1
    load(myMatName,'AGlobal')
    figNo=figNo+1;
    figure(figNo)
    T2=tiledlayout(nRows,nCols,'TileSpacing','compact','Padding','compact');
    
    % Plot global Nets (subnets included automaticly)
    for P=1:length(AGlobal.A)
        nexttile
        PlotNet(AGlobal.A{P},AGlobal.pIds,AGlobal.tIds,[' in Phase ',num2str(P)],figNo);
    end
    title(T2,'Global Petri Nets in Each Phase')
end


   
