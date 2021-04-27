clear all;
clc;

%% 6)	Show examples (Matlab and Simulink) on the performance of one (two?) PID used to do the same task

% Continuous time system

Ac = [-0.1 -0.12
      -0.3 -0.012];
Bc = [0 
      -0.07];
C = eye(2);
D = zeros(2,1);

sampleTime=0.1;
horizon=100;

x0=[10
    -2];
sysc = ss(Ac,Bc,C,D);
sysd=c2d(sysc,sampleTime);
Ad=sysd.A;
Bd=sysd.B;

t=0:sampleTime:horizon;
nSamples=length(t);
N = length(t)-1;

x1_track=4*sin(t);
x2_track=-10*sin(t);
x(:,1)=x0;
x(:,2)=x0;

Qv = [0.1 0
      0 0.1]; % covariance noise of input
rng default  % for reproducibility
mucsi = [0 0]; % mean noise of input
csi = mvnrnd(mucsi,Qv,N)'; % generates random input noise

% Values for PID, obtained tuning the PID in Simulink
Kp=390;
Ki=15;
Kd=559;

previousError = 0;
integral = 0;
for i=1:nSamples-1
%example of PID control on the temperature
  error = x1_track(:,i) - x(1,i);
  integral = integral + error*sampleTime;
  derivative = (error - previousError)/sampleTime;
  u(:,i) = Kp*error + Ki*integral + Kd*derivative;
  previousError = error;
  
  %evolution of the system
  x(:,i+1)=Ad*x(:,i)+Bd*u(:,i)+csi(:,i);
end

subplot(2,1,1);
plot(t,x(1,:));
hold on;
plot(t,x1_track(1,:));
hold off;
title('State1');
legend('State','Signal');

% PID 2

Kp=1;
Ki=1;
Kd=0;

previousError = 0;
integral = 0;
for i=1:nSamples-1
%example of PID control on the reaction
  error = x1_track(:,i) - x(1,i);
  integral = integral + error*sampleTime;
  derivative = (error - previousError)/sampleTime;
  u(:,i) = Kp*error + Ki*integral + Kd*derivative;
  previousError = error;
  
  %evolution of the system
  x(:,i+1)=Ad*x(:,i)+Bd*u(:,i)+csi(:,i);
end

% Plotting simulation
subplot(2,1,1);
plot(t,x(1,:));
hold on;
plot(t,x1_track(1,:));
hold off;
title('State1');
legend('State','Signal');

% subplot(3,1,2);
% plot(t,x(2,:));
% hold on;
% plot(t,x2_track(1,:));
% hold off;
% title('State2');
% legend('State','Signal');

subplot(2,1,2);
plot(t(1:end-1),u(1,:));
title('Control');
