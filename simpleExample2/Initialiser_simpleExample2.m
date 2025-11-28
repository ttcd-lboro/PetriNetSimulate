clearvars -except poolobj
close all
clc
addpath('../')

%% Define simulation
Sim.SimTitle = 'simpleExample2';
Sim.PhaseDurations = [inf]; % Duration of each phase specified in in units matching those of the failure data)
% Note that length of above vector defines number of phases
Sim.MaxNSims = 2e3;%  Number of missions to simulate to ensure convergence
Sim.MaxSimTimeHrs = 10/60; % Max simulation runtime before giving up
Sim.NComponents = 3; % Number of all components in the system
Sim.CaseDataMatName = 'CaseData-simpleExample2';

%% Set Options
opts.nProcs = 4; % Number of computer processors to use for simulation - NOTE nProcs=1 is easier to debug in matlab if things go wrong
opts.debugNetByPlotting = false; % Can only be done if running on a single processor
opts.arbitraryFailureTimes = false; % Doesn't read the failure times matrix - just uses random times to allow debugging
opts.failureRateMultiplier = 1;% Increases rate of failures arbitrarily to allow quicker debugging
opts.showProgressBar = true; % Only works for parallel cases
opts.progressBarUpdatePeriod = 1; % Progress monitor updates every 2 seconds (example)
opts.saveAllVariables = false; % Save every simulation variable at end of simulation - normally only relevant variables are saved

%% Run Code
run PetriNetSimulator_repairNoCompNets
