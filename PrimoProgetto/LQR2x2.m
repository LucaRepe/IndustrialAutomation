clear;
clc;

A=[1 1
   0 1];
B=[0 1
   1 0];
Q=eye(2);
R=100;
Qf=Q;
sampleTime=1;
horizon = 100;
t = 0:sampleTime:horizon;
N=length(t)-1;
u = zeros(2,N+1);

x0=[10
    -2];
x(:,1)=x0;
SYS=ss(A,B,eye(2),zeros(1));
sysd = c2d(SYS,sampleTime);

Ad = sysd.A;
Bd = sysd.B;

% [K,P,e] = lqr(sysd,Q,R);
[K,P,e] = dlqr(Ad,Bd,Q,R);

for i=1:N
    u(:,i)=-K*x(:,i);
    x(:,i+1)=Ad*x(:,i)+Bd*u(:,i);
end

% plot(t,x);

plot(t(1:N+1),x(1,:));
hold on;
plot(t(1:N+1),x(2,:));
hold off;
 