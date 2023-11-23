function[p1,figHand,LocalTransitionIndices,keepNodes] = PlotNet(A,pIds,tIds,graphTitle,varargin)

if nargin>4
    figHand = varargin{1};
    figure(figHand)
else
    figure
end

figHand = gcf;
pIds = pIds(:);
tIds = tIds(:);
%% Convert A to square
%To plot a directed graph in Matlab, you must first change our "A" matrix
%into a square matrix which uses only 1s and 0s to represent A (which has
%-1s as well) - our notation is more concise and easy to follow but cannot
%be plotted

%% Seperate into Forward and Backwards
Aup=(A==-1)';
Alow=(A==1);

ADims = size(A);
MaxDim = sum(ADims);
AAssembled = zeros(MaxDim); %Initialise

AAssembled([1:ADims(2)],[ADims(2)+1:MaxDim]) = Aup;
AAssembled([(ADims(2)+1):MaxDim],[1:ADims(2)]) = Alow;

%% Plot to Check
h1 = digraph(AAssembled);
removeNodes = (indegree(h1)+outdegree(h1))==0;

keepNodes = (indegree(h1)+outdegree(h1))>0; %othewise known as GlobalToPlotPlaceMapping
h2=rmnode(h1,find(removeNodes));

p1 = plot(h2);
p1.NodeColor = 'b';
p1.EdgeColor = [0 0 0];
% p1.EdgeAlpha = 1;
p1.MarkerSize = 5;
p1.NodeFontSize = 12;
layout(p1,'layered','Direction','up')
title(graphTitle)

%% Label the Nodes
Prefixes=[repmat('P', [ADims(2),1]);repmat('T', [ADims(1),1])];
RealNodeNums = [pIds;tIds]';
NLabels = string(strcat(Prefixes,num2str(RealNodeNums')));

labelnode(p1,1:sum(keepNodes),NLabels(keepNodes)) %Label all nodes
LocalTransitionIndices = contains(NLabels(keepNodes),'T');
highlight(p1,LocalTransitionIndices,'NodeColor','r') % Highlight the Transitions

% print(gcf,'Phase2PetriGraph.png','-dpng','-r600');
%% Reachability graph
% D = transclosure(p1);
% R = full(adjacency(D))
end
