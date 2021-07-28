clear all;
clc;

%% Parameters

% Defining the jobs
J = [1 2 3 4 5 6 7 8 9 10]';

% Defining the processing times
% P = [5 3 6 8 4 12 12 5 3 2]';
  P = [5 3 6 8 4 12 12 5 3 2]';

% Defining the due dates
D = [12 60 16 15 9 15 32 20 18 18]';

% Defining the weights
W = [1 1 1 1.5 1 1 2 1 1.2 3]';

% Defining the matrix of precedences
precedences = zeros(10,10);
precedences(1,3) = 1;
precedences(9,10) = 1;

% Defining the stages
N = length(J);
X0 = 0;

% Cell array with all the possible states in the stages
for i = 1:N   
    X{i} = nchoosek(1:N,i);
end

%% Pruning

% Pruning the first stage

% Loop on the columns of the precendeces matrix
% If the state has value of 0 it has no precedences
j=1;
for i=1:length(X{1}(:,1))
    if sum(precedences(:,i)) == 0
        Y{1}(j,:) = X{1}(i,:);
        j = j+1;
    end 
end

% Pruning the other stages
% I have to check if each state is reachable from the previous state,
% if it's reachable I have to verify that respects the contraints,
% if it's verified then is admissible.

% Loop to prune the other stages

for c=2:N
    j=1;
    % Loop with all the possible states in the c-th stage
    for i=1:length(X{c}(:,1))
        count = 0;
        % Loop with the states in the previous stage
        for k=1:length(Y{c-1}(:,1))
            % If at least one state from the previous stage has distance
            % one from the state of the actual stage, then the state is 
            % admissible if the preceding constraints are satisfied
            if size(setdiff(X{c}(i,:),Y{c-1}(k,:)))==1
                count = count + 1;
            end 
        end
        % Check if this state satisfies the constraints
        if count > 0
            count = 0;
            % Loop on the jobs computed by the state i in the stage c
            for a=1:length(X{c}(i,:))
                % Loop on the rows of the precedences matrix
                for b=1:length(precedences(1,:))
                    if precedences(b,X{c}(i,a)) ~= 0
                        % There is a preceding constraint on this job,
                        % I have to control if the job that has to be 
                        % executed before has been executed in the state
                        if (~ismember(b,X{c}(i,:)))
                            count = count + 1;
                        end
                    end
                end
            end
            if count == 0 % Then it is admissible
                Y{c}(j,:) = X{c}(i,:);
                j = j+1;
            end
        end
    end % End loop on the states of stage c
end

X = Y;

%% Backward phase

% Step N
states(N)=length(X{N}(:,1));
Go{N}=0; % cost at each state

% Steps from N-1 to 1
for k=N-1:-1:1
    states(k)=length(X{k}(:,1));
    G{k}=10000*ones(states(k),states(k+1)); % cost matrix
    for i=1:states(k)
        start_time=sum(P(X{k}(i,:))); % sum of all the p of the job listed
        for j=1:states(k+1)
            if ismember(X{k}(i,:),X{k+1}(j,:)) % control to check if the state is reachable
                control(i,j)=setdiff(X{k+1}(j,:),X{k}(i,:)); % job to compute the tardiness
                tardiness{k}(i,j) = max((start_time+P(control(i,j))-D(control(i,j))), 0)*W(k); % tardiness computation
                G{k}(i,j)=Go{k+1}(j)+tardiness{k}(i,j); % add the tardiness to the previous cost
            end
        end
        Go{k}(i)=min(G{k}(i,:)); % update the cost matrix
    end
end

% Step 0
for i=1:length(X{1})
    G0(i)=Go{1}(i)+max((P(X{1}(i))-D(X{1}(i))), 0);
end

[Go0, index1]=min(G0); % add the storage of the optimal control
path{1} = X{1}(index1, :); % cell array of the list of execution

%% Forward phase

for i=2:N
    [value, index] = min(Go{i});
    path{i} = X{i}(index, :);
end

scheduled = zeros(N,1);
for i=N:-1:2
    scheduled(i) = setdiff(path{i}, path{i-1});
end
scheduled(1) = path{1};

% Completion time definition

temp = 0;
for i=1:N
    completionTime(i) = temp + P(scheduled(i));
    temp = completionTime(i);
end

%% Gantt chart

clf;
close all;

% Creation of the matrix that we're going to plot in the Gantt chart
ganttMatrix = zeros(N,1);
for i = 1:length(P)
    ganttMatrix(i) = P(scheduled(i));
end

H = barh(1,ganttMatrix,'stacked','FaceColor','flat');

% Display every second in the X axis
xticks(0:1:sum(P));

% Computing the number of repeating due dates
[GC,GR] = groupcounts(D);
row = 1;
col = 1;
for i=1:length(GC)
    if GC(i) > 1
        repetitions(row,col) = GC(i);
        repetitions(row,col+1) = GR(i);
        row=row+1;
    end
end

% Display red or blue labels corresponding to the due dates
count1=0;
count2=0;
for i=1:N
    if ismember(D(scheduled(i)),repetitions(1,2))
        if count1 == 0
            if completionTime(i) > D(scheduled(i))
                xl = xline(D(scheduled(i)),'--r',"D" + string(scheduled(i)) + " & " + "      ");
                xl.LabelHorizontalAlignment = 'left';
                count1=1;
                continue;
            else
                xl = xline(D(scheduled(i)),'--b',"D" + string(scheduled(i)) + " & " + "      ");
                xl.LabelHorizontalAlignment = 'left';
                count1=1;
                continue;
            end
        else
            if completionTime(i) > D(scheduled(i))
                xl = xline(D(scheduled(i)),'r',"D" + string(scheduled(i)));
                xl.LabelHorizontalAlignment = 'left';
                count1=0;
                continue;
            else
                xl = xline(D(scheduled(i)),'b',"D" + string(scheduled(i)));
                xl.LabelHorizontalAlignment = 'left';
                count1=0;
                continue;
            end                
        end         
    end 
        
     if ismember(D(scheduled(i)),repetitions(2,2))
        if count2 == 0
            if completionTime(i) > D(scheduled(i))
                xl = xline(D(scheduled(i)),'--r',"D" + string(scheduled(i)) + " & " + "      ");
                xl.LabelHorizontalAlignment = 'left';
                count2=1;
                continue;
            else
                xl = xline(D(scheduled(i)),'--b',"D" + string(scheduled(i)) + " & " + "      ");
                xl.LabelHorizontalAlignment = 'left';
                count2=1;
                continue;
            end
        else
            if completionTime(i) > D(scheduled(i))
                xl = xline(D(scheduled(i)),'r',"D" + string(scheduled(i)));
                xl.LabelHorizontalAlignment = 'left';
                count2=0;
                continue;
            else
                xl = xline(D(scheduled(i)),'b',"D" + string(scheduled(i)));
                xl.LabelHorizontalAlignment = 'left';
                count2=0;
                continue;
            end                
        end  
     end
          
    if completionTime(i) > D(scheduled(i))
        xl = xline(D(scheduled(i)),'--r',"D" + string(scheduled(i)));
        xl.LabelHorizontalAlignment = 'left';
        continue;
    else
        xl = xline(D(scheduled(i)),'--b',"D" + string(scheduled(i)));
        xl.LabelHorizontalAlignment = 'left';
        continue;
    end
end

% Vertical lines
grid on;
% Adding three more colours, so all the charts are unique
if N > 6
      H(8).CData = [0 1 0];
      H(9).CData = [1 1 0.5];
      H(10).CData = [1 0.5 0.5];
end
title('Gantt chart');
xlabel('Processing time');
ylabel('Job schedule');
% Printing the labels in the charts
labelx = H(1).YEndPoints - 4.5;
labely = H(1).XEndPoints;
text(labelx, labely, "J" + string(scheduled(1)),'VerticalAlignment', 'middle');
for i = 1:N
    labelx = H(i).YEndPoints + 0.5;
    labely = H(i).XEndPoints;
    if i ~= N
        text(labelx, labely, "J" + string(scheduled(i+1)),'VerticalAlignment', 'middle');
    end
end
