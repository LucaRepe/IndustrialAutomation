clear all;
clc;

%% Parameters

% Defining the jobs
J = [1 2 3 4 5 6 7 8 9 10];

% Defining the processing times
P = [5 3 6 8 4 12 12 5 3 2];

% Defining the due dates
D = [12 60 16 15 9 15 32 20 18 18];

% Defining the weights
W = [1 1 1 1.5 1 1 2 1 1.2 3];

% Big-M coefficient
M = 1000;

%% Variables

prob = optimproblem;

nJobs = length(J);
nMachines = 1;

S = optimvar('S', nJobs, nMachines, 'lowerbound',0);
C = optimvar('C', nJobs, nMachines, 'lowerbound',0);
T = optimvar('T', nJobs, nMachines, 'lowerbound',0);
X = optimvar('X', nJobs, nJobs, 'Type', 'integer', 'lowerbound',0, 'upperbound', 1);

%% Objective function

prob.Objective = W * T;

%% Constraints

% Completion time definition

count = 1;
completionTime = optimconstr(nJobs);

for i=1:nJobs
    completionTime(count) = C(i) == S(i) + P(i);
    count = count + 1;
end

prob.Constraints.completionTime = completionTime;


% Big-M one job at a time

count = 1;
bigMconstr = optimconstr (nJobs*nJobs);

for i=1:nJobs
    for j=1:nJobs
        if i~=j
            bigMconstr(count) = S(j) >= C(i) - M*(1-X(i,j));
            bigMconstr(count+1) = S(i) >= C(j) - M*(X(i,j));
            count = count+2;
        end
    end
end

prob.Constraints.bigMconstr = bigMconstr;

% Job 1 before Job 3

j1beforej3constr = optimconstr(nMachines);
j1beforej3constr = S(3) >= C(1);

prob.Constraints.j1beforej3constr = j1beforej3constr;

% J9 before J10

j9beforej10constr = optimconstr(nMachines);
j9beforej10constr = S(10) >= C(9);

prob.Constraints.j9beforej10constr = j9beforej10constr;


%% Tardiness

count = 1;
tardiness = optimconstr(nJobs);

for j=1:nJobs
    tardiness(count) = T(j) == C(j) - D(j);
    count = count+1;
end

prob.Constraints.tardiness = tardiness;

%% Solution

show(prob);
[sol, cost, output] = solve(prob);
disp(sol);
disp(cost);
disp(output);

%% Gantt chart

[out, idx] = sort(sol.C, 'ascend');

% Creation of the matrix that we're going to plot in the Gantt chart
ganttMatrix = zeros(nJobs,1);
for i = 1:nJobs
    ganttMatrix(i) = P(idx(i));
end

complTime = zeros(nJobs,1);
temp = 0;
for i=1:nJobs
    complTime(i) = temp + P(idx(i));
    temp = complTime(i);
end
H = barh(1,ganttMatrix,'stacked','FaceColor','flat');
% Display every second in the X axis
xticks(0:1:sum(P));
% Computing the number of repeating due dates
[GC,GR] = groupcounts(D');
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
for i=1:nJobs
    if ismember(D(idx(i)),repetitions(1,2))
        if count1 == 0
            if complTime(i) > D(idx(i))
                xl = xline(D(idx(i)),'--r',"D" + string(idx(i)) + " & " + "      ");
                xl.LabelHorizontalAlignment = 'left';
                count1=1;
                continue;
            else
                xl = xline(D(idx(i)),'--b',"D" + string(idx(i)) + " & " + "      ");
                xl.LabelHorizontalAlignment = 'left';
                count1=1;
                continue;
            end
        else
            if complTime(i) > D(idx(i))
                xl = xline(D(idx(i)),'--r',"D" + string(idx(i)));
                xl.LabelHorizontalAlignment = 'left';
                count1=0;
                continue;
            else
                xl = xline(D(idx(i)),'--b',"D" + string(idx(i)));
                xl.LabelHorizontalAlignment = 'left';
                count1=0;
                continue;
            end                
        end         
    end 
        
     if ismember(D(idx(i)),repetitions(2,2))
        if count2 == 0
            if complTime(i) > D(idx(i))
                xl = xline(D(idx(i)),'--r',"D" + string(idx(i)) + " & " + "      ");
                xl.LabelHorizontalAlignment = 'left';
                count2=1;
                continue;
            else
                xl = xline(D(idx(i)),'--b',"D" + string(idx(i)) + " & " + "      ");
                xl.LabelHorizontalAlignment = 'left';
                count2=1;
                continue;
            end
        else
            if complTime(i) > D(idx(i))
                xl = xline(D(idx(i)),'--r',"D" + string(idx(i)));
                xl.LabelHorizontalAlignment = 'left';
                count2=0;
                continue;
            else
                xl = xline(D(idx(i)),'--b',"D" + string(idx(i)));
                xl.LabelHorizontalAlignment = 'left';
                count2=0;
                continue;
            end                
        end  
     end
          
    if complTime(i) > D(idx(i))
        xl = xline(D(idx(i)),'--r',"D" + string(idx(i)));
        xl.LabelHorizontalAlignment = 'left';
        continue;
    else
        xl = xline(D(idx(i)),'--b',"D" + string(idx(i)));
        xl.LabelHorizontalAlignment = 'left';
        continue;
    end
end

% Vertical lines
grid on;
% Adding three more colours, so all the charts are unique
if nJobs > 6
      H(8).CData = [0 1 0];
      H(9).CData = [1 1 0.5];
      H(10).CData = [1 0.5 0.5];
end
% Vertical lines
grid on;
% Adding three more colours, so all the charts are unique
if nJobs > 6
      H(8).CData = [0 1 0];
      H(9).CData = [1 1 0.5];
      H(10).CData = [1 0.5 0.5];
end
title('Gantt chart');
xlabel('Processing time');
ylabel('Job schedule');
% Printing the labels in the charts
labelx = H(1).YEndPoints - 3.5;
labely = H(1).XEndPoints;
text(labelx, labely, "J" + string(idx(1)),'VerticalAlignment', 'middle');
for i = 1:nJobs
    labelx = H(i).YEndPoints + 0.5;
    labely = H(i).XEndPoints;
    if i ~= nJobs
        text(labelx, labely, "J" + string(idx(i+1)),'VerticalAlignment', 'middle');
    end
end
