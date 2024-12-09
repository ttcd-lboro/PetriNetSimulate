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