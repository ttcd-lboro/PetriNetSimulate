clearvars -except poolobj
close all
clc
addpath('../')

%% Define simulation
Sim.SimTitle = 'repairableExample';
Sim.PhaseDurations = [inf]; % Duration of each phase specified in in units matching those of the failure data) - inf for unphased missions
% Note that length of above vector defines number of phases
Sim.MaxNSims = 1e5;%  Number of missions to simulate to ensure convergence
Sim.MaxSimTimeHrs = 10/60; % Max simulation runtime before giving up
Sim.NComponents = 2; % Number of all components in the system
Sim.CaseDataMatName = 'CaseData-repairableExample';

%% Set Options
opts.nProcs = 4; % Number of computer processors to use for simulation
opts.debugNetByPlotting = false;
opts.arbitraryFailureTimes = false; %doesnt read the failure times matrix - just uses random times to allow debugging
opts.failureRateMultiplier = 1;% increases rate of failures arbitrarily to allow quicker debugging
opts.showProgressBar = false; % only works for parallel cases
opts.progressBarUpdatePeriod = 1; % progress monitor updates every 3 seconds (example)
opts.saveAllVariables = false; % save every simulation variable at end of simulation - normally only relevant variables are saved

%% Run code
run RepairablePetriNetSimulator_noCompNets
