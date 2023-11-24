clearvars -except poolobj
close all
clc
addpath('../')

%% Define simulation
Sim.SimTitle = 'SimpleCase';
Sim.PhaseDurations = [1,3,0.5]; % Duration of each phase specified in hours (if component failure data is also in hours)

Sim.MaxNSims = 1e4;%  Number of missions to simulate
Sim.MaxSimTimeHrs = 10/60; % max sim time in hours 
Sim.NComponents = 3; % Number of all components in the system
Sim.ConnectivityMatName = 'InputConnectivity-SimpleCase';

%% Set Options
opts.nProcs = 1; % Number of computer processors to use for simulation
opts.debugNetByPlotting = false; % can only be done if running on a single processor
opts.arbitraryFailureTimes = false; %doesnt read the failure times matrix - just uses random times to allow debugging
opts.failureRateMultiplier = 1;% increases rate of failures arbitrarily to allow quicker debugging
opts.showProgressBar = false; % only works for parallel cases
opts.progressBarUpdatePeriod = 3; % progress monitor updates every 3 seconds (example)
opts.saveAllVariables = false; % save every simulation variable at end of simulation - normally only relevant variables are saved

%% Run Code
run PhasedPetriNetSimulator
