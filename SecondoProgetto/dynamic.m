clear all;
clc;

% Defining the jobs
J = [1 2 3 4 5 6 7 8 9 10]';

% Defining the processing times
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
X{N} = zeros(N);

% Cell array with all the possible state in the stages
for i = 1:N   
    X{i} = nchoosek(1:N,i);
end

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
        % add the storage of the optimal control
        [Go{k}(i),position(k,i)]=min(G{k}(i,:)); % update the cost matrix
        %control_o(k,i) = control(i, position(k,i));
    end
end

% Step 0
for i=1:N
    G0(i)=Go{1}(i)+max((P(X{1}(i))-D(X{1}(i))), 0);
end

[Go0, idx]=min(G0); % add the storage of the optimal control
path{1} = X{1}(idx, :);

%% Forward phase

for i = 2:N
    [out, idx] = min(Go{i});
    path{i} = X{i}(idx, :);
end

scheduled = [0 0 0 0 0 0 0 0 0 0]';
for i=N:-1:2
    scheduled(i) = setdiff(path{i}, path{i-1});
end
scheduled(1) = path{1};


%[cost, tadiness, completionTime] = 

%% Gantt chart

clf;
close all;

