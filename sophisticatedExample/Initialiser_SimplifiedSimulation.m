clearvars -except poolobj
close all
clc
addpath('../')

%% Define simulation
Sim.SimTitle = 'sophisticatedSim_SubnetMod';
%Sim.PhaseDurations = [1,1,1,1,1]; % Duration of each phase specified in hours (if component failure data is also in hours)
Sim.PhaseDurations = [3/60,1/60,1.7166,1/60,3/60]; % Duration of each phase specified in hours (if component failure data is also in hours)

Sim.MaxNSims = 1;%  Number of missions to simulate
Sim.MaxSimTimeHrs = 0.2; % max sim time in hours
Sim.NComponents = 40; % Number of all components in the system
Sim.ConnectivityMatName = 'InputConnectivity-sophisticatedSim';

%% Set Options
opts.nProcs = 12; % Number of computer processors to use for simulation
opts.debugNetByPlotting = false;
opts.arbitraryFailureTimes = false; %doesnt read the failure times matrix - just uses random times to allow debugging
opts.failureRateMultiplier = 1000;% increases rate of failures arbitrarily to allow quicker debugging
opts.showProgressBar = true; % only works for parallel cases
opts.progressBarUpdatePeriod = 3; % progress monitor updates every 3 seconds (example)
opts.saveAllVariables = false; % save every simulation variable at end of simulation - normally only relevant variables are saved

%% Run code
run PhasedPetriNetSimulator
