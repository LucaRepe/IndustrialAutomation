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

x_track=sin(t).*ones(1,nSamples);
x(:,1)=x0;

%track x1
Kp=120;
Ki=30;
Kd=600;

%track x2
% Kp=-80;
% Ki=1;
% Kd=6;

previousError = 0;
integral = 0;
for i=1:nSamples-1
%example of PID control on the temperature
  error = x_track(:,i) - x(1,i);
  integral = integral + error*sampleTime;
  derivative = (error - previousError)/sampleTime;
  u(:,i) = Kp*error + Ki*integral + Kd*derivative;
  previousError = error;
  
  %evolution of the system
  x(:,i+1)=Ad*x(:,i)+Bd*u(:,i);
end

%plotting simulation
subplot(2,1,1);
plot(t,x(1,:));
hold on;
plot(t,x_track(1,:));
hold off;
title('First state component noise');
legend('State','Signal');

subplot(2,1,2);
plot(t(1:end-1),u(1,:));
title('Control');
