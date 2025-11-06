clearvars -except poolobj
close all
clc
addpath('../')

%% Define simulation
Sim.SimTitle = 'SinglePhaseCase';
Sim.PhaseDurations = [1]; % Duration of each phase specified in hours (if component failure data is also in hours)
% Note that length of above vector defines number of phases
Sim.MaxNSims = 1e5;%  Number of missions to simulate
Sim.MaxSimTimeHrs = 10/60; % Max sim time in hours 
Sim.NComponents = 3; % Number of all components in the system
Sim.ConnectivityMatName = 'InputConnectivity-SinglePhaseCase';

%% Set Options
opts.nProcs = 1; % Number of computer processors to use for simulation
opts.debugNetByPlotting = false; % Can only be done if running on a single processor
opts.arbitraryFailureTimes = false; % Doesn't read the failure times matrix - just uses random times to allow debugging
opts.failureRateMultiplier = 1;% Increases rate of failures arbitrarily to allow quicker debugging
opts.showProgressBar = false; % Only works for parallel cases
opts.progressBarUpdatePeriod = 3; % Progress monitor updates every 3 seconds (example)
opts.saveAllVariables = false; % Save every simulation variable at end of simulation - normally only relevant variables are saved

%% Run Code
run PhasedPetriNetSimulator
for n=1:length(A.A)
    disp(['Phase ',num2str(n)])
    disp('A:')
    disp(size(A.A{n}))
    disp('pIds:')
    disp((A.pIds{n}))
    disp('tIds:')
    disp((A.tIds{n}))
end