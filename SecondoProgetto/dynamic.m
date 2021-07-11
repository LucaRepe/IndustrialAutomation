clear all;
clc;

% Defining the jobs
J = [1 2 3 4 5 6 7 8 9 10]';

% Defining the processing times
P = [5 3 6 8 4 12 12 5 3 2]';

% Defining the due dates
D = [12 60 16 15 9 15 32 20 18 18]';

% Defining the stages
N = length(J);
X0 = 0;
X{10} = zeros(10);
for i = 1:N   
    X{i} = nchoosek(1:N,i);
end

%% Backward phase

% Step N
states(10)=length(X{10}(:,1));
Go{10}=0; % cost at each state

% Steps from N-1 to 1
for k=N-1:-1:1
    states(k)=length(X{k}(:,1));
    G{k}=10000*ones(states(k),states(k+1)); % cost matrix
    for i=1:states(k)
        start_time=sum(P(X{k}(i,:))); % sum of all the p of the job listed
        for j=1:states(k+1)
            if ismember(X{k}(i,:),X{k+1}(j,:)) % control to check if the state is reachable
                control(i,j)=setdiff(X{k+1}(j,:),X{k}(i,:)); % job to compute the tardiness
                tardiness{k}(i,j) = max((start_time+P(control(i,j))-D(control(i,j))), 0); % tardiness computation
                G{k}(i,j)=Go{k+1}(j)+tardiness{k}(i,j); % add the tardiness to the previuos cost
            end
        end
        Go{k}(i)=min(G{k}(i,:)); % update the cost matrix
    end
end

% Step 0
for i=1:N
    G0(i)=Go{1}(i)+max((P(X{1}(i))-D(X{1}(i)))/N, 0);
end
Go0=min(G0);

%% Forward phase


