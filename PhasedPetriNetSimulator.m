%% Phased mission petri net code
%
% V2: 2024-Dec-2nd
% Chris Dunne MEng, MRes
% PhD Student - CDT Future Propulsion and Power
% Loughborough University
% c.dunne@lboro.ac.uk
%
%The following is a parallelised MATLAB code for simulating petri
%nets for a phased mission.
%
%Please note results have not been verfied but appeared to be within
%expected limits and logic has been tested using the optional
%"opts.debugNetByPlotting = true" statement, which shows how tokens move
%through each net on a graph
%
%Connectivity between places is specified in 'A' matrices, and times to
%failure are generated from exponential/weibull/normal distributions.
%Data for these distributions is read in as stored as excel
%spreadsheets which are read in using "buildMatr
%
%All other parameters are specifed at the start of this script
%Assumes all components active (could fail) during any phase (but will not
%cause phase failure if they are not in the phase petri net)
%
%Components' working places are always the first places to be defined
%(e.g.1:10)
%
%Components' failure places must then be the next integers following the
%working places
%(e.g. 11:19)
%
%Subseqeuent places in the net should be ordered methodically but order
%does not matter so long as A-matrix correctly programmed
%
%Petri net place IDs (not indices) begin at 1 and transition place IDs
%begin at 1
%
%Uses innovative method of keeping componenet failure nets (2 places 1
%transition each), seperate from the main petri nets, allowing the failed
%nature of each component to carry across to all new phases
%
%Also allows for sunets which allow for additional repeated subnets to be
%created and used in multiple phases

%% Load Data
% Define "Sim and opts structures in auxilliary file first (see exampleInitialiser.m)"
warning off backtrace
load([Sim.ConnectivityMatName,'.mat'],'A','ASubnets','failDatTable','ComponentNetToPhaseNetIDs_allPhases'); % read in A matrices for all phases with their associated (glboal) place and transition IDs.
if ~exist('ASubnets','var')
    warning('No subnets found. Assuming none present')
    ASubnets = [];
end
warning on backtrace
%% Construct petri net and failure times
Sim.fullSimName = [Sim.SimTitle,'.',char(datetime('now','Format','yy-MM-d_HH-mm'))];
Sim.NPhases = length(Sim.PhaseDurations);

[~, err, ~] = mkdir(Sim.fullSimName); i = 0;
while ~isempty(err)
    i=i+1;
    [~, err, ~] = mkdir([Sim.fullSimName,'_',num2str(i)]);
end

diary([Sim.fullSimName,'/log.',Sim.fullSimName]); diary on
rng('shuffle'); % Sets unique rand seed
[AGlobal,AGlobalDims] = AssembleAGlobal(A,ASubnets,Sim);
NGlobalTransitions = AGlobalDims(1);
NGlobalPlaces = AGlobalDims(2);

%% Initialise Simulation Variables
MaxSimTime = Sim.MaxSimTimeHrs*60^2; % max sim time in seconds
SysEndTime = sum(Sim.PhaseDurations);
PhaseFailures = zeros(1,Sim.NPhases);
MGlobal_0 = zeros(NGlobalPlaces,1); % Initalise the marking of the phase
MGlobal_0(1:Sim.NComponents) = true;
small_ = SysEndTime/1e5;
FailedComponents=zeros(Sim.NComponents,1);

SimOutcome = zeros(Sim.MaxNSims,1,'int8');
PhaseOfFailure = zeros(Sim.MaxNSims,1,'int8');
T_Fire_0 = false(NGlobalTransitions,1); % Define the zeroed version of the transition firing matrix

% Setup simulation for running in parallel
if opts.nProcs>1
    if ~exist('poolobj','var')
        try
            poolobj = gcp();
        catch
            try
                poolobj = parpool(opts.nProcs);
            catch
                delete(gcp('nocreate'))
                poolobj = parpool(opts.nProcs);
            end
        end
    elseif poolobj.NumWorkers ~= opts.nProcs
        delete(gcp('nocreate'))
        poolobj = parpool(opts.nProcs);
    end
end

warning off backtrace
[~] = GenerateTimesToFailure(failDatTable,1); %prerun generate times to failure so warnings about components with no data are shown
if opts.arbitraryFailureTimes
    warning("'opts.arbitraryFailureTimes' is enabled - all failure times are random for this case")
end
warning on backtrace

runTime = tic; % start timer
disp('Simulation running')
if opts.showProgressBar
    disp('Note: progress bar only considers the time towards completing the maximum number of simulations')
    disp('Time shown by progress bar does not account for the maximum simulation time')
end
warning('off','MATLAB:mir_warning_maybe_uninitialized_temporary')

%% Run Simulation
if opts.nProcs>1 && ~opts.debugNetByPlotting % paralllel processing
    if opts.showProgressBar
        ppm = ParforProgressbar(Sim.MaxNSims,'progressBarUpdatePeriod',opts.progressBarUpdatePeriod,'title','Total Simulation Progress'); %
    end
    parfor runNo = 1:(Sim.MaxNSims)
        %%% ALGORITHM START %%%
        if toc(runTime)<MaxSimTime

            %% Initialise sim
            P = 0 ; %Initial phase is phase 1
            MGlobal = MGlobal_0;
            PhaseEndTime = Sim.PhaseDurations(1);
            t_sys = 0; %system has time of 0
            ALeaving = sum(A.A{1}==-1); % List number of transitions leaving each place
            PhaseFailedPlaceId = A.pIds{1}(ALeaving == 0); % Phase failed place is place no transitions leaving it
            if length(PhaseFailedPlaceId)>1;error('Multiple phase fail places detected');end

            % Get new component failure times
            tInitialTransitions = zeros(NGlobalTransitions,1);
            if (opts.arbitraryFailureTimes)
                tInitialTransitions(1:Sim.NComponents) = 0.2*(1+rand(1,Sim.NComponents))/opts.failureRateMultiplier;
            else
                tInitialTransitions(1:Sim.NComponents) = GenerateTimesToFailure(failDatTable,0)/opts.failureRateMultiplier; %
            end

            tRemainTransitions = tInitialTransitions;

            %% Loop til failure/success
            while true % Loop until the break keyword
                %% Continue loop conditions:
                PPrevious = P;
                if P~=0
                    if MGlobal(PhaseFailedPlaceId)>0 %Check if token in system failed place then fail the mission
                        PhaseOfFailure(runNo) = P;
                        SimOutcome(runNo) = 2; % 2 means system failed
                        FailedComponents = FailedComponents + (MGlobal(1:Sim.NComponents)==0);
                        if opts.debugNetByPlotting
                            disp(['Sim ',num2str(runNo),': Phase failure registered in phase ',num2str(P)])
                        end
                        break
                    end
                end
                if t_sys >= PhaseEndTime || P==0  % If time to move to next phase then switch phase and reinitialise all variables
                    if opts.debugNetByPlotting && P~=0
                        disp(['t_sys>PhaseEndTime                  : ',num2str(t_sys),' > ',num2str(PhaseEndTime)])
                    end
                    if P==Sim.NPhases %all phases complete if phase time complete AND its the final phase
                        SimOutcome(runNo) = 1;
                        if opts.debugNetByPlotting
                            disp(['Sim ',num2str(runNo),': Mission complete without failure - final phase  time over '])
                        end
                        break
                    else

                        %% Reinitialise for new phase
                        P = P+1;
                        PhaseEndTime = PhaseEndTime+Sim.PhaseDurations(P); %increment the system time at which the phase ends
                        AGlobal_P = AGlobal.A{P};

                        %Get phase failed place
                        NArcsLeavingEachPlace = sum(A.A{P}==-1,1); % List number of transitions leaving each place
                        PhaseFailedPlaceId = A.pIds{P}(NArcsLeavingEachPlace == 0); % Phase failed place is place no transitions leaving it
                        if length(PhaseFailedPlaceId)>1
                            error('Multiple phase fail places detected');
                        elseif isempty(PhaseFailedPlaceId)
                            error('Phase failed place was not found')
                        end

                        % Reinitialise Transfer Variables
                        T_Fire = T_Fire_0;
                        T_Enabled = false(NGlobalTransitions,1); % Gives logical index of which transitions are enabled

                        % Reinitialise insertion vector and component to main net links for this phase
                        ComponentOutputIDs_P = ComponentNetToPhaseNetIDs_allPhases{P}(:,1);
                        PhaseNetInputIDs_P = ComponentNetToPhaseNetIDs_allPhases{P}(:,2);
                        if any(size(ComponentOutputIDs_P)~= size(PhaseNetInputIDs_P)); error('No Match');end
                        AllowNetCopying = ones(NGlobalPlaces,1);%Vector of 1s until a componenet fails, then the value is made a 0 to prevent adding more tokens into the phase net every time its chekced
                        InsertionVector = false(NGlobalPlaces,1); %Initialise the insertion vector - a boolean vector which describes the links between component nets and phase net

                    end
                end

                %% Find all the enabled transitions.
                for n = 1 : NGlobalTransitions %loop through each transition
                    InputInds = AGlobal_P(n,:)<0; %gives the indices of the input places to this transition (to check whether its enabled)
                    T_Enabled(n) = all(MGlobal(InputInds)) && ~isequal(InputInds,zeros(1,length(InputInds))); % Mark transition as enabled after checking current marking of these places to see if all have a token, also excludes places that have no inputs
                end
                if isempty(T_Enabled)
                    error('No transitions enabled - this could be fine  - try removing this error message if you encounter an issue')
                end

                %% Get transitions to fire based on min time left and update times
                if sum(T_Enabled)>0 % If any transitions are enabled //CD should be ~isempty(T_Enabled) - quicker
                    dt = min(min(tRemainTransitions(T_Enabled)),max((PhaseEndTime-t_sys+small_),small_)); %also considers whether phase is about to end
                else
                    dt = 0;
                end

                T_Fire = T_Enabled.*(tRemainTransitions<=dt); % Fire just this/these transition(s)

                %Update times
                tRemainTransitions = tRemainTransitions - dt.*T_Enabled; %Removes time past from all transitions that were enabled
                t_sys = t_sys + dt;

                %% Fire transitions
                MGlobalPrevious = MGlobal; %Cache old MGlobal
                MGlobal = MGlobal + (AGlobal_P' * T_Fire); %FIRE all transitions!
                InsertionVector(PhaseNetInputIDs_P) = MGlobal(ComponentOutputIDs_P); %
                MGlobal = MGlobal + InsertionVector.* AllowNetCopying; % Transfer tokens from component nets to phase net
                AllowNetCopying(InsertionVector~=0) = 0;  %After firing, reset insertion vector back to all zeros to prevent multiple tokens entering the phase PN from a single failed component net

                if opts.debugNetByPlotting
                    disp(['Phase ', num2str(P),' is affected by the failure of the following componenents: '])
                    disp(ComponentOutputIDs_P');
                end

                placesWithTokenComponentNets = intersect(ComponentOutputIDs_P,find(MGlobalPrevious));
                if ~isempty(placesWithTokenComponentNets)
                    placesWithTokenPhaseNets = MGlobal(placesWithTokenComponentNets);
                    if ~all(placesWithTokenPhaseNets)
                        error('Tokens were not copied from component nets to phase petri net after they failed - check component connectivity matrix')
                    end
                    if opts.debugNetByPlotting
                        disp('Of these, the following contained a token and had it transferred to the phase net:')
                        disp(placesWithTokenPhaseNets);
                        disp('The current status of the corresponding places in the phase net is: (should all be true)')
                    end
                elseif opts.debugNetByPlotting
                    disp('However none of these contained a token on this pass')

                end

                %% Plot it - live
                if opts.debugNetByPlotting
                    if P~=PPrevious %replot graph from scratch if its a new phase or hasnt been plotted yet
                        fNet = figure(50);
                        [p1,fNet,LocalTransitionIndices,keepNodes] = PlotNet(AGlobal_P,1:NGlobalPlaces,1:NGlobalTransitions,['Global Petri Net in Phase ',num2str(P)],fNet);
                        hold on
                        h = zeros(4, 1);h(1) = plot(NaN,NaN,'ob','MarkerFaceColor','b');h(2) = plot(NaN,NaN,'ok','MarkerFaceColor','k');h(3) = plot(NaN,NaN,'or','MarkerFaceColor','r');h(4) = plot(NaN,NaN,'og','MarkerFaceColor','g'); % define symbols for legend
                        legend(h,'Empty place','Token','Disabled Transition','Enabled Transition','location','southoutside')
                        hold off
                    end

                    % Highlight graph based on marking
                    DefaultColours = p1.NodeColor;
                    MarkedNodes = MGlobal(keepNodes(1:length(MGlobal)));
                    EnabledTransitions = T_Enabled(keepNodes((length(MGlobal)+1):length(keepNodes)));
                    highlight(p1,find([zeros(length(MarkedNodes),1);EnabledTransitions]),'NodeColor','g') %puts the places on the front and then concatenates the enabled transitions
                    highlight(p1,find(MarkedNodes),'NodeColor','k') %shows marked nodes as black
                    FiredTransIndex = find(MGlobalPrevious~=MGlobal)';
                    if isempty(FiredTransIndex)
                        title(['Simulation no: ',num2str(runNo),': phase no: ',num2str(P),'. No transitions fired in this phase'])
                    else
                        title(['Simulation no: ',num2str(runNo),': phase no: ',num2str(P),'. The following places changed: ',num2str(num2str(FiredTransIndex))])
                    end

                    % Pause, waiting for user to press any key to continue, then reset node colours after
                    disp('Press any key to step through component failures and their effects: ')
                    pause

                    if sum(MGlobal<0)>0
                        error(['Mistake in marking for node ,',num2str(find(MGlobal<0)), ' : reconsider code structure'])
                    end
                    p1.NodeColor = DefaultColours;
                end

            end
        else
            SimOutcome(runNo) = 0;
        end
        %%% ALGORITHM END %%%
        if opts.showProgressBar
            ppm.increment();
        end
    end

    if opts.showProgressBar
        delete(ppm);
    end
else
    progCount = 0.1;
    for runNo = 1:(Sim.MaxNSims)

        run Algorithm4SerialRun % run the same algorithm as above - kept in seperate file for simplicity

        progress = mod(runNo/Sim.MaxNSims,0.05);
        if (runNo/Sim.MaxNSims)>(progCount)
            disp(['Simulation ',num2str(progCount*100),'% complete'])
            progCount = progCount + 0.1;
        end
    end
end
totalRunTime = toc(runTime);
disp(['Total runTime: ',num2str(totalRunTime)])
save([Sim.fullSimName,'/Results.',Sim.fullSimName,'.mat'],'Sim','SimOutcome','PhaseOfFailure','FailedComponents')
if opts.saveAllVariables
    save([Sim.fullSimName,'/AllResults.',Sim.fullSimName,'.mat'])
end
save([Sim.fullSimName,'/Inputs.',Sim.fullSimName,'.mat'],'A','failDatTable','ComponentNetToPhaseNetIDs_allPhases','ASubnets'); % read in A matrices for all phases with their associated (glboal) place and transition IDs.

%% Process results
SimOutcome=SimOutcome(SimOutcome~=0);%0 means mission was skipped due to simulation time limit
NSims = length(SimOutcome); % remove all skipped simulations (due to time limit or early end)
disp([num2str(NSims/Sim.MaxNSims*100),' % of simulations were completed before time limit occurred'])
NSuccesses = sum(SimOutcome==1);%1 means mission was successful
NFailures = sum(SimOutcome==2);%2 means mission failed

NComponentFailures = sum(FailedComponents);
SysFailureProbability = NFailures/NSims;
disp(['There were ',num2str(NFailures),' mission failures and ', num2str(NSuccesses),' succcesses, after ',num2str(NSims), ' runs']) % Print no times sys has failed
disp(['This corresponds to a failure rate of ', num2str(SysFailureProbability*100),' %']) % Calculate failure probability
disp('') % line break
disp(['Across all simulations, there were a total of ',num2str(NComponentFailures),' component failures']) % Print no times sys has failed

%% Components which had failed upon system failure
figure
ComponentFailLikelihoodOnSysFail = FailedComponents/NFailures;

bar(ComponentFailLikelihoodOnSysFail)
grid on
title('Components which had failed upon system failure')
ylabel(["Component failures at ", "failure time / system failures"])
xlabel('Component Number')
set(gca,'yscale','log')
yl = ylim;
yl(1) = min(yl(1),0.8*min(ComponentFailLikelihoodOnSysFail(ComponentFailLikelihoodOnSysFail~=0)));
yl(2) = max(yl(2),1.2*max(ComponentFailLikelihoodOnSysFail));
ylim(yl)

exportgraphics(gcf,[Sim.fullSimName,'/QcomponentCausesFailure.png'])

%% Plot Convergence Graph

DevelopingFailureProbability = cumsum(SimOutcome==2)./(1:NSims)';
FinalSysFailProbability = DevelopingFailureProbability(end);
if (FinalSysFailProbability>0)
    if NSims>1e5
        sep = round(NSims/min(1e4,NSims),0);
        DevelopingFailureProbability = downsample(DevelopingFailureProbability,sep);
        DevelopingFailureProbability_Ind = 1:sep:NSims;
    else
        DevelopingFailureProbability_Ind = 1:NSims;
    end

    figure
    tl = tiledlayout(1,2,'TileSpacing','compact','padding','compact');
    nexttile
    semilogy(DevelopingFailureProbability_Ind,DevelopingFailureProbability)
    xlim([0 NSims])
    ylim([FinalSysFailProbability*10^(-0.1),FinalSysFailProbability*10^0.1])
    title(tl,'Convergence')
    xlabel('Iteration No')
    ylabel('Overall System Failure Probability')
    yline(FinalSysFailProbability,'k--')
    yline(FinalSysFailProbability*1.05,'r--')
    yline(FinalSysFailProbability*0.95,'r--')
    legend('Prediction as Simulation Progressed','Final Value','5% Upper Confidence Bound','5% Lower Confidence Bound')
    title('log scale')
    grid on

    nexttile
    plot(DevelopingFailureProbability_Ind,DevelopingFailureProbability)
    xlim([0 NSims])
    ylim([FinalSysFailProbability*0.9,FinalSysFailProbability*1.1])

    xlabel('Iteration No')
    ylabel('Overall System Failure Probability')
    yline(FinalSysFailProbability,'k--')
    yline(FinalSysFailProbability*1.05,'r--')
    yline(FinalSysFailProbability*0.95,'r--')
    legend('Prediction as Simulation Progressed','Final Value','5% Upper Confidence Bound','5% Lower Confidence Bound')
    title('linear scale')
    grid on

    title(tl,'Convergence of System Failure Probabily')
    rsz = get(gcf,'Position');
    rsz(3) = 2 * rsz(3);
    set(gcf,'Position',rsz)
    exportgraphics(gcf,[Sim.fullSimName,'/simConvergence.png'])

    %% Phase of failure
    for P=1:Sim.NPhases
        PhaseFailures(P) = sum(PhaseOfFailure==P);
    end
    figure
    bar(PhaseFailures/NSims)
    xlabel('Phase')
    ylabel(["Simulated probability system fails", "in each phase"])
    disp(['Failed in each phase the following number of times:    ', num2str(PhaseFailures)])
    set(gca,'yscale','log')
    grid on
    title('Simulated probability system fails in each phase')
    exportgraphics(gcf,[Sim.fullSimName,'/QphaseFailure.png'])
else
    disp('No failures in entire simulation time. Convergence not plotted')
end
%% End
save([Sim.fullSimName,'/Results.',Sim.fullSimName,'.mat'],'NSims','NFailures','NComponentFailures','PhaseFailures','FinalSysFailProbability','NComponentFailures','-append')
if opts.saveAllVariables
    save([Sim.fullSimName,'/AllResults.',Sim.fullSimName,'.mat'])
end

diary off

function [AGlobal,AGlobalDims] = AssembleAGlobal(A,ASubnets,Sim)

disp("Assembling Global A-Matrix")
NPhases = length(A.A);
maxPId = max(cellfun(@max,A.pIds));
maxTId = max(cellfun(@max,A.tIds));
AGlobal.tIds = 1:maxTId;
AGlobal.pIds = 1:maxPId;

AGlobalDims = [maxTId,maxPId];
AGlobalZeros = zeros(AGlobalDims);

A_Components_Local = [-eye(Sim.NComponents),eye(Sim.NComponents)]; % Create the A Matrix which links all components together

AGlobalComponents = AGlobalZeros;
AGlobalComponents((1:Sim.NComponents),(1:2*Sim.NComponents)) = A_Components_Local;

%Put component A matrices into global format
for P=1:NPhases
    AGlobal.A{P} = AGlobalZeros;
    AGlobal.A{P}(A.tIds{P},A.pIds{P}) = A.A{P};
end

% Add component subnets (auto-generated)
for P=1:NPhases
    AGlobal.A{P} = AGlobal.A{P} + AGlobalComponents; %Put componenet failures into the global matrix
end

% Add subnets if present
if ~isempty(ASubnets)&&iscell(ASubnets.A)
    AGlobalSubnet = AGlobalZeros;
    for SId=1:length(ASubnets.A)
        AGlobalSubnet(ASubnets.tIds{SId},ASubnets.pIds{SId}) = ASubnets.A{SId};
    end
    for P=1:NPhases
        AGlobal.A{P} = AGlobal.A{P} + AGlobalSubnet; %Put componenet failures into the global matrix
    end
end

disp("Global A-Matrix Completed")
if Sim.compressAMatrices
    CompressAMatrices()
end

AGlobalDims = size(AGlobal.A{1});

    function [] = CompressAMatrices()
        validTr = false(size(AGlobal.A{1},1),1);
        validPl = false(1,size(AGlobal.A{1},2));
        for Pq=1:NPhases
            validTr = validTr|~all(AGlobal.A{Pq} == 0, 2); %boolean giving all irrelevant transitions to current phase
            validPl = validPl|~all(AGlobal.A{Pq} == 0, 1); %boolean giving all irrelevant places to current phase
        end
        %validTr = cellfun(@any,invalidTr_p);
        for Pq=1:NPhases
            AGlobal.A{Pq} = AGlobal.A{Pq}(validTr,validPl);
        end
        AGlobal.tRealIds = AGlobal.tIds(validTr');
        AGlobal.pRealIds = AGlobal.pIds(validPl);
        AGlobal.tIds = 1:length(AGlobal.tRealIds);
        AGlobal.pIds = 1:length(AGlobal.pRealIds);
        disp("Global A-Matrix Compressed")
        AGlobalDims = [length(AGlobal.tIds),length(AGlobal.pIds)];
        AGlobal.pCompOffset = AGlobal.pIds - AGlobal.pRealIds;
        AGlobal.tCompOffset = AGlobal.tIds - AGlobal.tRealIds;

    end
end
function IND = ID2Ind(ID, AGlobal,Sim)
% Find where ID values match in AGlobal.pRealIds
IND = ID;
if Sim.compressAMatrices
    for n=1:length(ID)
        IND(n) = AGlobal.pIds(find(AGlobal.pRealIds==ID(n)));
    end
end
end

% Function for Ind2ID
function ID = Ind2ID(IND, AGlobal,Sim)
% Find where IND values match in AGlobal.pIds
ID = IND;
if Sim.compressAMatrices
    for n=1:length(ID)
        ID(n) = AGlobal.pRealIds(find(AGlobal.pIds==IND(n)));
    end
end
end