clearvars -except poolobj
close all
clc
addpath('../')

% note that this 'realistic' simulation takes around 48 hrs on 12 cores to
% complete - much better to use the Simplified Simulation as an example or
% the simpleExample test case which is simpler but has no subnets

%% Define simulation
Sim.SimTitle = 'sophisticatedSim_realistic';
Sim.PhaseDurations = [3/60,1/60,1.7166,1/60,3/60]; % Duration of each phase specified in hours (if component failure data is also in hours)

Sim.MaxNSims = 1.5e10; %  Number of missions to simulate
Sim.MaxSimTimeHrs = 56; % max sim time in hours
Sim.NComponents = 40; % Number of all component subnets (where a subnet is the petri net for a given phase)
Sim.ConnectivityMatName = 'InputConnectivity-sophisticatedSim'; % run 'additionalTools/exampleBuildMatricesFromExcel.m' first to generate an example
Sim.compressAMatrices = true; % compress A-matrix to improve calculation speed - requires special handling of place IDs

%% Set Options
opts.nProcs = 1; % Number of computer processors to use for simulation
opts.debugNetByPlotting = false;
opts.arbitraryFailureTimes = false; %doesnt read the failure times matrix - just uses random times to allow debugging
opts.failureRateMultiplier = 1;% increases rate of failures arbitrarily to allow quicker debugging
opts.showProgressBar = false; % only works for parallel cases
opts.progressBarUpdatePeriod = 3; % progress monitor updates every 3 seconds (example)
opts.saveAllVariables = false; % save every simulation variable at end of simulation - normally only relevant variables are saved

%% Run code
% check all variables present
run PhasedPetriNetSimulator