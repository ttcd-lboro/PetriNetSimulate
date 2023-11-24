clearvars -except poolobj
close all
clc

%% Define simulation
Sim.SimTitle = 'mySim1';
Sim.PhaseDurations = [3/60,1/60,1.7166,1/60,3/60]; % Duration of each phase specified in hours (if component failure data is also in hours)

Sim.MaxNSims = 1.5e10; %  Number of missions to simulate
Sim.MaxSimTimeHrs = 56; % max sim time in hours
Sim.NComponents = 40; % Number of all component subnets (where a subnet is the petri net for a given phase)
Sim.ConnectivityMatName = 'InputConnectivity-mySim1'; % run 'additionalTools/exampleBuildMatricesFromExcel.m' first to generate an example

%% Set Options
opts.nProcs = 4; % Number of computer processors to use for simulation
opts.debugNetByPlotting = false;
opts.arbitraryFailureTimes = false; %doesnt read the failure times matrix - just uses random times to allow debugging
opts.failureRateMultiplier = 1;% increases rate of failures arbitrarily to allow quicker debugging
opts.showProgressBar = true;
opts.progressBarUpdatePeriod = 3; % progress monitor updates every 3 seconds (example)

%% Run code
% check all variables present
run PhasedPetriNetSimulator