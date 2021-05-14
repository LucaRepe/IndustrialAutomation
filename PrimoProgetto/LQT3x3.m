clear all;
clc;

%% 4)	Apply a LQT to make the state track a given function

% Continuous time system

Ac = [-0.1 0 0
    0 -0.1 0
    -0.1 0 1];
Bc = [1 0 
    2 0
    0 1];
C = eye(3);
D = zeros(3, 2);

sampleTime = 1;
sysc = ss(Ac,Bc,C,D);
sysd = c2d(sysc,sampleTime);

Ad = sysd.A;
Bd = sysd.B;

Q = eye(3);
Qf = Q; % cost of the state
R = 0.01; % cost of the control

horizon = 100;
sampleTime = 1;
t = 0:sampleTime:horizon;
N = length(t)-1;

% P and K matrices obtained from Riccati equation
[P, K] = pk_riccati_output(Ad,Bd,C,Q,Qf,R,N);

% Function to track
z = [4*sin(1:N+1)
    -1*sin(1:N+1)
    5*sin(1:N+1)];

% G and LG matrices 
[g, Lg] = Lg_xLQT(Ad,Bd,C,Q,Qf,R,N,P,z);

x0 = [-10 13 2]';
x(:,1) = x0;
%u = zeros(1,N-1);

for i=1:N
    % Optimal control
    u(:,i)=-K(:,:,i)*x(:,i) + Lg(:,:,i)*g(:,:,i+1);
    % Optimal state for LQT to track z
    x(:,i+1)=Ad*x(:,i) + Bd*u(:,i);
end

% Plot of the tracking

subplot(4,1,1);
plot(t(1:N+1),x(1,:));
hold on;
plot(t(1:N+1),z(1,:));
hold off;
title('State1');
legend('x1','z1');
xlabel('Time');
ylabel('Reaction');

subplot(4,1,2);
plot(t(1:N+1),x(2,:));
hold on;
plot(t(1:N+1),z(2,:));
hold off;
title('State2');
legend('x2','z2');
xlabel('Time');
ylabel('Temperature');

subplot(4,1,3);
plot(t(1:N+1),x(3,:));
hold on;
plot(t(1:N+1),z(3,:));
hold off;
title('State2');
legend('x2','z2');
xlabel('Time');
ylabel('Temperature');


subplot(4,1,4);
plot(t(1:N),u);
title('Control');
legend('u');
xlabel('Time');
ylabel('Cooling rate');
