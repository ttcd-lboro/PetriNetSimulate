%% Inputs

%InputConnectivityMatName = 'InputConnectivity-sophisticatedSim';%define InputConnectivityMatName

%% Code: Do not modify %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath('../')
myMatName = [CaseDataMatName,'.mat'];
myMatFile = matfile(myMatName); myMatFileVars = who(myMatFile);
load(myMatName,'A'); % read in A matrices for all phases with their associated (glboal) place and transition IDs.

%close all
figNo = 100;
sz = size(A.Ain);
multipleNets = (sz(1)*sz(2))>1;
if multipleNets
    if max(sz)>4
        nCols = ceil((1+max(sz))/3);
    else
        nCols = 2;
    end
    nRows = ceil((1+max(sz))/nCols);
end
%% Fig 1: Locally indexed nets
figure(figNo)
if multipleNets
    T1=tiledlayout(nRows,nCols,'TileSpacing','compact','Padding','compact');
else
    T1=gca;
end
for P=1:length(A.Ain)
    if multipleNets ; nexttile; end
    PlotNet(A.Ain{P},A.Aout{P},A.pIds{P},A.tIds{P},['Phase ',num2str(P)],figNo);
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
            PlotNet(ASubnets.Ain{SId},ASubnets.Aout{SId},ASubnets.pIds{SId},ASubnets.tIds{SId},['Subnet ',num2str(SId)],figNo);
        end
    end
    title(T2,'Subnet Petri Nets')
end

%% Fig 2: Globally indexed nets - (IF AGlobal already constructed by PetriNetSimulator)

if sum(contains(myMatFileVars,'AGlobal'))==1
    load(myMatName,'AGlobal')
    figNo=figNo+1;
    figure(figNo)
    if multipleNets
        T3=tiledlayout(nRows,nCols,'TileSpacing','compact','Padding','compact');
    else
        T3=gca;
    end
    % Plot global Nets (subnets included automaticly)
    for P=1:length(AGlobal.A)
        if multipleNets; nexttile; end
        PlotNet(AGlobal.Ain{P},AGlobal.Aout{P},AGlobal.pIds,AGlobal.tIds,[' in Phase ',num2str(P)],figNo);
    end
    title(T3,'Global Petri Nets in Each Phase')
end



