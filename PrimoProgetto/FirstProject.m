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

sampleTime = 1;
sysc = ss(Ac,Bc,C,D);
sysd = c2d(sysc,sampleTime);

% Ad and Bd are the discrete time matrices, C and D remain the same of
% the ones in continuous time.

Ad = sysd.A;
Bd = sysd.B;

%% 2)	Verify the asymptotical stability (or not) of the system

% To verify the asymptotical stability we check if the absolute value of
% the eigenvalues of the Ad matrix are less than one.

if abs(eig(Ad)) < 1
    disp('The system is stable');
else
    disp('The system is not stable');
end

%% 3)	Simulate the system under autonomous behavior

x0 = [1
      1]; % initial state
horizon = 100; % time where the simulation stops
t = 0:sampleTime:horizon; % starts at 0, computes at every sample time and arrives at horizon
nSamples = length(t); % calculated from the length of t
u = 1*ones(1,nSamples-1);

x(:,1)=x0; % array whose evolution is in time
for i=1:nSamples-1
    x(:,i+1)=Ad*x(:,i);
end

figure(1);
subplot(2,1,1);
plot(t,x(1,:));
title('System under autonomous behavior');
subplot(2,1,2);
plot(t,x(2,:));

%% 4)	Apply a LQT to make the state track a given function

Q = [1000 0
     0 0.0001];
Qf = Q; % cost of the state
R = 1; % cost of the control

horizon = 200;
sampleTime = 1;
t = 0:sampleTime:horizon;
N = length(t)-1;

[P, K] = pk_riccati_output(Ad,Bd,C,Q,Qf,R,N);
[Kinf,Pinf,e] = lqr(sysd,Q,R); % A cosa ci serve?
% z = [4*ones(N+1,1)'
%    -1*ones(N+1,1)'];
z = [4*sin(1:N+1)
    -1*sin(1:N+1)];
[g, Lg] = Lg_xLQT(Ad,Bd,C,Q,Qf,R,N,P,z);

x0 = [-10 13]';
x(:,1) = x0;

%STEP 3 and 4;
for i=1:N
    %optimal control
    u(:,i)=-K(:,:,i)*x(:,i)+Lg(:,:,i)*g(:,:,i+1);
    %optimal state for LQT to track z
    x(:,i+1)=Ad*x(:,i)+Bd*u(:,i);
end

figure(2);
subplot(3,1,1);
plot(t(1:N+1),x(1,:));
hold on;
plot(t(1:N+1),z(1,:));
hold off;
title('LQT','State1');
legend('z1','x1');
xlabel('Time');
ylabel('Reaction');

subplot(3,1,2);
plot(t(1:N+1),x(2,:));
hold on;
plot(t(1:N+1),z(2,:));
hold off;
title('State2');
legend('z2','x2');
xlabel('Time');
ylabel('Temperature');


subplot(3,1,3);
plot(t(1:N),u);
title('Control');
legend('u');
xlabel('Time');
ylabel('Cooling rate');

%% 5)	Show examples with noise on the system, and on the measure of the state, 
%       also taken into account an output y=Cx where C may also be a singular matrix or rectangular.

mucsi = [0 0]; % mean noise of input
Qv = [0.1 0
      0 0.1]; % covariance noise of input
mueta = 0; % mean noise of output
Rv = 0.1;
rng default  % For reproducibility
csi = mvnrnd(mucsi,Qv,N)'; % generates random input noise
eta = mvnrnd(mueta,Rv,N+1)'; % generates random output noise

% C = 10;
C = [1 0];

[P, K] = p_riccati(Ad, Bd, Q, Qf, R, N);
alfa = [0 0]'; % mean initial state
sigma0 = [1 0
          0 1]; % covariance initial state
[Kkalman] = mykalman(Ad,C,Qv,Rv,alfa,sigma0,N);
x0 = [1 1]';
y0 = C*x0+eta(:,1);
mu0 = squeeze(alfa+Kkalman(:,:,1)*(y0-C*alfa));

x(:,1) = x0;
mu(:,1) = mu0;

for i=1:N
    %optimal control
    u(:,i) = -K(:,:,i)*mu(:,i);
    %u(:,i)=0;
    %optimal state for LQT to track z
    x(:,i+1) = Ad*x(:,i)+Bd*u(:,i)+csi(:,i);
    y(:,i+1) = C*x(:,i+1)+eta(:,i+1);
    mu(:,i+1) = Ad*mu(:,i)+Bd*u(:,i)+...
    Kkalman(:,:,i+1)*(y(:,i+1)-C*(Ad*mu(:,i)+Bd*u(:,i)));
    
end

figure(3);
subplot(3,1,1);
plot(t(1:N+1),x(1,:));
hold on;
plot(t(1:N+1),mu(1,:));
hold off;
title('LQG','State1');
legend('Actual','Kalman estimation');
xlabel('Time');
ylabel('Reaction');

subplot(3,1,2);
plot(t(1:N+1),x(2,:));
hold on;
plot(t(1:N+1),mu(2,:));
hold off;
title('State2');
legend('Actual','Kalman estimation');
xlabel('Time');
ylabel('Temperature');

subplot(3,1,3);
plot(t(1:N),u);
title('Control');
legend('u');
xlabel('Time');
ylabel('Cooling rate');

%% 6)	Show examples (Matlab and Simulink) on the performance of one (two?) PID used to do the same task

