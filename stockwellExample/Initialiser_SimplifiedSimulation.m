clearvars -except poolobj
close all
clc
addpath('../')

%% Define simulation
Sim.SimTitle = 'sophisticatedSim_stockwell';
delta = 1/60^2;
Sim.PhaseDurations = [delta,1,delta,2]; % Duration of each phase specified in hours (if component failure data is also in hours)
Sim.MaxNSims = 1e5;%  Number of missions to simulate
Sim.MaxSimTimeHrs = 0.2; % max sim time in hours
Sim.NComponents = 22; % Number of all components in the system
Sim.ConnectivityMatName = 'InputConnectivity-stockwellSim';

% Set Options
opts.nProcs = 12; % Number of computer processors to use for simulation
opts.debugNetByPlotting = false;
opts.arbitraryFailureTimes = false; %doesnt read the failure times matrix - just uses random times to allow debugging
opts.failureRateMultiplier = 1;% increases rate of failures arbitrarily to allow quicker debugging
opts.showProgressBar = true; % only works for parallel cases
opts.progressBarUpdatePeriod = 1; % progress monitor updates every 3 seconds (example)
opts.saveAllVariables = false; % save every simulation variable at end of simulation - normally only relevant variables are saved
opts.allowLoneComponents = true; % allow components to not be connected to any phase net without error - not explicitly built for this. Potential issues in post-processing only

%% Run code
run PhasedPetriNetSimulator
