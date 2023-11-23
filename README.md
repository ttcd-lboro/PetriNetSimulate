# PetriNetSimulate
A parallelised MATLAB code for simulating petri nets for a phased mission with subnets

See help of 'PhasedPetriNetSimulator.m' for details on method

To familiarise yourself with the code programming inputs, the simplest way to run your first simulation is 
to run 'additionalTools/exampleBuildMatricesFromExcel.m' to generate a .mat file of the place/transition connectivity 
and component failure data from excel input files
Then run 'exampleDummySimulationInitialiser.m' to simulate the data

# Steps to a custom initialisation:

1) Build A-matrix for each phase petri net and store in the 'A' cell array (1 cell per phase) of InputConnectivity*.mat
    See 'additionalTools/buildMatricesFromExcel.m' for an example on how this can be done
    Run the code to generate an example InputConnectivity*.mat file which is read in by the solver

2) Store component failure data in the 'failDatTable' table variable of InputConnectivity*.mat
    Component data can be be of exponential, weibull or normal distributions (indexed 0,1,2 respectively in the table column "Datatype")
    See 'RawInputData/ComponentFailureData.xlsx' for an example definition of failure data, of which the highlighted columns are read into matlab in 'additionalTools/buildMatricesFromExcel.m'
    See 'additionalTools/buildMatricesFromExcel.m' for example on how an excel definition of the data is converted to tabular format

3) Declare simulation parameters in the "Sim" structure - usually done within the initialiser script - see 'exampleInitialiser.m'
    Example: <br>
        Sim.SimTitle = 'mySim1'; <br>
        Sim.PhaseDurations = [3/60,1/60,1.7166,1/60,3/60]; % Duration of each phase specified in hours (if component failure data is also in hours)
        Sim.MaxNSims = 1.5e10; %  Number of missions to simulate
        Sim.MaxSimTimeHrs = 56; % max sim time in hours
        Sim.NComponents = 40; % Number of all component subnets (where a subnet is the petri net for a given phase)
        Sim.ConnectivityMatName = 'InputConnectivity-mySim1';

4) Declare simulation options in the "opts" structure - usually done within the initialiser script - see 'exampleInitialiser.m'
    Example:
        opts.nProcs = 4; % Number of computer processors to use for simulation
        opts.debugNetByPlotting = false;
        opts.arbitraryFailureTimes = false; %doesnt read the failure times matrix - just uses random times to allow debugging
        opts.failureRateMultiplier = 1;% increases rate of failures arbitrarily to allow quicker debugging
        opts.showProgressBar = true;
        opts.progressBarUpdatePeriod = 3; % progress monitor updates every 3 seconds (example)
