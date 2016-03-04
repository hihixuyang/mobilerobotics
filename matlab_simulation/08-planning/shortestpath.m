function [spath,sdist] = shortestpath(nodes, edges, start, finish, method, createVideo)
%SHORTESTPATH Find shortest path using A-star search
% Inputs: 
%   nodes: list of n node locations in 2D
%   edges: nXn connectivity of nodes (1 = connected), symmetric only uses
%           upper triangle
%   start: index of start node
%   finish: index of finish node
%   method: (1 = Astar) (2 = Breadth-First) (3= Depth-First) (4= Dijkstra's)
%   createVideo: (1 = YES) (the others: NO) 

switch method
    case 1 
    case 2 
    case 3 
    case 4
       % happy here.
    otherwise
       disp('wrong search of method')
       return
end
       
%% Create AVI object
if ((createVideo >0) && (createVideo <=1))
    switch method
        case 1 % Astart
            vidObj = VideoWriter('Astar.avi');
        case 2 %Breadth-First
            vidObj = VideoWriter('Breadth_First.avi');
        case 3 %Depth-First
            vidObj = VideoWriter('Depth_First.avi');
        case 4 %Dijkstra's 
            vidObj = VideoWriter('Dijkstra');
    end

    vidObj.Quality = 100;
    vidObj.FrameRate = 5;
    open(vidObj);
end 
% Find edge lengths
n = length(nodes);
dists= zeros(n,n);
for i = 1:n
    for j = i:n
        if (edges(i,j))
            dists(i,j) = norm(nodes(i,:)-nodes(j,:));
            dists(j,i) = dists(i,j);
        end
    end
end

%% Plot graph
figure(1); clf; hold on;
plot(nodes(:,1),nodes(:,2),'ko');
for i = 1:n
    for j = i:n
        if (edges(i,j)==1)
            plot([nodes(i,1) nodes(j,1)],[nodes(i,2) nodes(j,2)],'k');
        end
    end
end
plot(nodes(start,1),nodes(start,2),'bo','MarkerSize',6,'LineWidth',2);
plot(nodes(finish,1),nodes(finish,2),'ro','MarkerSize',6,'LineWidth',2);
if(createVideo >0 && createVideo<=1)
   writeVideo(vidObj, getframe(gcf));
end


%% Find shortest path

% Initialize open set (node, backtrack, lower bound cost, current cost)
dmax = norm(nodes(start,:)-nodes(finish,:));
OpenSet = [start 0 dmax 0];
% Initialize closed set (same as open set)
C = [];
done = 0;
t = 0;

best =1 ; %init index
bestnode = OpenSet(best,:);

%%======================================================== MAIN
% Main algorithm
while (~done)
    t=t+1 
     switch method
         case 1 % Astart
            % Check if open set is empty
            if (length(OpenSet(:,1))==0)
                spath = [];
                sdist = 0;
                return;
            end             
            [val, best] = min(OpenSet(:,3));
            bestnode = OpenSet(best,:);
            % Check end condition
            if (bestnode(1)==finish)
                done = 1;
                % Move best to closed set
                C = [C; bestnode];                
                continue;
            end 
            
         case 4 %Dijkstra's 
            % Check if open set is empty
            if (length(OpenSet(:,1))==0)
                spath = [];
                sdist = 0;
                return;
            end             
            [val, best] = min(OpenSet(:,3));
            bestnode = OpenSet(best,:);
            % Check end condition
            if (bestnode(1)==finish)
                done = 1;
                % Move best to closed set
                C = [C; bestnode];                
                continue;
            end 

            
         case 2 %Breadth-First
            if (length(OpenSet(:,1))==0)
                done = 1;
                continue;
            end
             best = 1;  % Grap next node in the open set
             bestnode = OpenSet(best,:);
            % remove best node from open set
            OpenSet = OpenSet([best+1:end],:);                 
          
         case 3 %Depth-First
            if (length(OpenSet(:,1))==0)
                done = 1;
                continue;
            end
            best = 1;  % Grap next node in the open set
            bestnode = OpenSet(best,:);
            % remove best node from open set
            OpenSet = OpenSet([best+1:end],:);            

     end
   
     % Move best to closed set
     C = [C; bestnode];

    

    % Get all neighbours of best node
    neigh = find(edges(bestnode(1),:)==1);
    
    % Process each neighbour
    for i=1:length(neigh)
        % If neighbour is in closed set, skip        
        found = find(C(:,1)==neigh(i),1);
        if (length(found)==1)
            if(C(found,1)~=finish)
                continue;
            end
        end
        
        dcur = bestnode(4)+dists(bestnode(1),neigh(i));
        found = find(OpenSet(:,1)==neigh(i),1);
        switch method
            case 1 % Astart
                dtogo = norm(nodes(neigh(i),:)-nodes(finish,:));
                % If neighbour is not in open set, add it   
                if (length(found)==0)
                   OpenSet = [OpenSet; neigh(i) bestnode(1) dtogo+dcur dcur];             
                else
                   if (dcur < OpenSet(found,4))
                      OpenSet(found,:) = [neigh(i) bestnode(1) dtogo+dcur dcur];
                   end
                end
              
            case 2 %Breadth-First   (QUEUE)
                % If neighbour is not in open set, add it
                if (length(found)==0)
                   OpenSet = [OpenSet; neigh(i) bestnode(1) dcur dcur];     
        
                else % If in open set, update cost if better    
                   if (dcur < OpenSet(found,4))
                      OpenSet(found,:) = [neigh(i) bestnode(1) dcur dcur];
                   end
                end                   
            
            case 3 %Depth-First  (STACK)
                % If neighbour is not in open set, add it
                if (length(found)==0)
                   OpenSet = [neigh(i) bestnode(1) dcur dcur; OpenSet];
                else % If in open set, update cost if better    
                   if (dcur < OpenSet(found,4))
                      OpenSet(found,:) = [neigh(i) bestnode(1) dcur dcur];
                   end
                end                   

            case 4 %Dijkstra's 
                % If neighbour is not in open set, add it
                if (length(found)==0) 
                   OpenSet = [OpenSet; neigh(i) bestnode(1) dcur dcur]; 
                
                else % If neighbour is in open set, check if new route is better
                    if (dcur < OpenSet(found,4))
                       OpenSet(found,:) = [neigh(i) bestnode(1) dcur dcur];
                    end
                end                    
            end     
        
        
    end
    
    switch method
        case 1 % Astart
               OpenSet = OpenSet([1:best-1 best+1:end],:); % remove best node from open set                            
        case 4 %Dijkstra's     
               OpenSet = OpenSet([1:best-1 best+1:end],:); % remove best node from open set                
    end
    
    % Plot active nodes for this step
    figure(1);hold on;
    plot(nodes(C(:,1),1),nodes(C(:,1),2), 'ko','MarkerSize',6,'LineWidth',2);
    plot(nodes(bestnode(1),1),nodes(bestnode(1),2), 'go','MarkerSize',6,'LineWidth',2);
    for i=1:length(neigh)
        plot(nodes(neigh(i),1),nodes(neigh(i),2), 'mo');
        plot([nodes(bestnode(1),1) nodes(neigh(i),1)],[nodes(bestnode(1),2) nodes(neigh(i),2)], 'm');
    end
    if ((createVideo >0) && (createVideo <=1))
        writeVideo(vidObj, getframe(gcf));
    end
end

%%======================================================== END OF MAIN
% Find final path through back tracing
done = 0;
cur = finish;
curC = find(C(:,1)==finish);
[ldistance,lessCostIndex]= min(C(curC,3));
prev = C(curC(lessCostIndex),2);
spath = [cur];
sdist = 0;
while (~done)
    if (prev == start)
        done = 1;
    end
    figure(1);hold on;
    plot([nodes(prev,1) nodes(cur,1)], [nodes(prev,2) nodes(cur,2)],'g','LineWidth',2)
    cur = prev;
    curC = find(C(:,1)==cur);
    [ldistance,lessCostIndex]= min(C(curC,3));
    prev = C(curC(lessCostIndex),2);
    if ((createVideo >0) && (createVideo <=1))
       writeVideo(vidObj, getframe(gcf));
    end
    spath = [cur, spath];
    sdist = sdist+dists(spath(1),spath(2));

end

if ((createVideo >0) && (createVideo <=1))
    close(vidObj);
end