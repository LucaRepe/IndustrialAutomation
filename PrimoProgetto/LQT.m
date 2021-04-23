clear all;
clc;

%% 4)	Apply a LQT to make the state track a given function

Ac = [-0.1 -0.12
    -0.3 -0.012];
Bc = [0 
    -0.07];
C = eye(2);
D = zeros(2, 1);

sampleTime = 1;
sysc = ss(Ac,Bc,C,D);
sysd = c2d(sysc,sampleTime);

Ad = sysd.A;
Bd = sysd.B;

Q = [1000 0
     0 0.0001];
Qf = Q; % cost of the state
R = 0.01; % cost of the control

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
