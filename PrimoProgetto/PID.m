clear;
clc;
sample_time=0.03704;
horizon=25;
%x^dot(t)=A*x(t)+B*u(t)
%y(t)=C*x(t)+D*u(t);
%continuous time system
A = [-0.1 -0.12
      -0.3 -0.012];
B = [0 
      -0.07];

C = eye(2);

D = zeros(2,1);
x0=[0
    0];
sys_c = ss(A,B,C,D);
sys_d=c2d(sys_c, sample_time);
Ad=sys_d.A;
Bd=sys_d.B;
Cd=sys_d.C;
Dd=sys_d.D;

t=0:sample_time:horizon;
n_samples=length(t);

x_track=sin(t);

x(:,1)=x0;

%track x1
Kp=120;
Ki=30;
Kd=600;

%track x2
%Kp=-80;
%Ki=1;
%Kd=6;
previous_error = 0;
integral = 0;

for i=1:n_samples-1
%example of PID control on the temperature without noise
  error = x_track(:,i) - x(1,i);
  integral = integral + error*sample_time;
  derivative = (error - previous_error)/sample_time;
  u(:,i) = Kp*error + Ki*integral + Kd*derivative;
  previous_error = error;
  
  %evolution of the system
  x(:,i+1)=Ad*x(:,i)+Bd*u(:,i);
end

%plotting simulation
subplot(2,1,1);
plot(t,x(1,:));
hold on;
plot(t,x_track(1,:));
hold off;
title('first state component noise');
legend('state','signal');

subplot(2,1,2);
plot(t(1:end-1),u(1,:));
title('control');
