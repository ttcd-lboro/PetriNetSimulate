InputConnectivityMatName = 'InputConnectivity-mySim1';


load(['../',InputConnectivityMatName,'.mat'],'A','AHydraulicsSubnet'); % read in A matrices for all phases with their associated (glboal) place and transition IDs.
addpath('../')

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
    PlotNet(A.A{P},A.pIds{P},A.tIds{P},['Local Petri Nets in Phase ',num2str(P)],figNo);
end
nexttile 
PlotNet(AHydraulicsSubnet.A,AHydraulicsSubnet.pIds,AHydraulicsSubnet.tIds,['Hydraulics Subnet Petri Nets'],figNo);



%% Fig 2: Globally indexed nets - (IF AGlobal already constructed by PetriNetSimulator)
load(['../',InputConnectivityMatName,'.mat'],'A','AHydraulicsSubnet','AGlobal')
if exist('AGlobal','var')
    figNo=figNo+1;
    figure(figNo)
    T2=tiledlayout(nRows,nCols,'TileSpacing','compact','Padding','compact');
    
    % Plot global Nets (subnets included automaticly)
    for P=1:length(A.A)
        nexttile
        PlotNet(AGlobal.A{P},AGlobal.pIds,AGlobal.tIds,['Global Petri Nets in Phase ',num2str(P)],figNo);
    end
end


   
