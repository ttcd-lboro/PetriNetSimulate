clearvars -except poolobj
close all
clc

%% Define simulation
Sim.SimTitle = 'mySim1';
Sim.PhaseDurations = [3/60,1/60,1.7166,1/60,3/60]; % Duration of each phase specified in hours (if component failure data is also in hours)

Sim.MaxNSims = 5e5;%  Number of missions to simulate
Sim.MaxSimTimeHrs = 0.05; % max sim time in hours
Sim.NComponents = 40; % Number of all components in the system
Sim.ConnectivityMatName = 'InputConnectivity-mySim1';

%% Set Options
opts.nProcs = 12; % Number of computer processors to use for simulation
opts.debugNetByPlotting = false;
opts.arbitraryFailureTimes = true; %doesnt read the failure times matrix - just uses random times to allow debugging
opts.failureRateMultiplier = 1;% increases rate of failures arbitrarily to allow quicker debugging
opts.showProgressBar = true;
opts.progressBarUpdatePeriod = 3; % progress monitor updates every 3 seconds (example)

%% Run code
run PhasedPetriNetSimulator