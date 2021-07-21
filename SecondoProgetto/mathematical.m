clear;
clc;

%% Parameters

% Defining the jobs
J = [1 2 3 4 5 6 7 8 9 10]';

% Defining the processing times
P = [5 3 6 8 4 12 12 5 3 2]';

% Defining the due dates
D = [12 60 16 15 9 15 32 20 18 18]';

% Defining the weights
W = [1 1 1 1.5 1 1 2 1 1.2 3]';

% Big-M coefficient
M = 10000;

%% Variables

prob = optimproblem;

S = optimvar('S', size(P,1), size(P,1), 'lowerbound',0); % [nJob x nMachines]
C = optimvar('C', size(P,1), size(P,1), 'lowerbound',0);
T = optimvar('T', size(P,1), size(P,1), 'lowerbound',0);
X = optimvar('S', size(P,1), size(P,1), size(P,1),'Type', 'integer', 'lowerbound',0, 'upperbound', 1); % [nJob x nJob]

%% Objective function

prob.Objective = W * T;

%% Constraints

count = 1;
constr = optimconstr (2*((size(P,1)*size(P,1)*size(P,1)) - size(P,1) * size(P,1)));

for k = 1:size(P,1)
    for i = 1:size(P,1)
        for j = 1:size(P,1)
            if (i~=j)
                constr(count) = S(k,i) >= C(k,j) - M*(1-X(k,i,j));
                constr(count+1) = S(k,j) >= C(k,i) - M*(X(k,i,j));
                count = count+2;
            end
        end
    end
end

prob.Constraints.constr = constr;


