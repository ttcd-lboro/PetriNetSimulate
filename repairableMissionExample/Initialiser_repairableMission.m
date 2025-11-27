clearvars -except poolobj
close all
clc
addpath('../')

%% Define simulation
Sim.SimTitle = 'RepairableMission';
Sim.PhaseDurations = [10]; % Duration of each phase specified in hours (if component failure data is also in hours)
% Note that length of above vector defines number of phases
Sim.MaxNSims = 5e2;%  Number of missions to simulate to ensure convergence
Sim.MaxSimTimeHrs = 10/60; % Max simulation runtime before giving up
Sim.NComponents = 3; % Number of all components in the system
Sim.CaseDataMatName = 'CaseData-RepairableMission';

%% Set Options
opts.nProcs = 1; % Number of computer processors to use for simulation
opts.debugNetByPlotting = false; % Can only be done if running on a single processor
opts.arbitraryFailureTimes = false; % Doesn't read the failure times matrix - just uses random times to allow debugging
opts.failureRateMultiplier = 1;% Increases rate of failures arbitrarily to allow quicker debugging
opts.showProgressBar = false; % Only works for parallel cases
opts.progressBarUpdatePeriod = 0.2; % Progress monitor updates every 3 seconds (example)
opts.saveAllVariables = false; % Save every simulation variable at end of simulation - normally only relevant variables are saved

%% Run Code
run RepairablePetriNetSimulator_noCompNets
