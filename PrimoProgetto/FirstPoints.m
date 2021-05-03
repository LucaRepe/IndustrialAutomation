clear all;
clc;

% x1^dot(t) = -0.1*x1(t) - 0.12*x2(t)
% x2^dot(t) = -0.3*x1(t) - 0.012*x2(t) - 0.07*u(t)

% State variables
% x1 is the reaction variable
% x2 is the temperature variable
% u is the control variable, effective cooling rate coefficient

% Continuous time system

Ac = [-0.1 -0.12
    -0.3 -0.012];
Bc = [0 
    -0.07];
C = eye(2);
D = zeros(2, 1);

%% 1)	Discretize the system with a sample period of 0.1s.

sampleTime = 0.1;
sysc = ss(Ac,Bc,C,D);
sysd = c2d(sysc,sampleTime);

% Ad and Bd are the discrete time matrices, C and D remain the same of
% the ones in continuous time.

Ad = sysd.A;
Bd = sysd.B;

%% 2)	Verify the asymptotical stability (or not) of the system

% To verify the asymptotical stability we check if the absolute value of
% the eigenvalues of the Ad matrix is less than one.

if abs(eig(Ad)) < 1
    disp('The system is stable');
else
    disp('The system is not stable');
end

%% 3)	Simulate the system under autonomous behavior

x0 = [10
      -2]; % initial state
horizon = 100; % instant where the simulation stops
t = 0:sampleTime:horizon; % starts at 0, computes at every sample time and arrives at horizon
nSamples = length(t); % calculated from the length of t

x(:,1)=x0; 
for i=1:nSamples-1
    x(:,i+1)=Ad*x(:,i);
end

subplot(2,1,1);
plot(t,x(1,:));
title('State1');
subplot(2,1,2);
plot(t,x(2,:));
title('State2');
