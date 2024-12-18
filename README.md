#VERSION 2.1 2024
1) Subnets now easier to define: Separate import matrices
2) Improved handling of parallelisation

# PetriNetSimulate
A parallelised MATLAB code for simulating petri nets for a phased mission. All components must be non-repairable but subnets of component families are allowed.
The 'mission petri-net' is handled by a while loop but all component nets, and phase nets are combined into A-matrices for each phase (with consistent place and transition IDs between phases). This is the 'equation programming' method.
All missions are programmed to be independent such that components reinitialise their failure times from the fialure data at the start of each simulation/mission.
See help of 'PhasedPetriNetSimulator.m' for details on method

To familiarise yourself with the code programming inputs, the simplest way to run your first simulation is to run 'additionalTools/exampleBuildMatricesFromExcel.m' to generate a .mat file of the place/transition connectivity and component failure data from excel input files. Then run 'exampleDummySimulationInitialiser.m' to simulate the data

# Steps to a custom initialisation:

1) Build A-matrix for each phase petri net and store in the 'A' cell array (1 cell per phase) of InputConnectivity*.mat
    <br> See 'additionalTools/buildMatricesFromExcel.m' for an example on how this can be done
    <br> Run the code to generate an example InputConnectivity*.mat file which is read in by the solver

2) Store component failure data in the 'failDatTable' table variable of InputConnectivity*.mat
    <br> Component data can be be of exponential, weibull or normal distributions (indexed 0,1,2 respectively in the table column "Datatype")
    <br> See 'RawInputData/ComponentFailureData.xlsx' for an example definition of failure data, of which the highlighted columns are read into matlab in 'additionalTools/buildMatricesFromExcel.m'
    <br> See 'additionalTools/buildMatricesFromExcel.m' for example on how an excel definition of the data is converted to tabular format

3) Declare simulation parameters in the "Sim" structure - usually done within the initialiser script - see 'exampleInitialiser.m'
    <br> Example: 
        <br> Sim.SimTitle = 'mySim1';
        <br> Sim.PhaseDurations = [3/60,1/60,1.7166,1/60,3/60]; % Duration of each phase specified in hours (if component failure data is also in hours)
        <br> Sim.MaxNSims = 1.5e10; %  Number of missions to simulate
        <br> Sim.MaxSimTimeHrs = 56; % max sim time in hours
        <br> Sim.NComponents = 40; % Number of all component subnets (where a subnet is the petri net for a given phase)
        <br> Sim.ConnectivityMatName = 'InputConnectivity-mySim1';

4) Declare simulation options in the "opts" structure - usually done within the initialiser script - see 'exampleInitialiser.m'
    <br> Example:
        <br> opts.nProcs = 4; % Number of computer processors to use for simulation
        <br>opts.debugNetByPlotting = false;
        <br> opts.arbitraryFailureTimes = false; %doesnt read the failure times matrix - just uses random times to allow debugging
        <br> opts.failureRateMultiplier = 1;% increases rate of failures arbitrarily to allow quicker debugging
        opts.showProgressBar = true;
        opts.progressBarUpdatePeriod = 3; % progress monitor updates every 3 seconds (example)
