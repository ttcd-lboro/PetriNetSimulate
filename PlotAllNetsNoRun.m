%% Inputs

%InputConnectivityMatName = 'InputConnectivity-sophisticatedSim';%define InputConnectivityMatName

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

%% Fig 1: Locally indexed nets
figure(figNo)
T1=tiledlayout(nRows,nCols,'TileSpacing','compact','Padding','compact');

for P=1:length(A.A)
    nexttile
    PlotNet(A.A{P},A.pIds{P},A.tIds{P},['Phase ',num2str(P)],figNo);
end
title(T1,'Phase Petri Nets')

if sum(contains(myMatFileVars,'ASubnets'))==1
    figNo=figNo+1;
    figure(figNo)
    T2=tiledlayout(nRows,nCols,'TileSpacing','compact','Padding','compact');
    load(myMatName,'ASubnets'); % read in A matrices for all phases with their associated (glboal) place and transition IDs.
    if ~isempty(ASubnets)
        for SId=1:length(ASubnets.A)
            nexttile
            PlotNet(ASubnets.A{SId},ASubnets.pIds{SId},ASubnets.tIds{SId},['Subnet ',num2str(SId)],figNo);
        end
    end
    title(T2,'Subnet Petri Nets')
end

%% Fig 2: Globally indexed nets - (IF AGlobal already constructed by PetriNetSimulator)

if sum(contains(myMatFileVars,'AGlobal'))==1
    load(myMatName,'AGlobal')
    figNo=figNo+1;
    figure(figNo)
    T3=tiledlayout(nRows,nCols,'TileSpacing','compact','Padding','compact');
    
    % Plot global Nets (subnets included automaticly)
    for P=1:length(AGlobal.A)
        nexttile
        PlotNet(AGlobal.A{P},AGlobal.pIds,AGlobal.tIds,[' in Phase ',num2str(P)],figNo);
    end
    title(T3,'Global Petri Nets in Each Phase')
end


   
