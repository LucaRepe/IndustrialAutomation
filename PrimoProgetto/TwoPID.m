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
u1=zeros(1,nSamples-1);
u2=zeros(1,nSamples-1);

x1_track=50*sin(t+20)+10;
x2_track=400*sin(t+50);

x(:,1)=x0;

Qv = [0.1 0
      0 0.1]; % covariance noise of input
rng default  % for reproducibility
mucsi = [0 0]; % mean noise of input
csi = mvnrnd(mucsi,Qv,N)'; % generates random input noise

% Values for the first PID, obtained tuning the PID in Simulink

Kp = 2628.54740453048;
Ki = 19066.7584084496;
Kd = 0;

% Values for the second PID, obtained tuning the PID in Simulink

Kp2 = -128.478349079916;
Ki2 = -688.977103325722;
Kd2 = -0.850264599796858;

previousError = 0;
previousError2 = 0;
integral = 0;
integral2 = 0;
for i=1:nSamples-1
% PID control
  error = x1_track(:,i) - x(1,i);
  error2 = x2_track(:,i) - x(2,i);
  integral = integral + error*sampleTime;
  integral2 = integral2 + error2*sampleTime;
  derivative = (error - previousError)/sampleTime;
  derivative2 = (error2 - previousError2)/sampleTime;
  u1(:,i) = Kp*error + Ki*integral + Kd*derivative;
  u2(:,i) = Kp2*error2 + Ki2*integral2 + Kd2*derivative2;
  previousError = error;
  previousError2 = error2;
  
  % Evolution of the system
  x(:,i+1)=Ad*x(:,i)+Bd*(u1(:,i)+u2(:,i))+csi(:,i);
end

% Plotting the first PID

subplot(4,1,1);
plot(t,x(1,:));
hold on;
plot(t,x1_track(1,:));
hold off;
title('State1');
legend('State','Signal');

subplot(4,1,2);
plot(t(1:end-1),u1(1,:));
title('Control1');
legend('u1');

% Plotting the second PID

subplot(4,1,3);
plot(t,x(2,:));
hold on;
plot(t,x2_track(1,:));
hold off;
title('State2');
legend('State','Signal');

subplot(4,1,4);
plot(t(1:end-1),u2(1,:));
title('Control2');
legend('u2');
