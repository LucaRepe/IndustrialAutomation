clear all;
clc;
%continuos time system;
Ac=[-0.1 -0.12
    -0.3 -0.012];
Bc=[0
    -0.07];
C=eye(2);
D=zeros(2,1);

Q=[1000 0
   0 0.0001];
Qf=Q;
R=0.01;

sample=1;
horizon=200;
t=0:sample:horizon;
N=length(t)-1;
sysc=ss(Ac,Bc,C,D);
sysd=c2d(sysc,sample);
Ad=sysd.a;
Bd=sysd.b;

[P, K]=pk_riccati_output(Ad,Bd,C,Q,Qf,R,N);
[Kinf,Pinf,e]=lqr(sysd,Q,R);
z=[4*ones(N+1,1)'
  -1*ones(N+1,1)'];
[g, Lg]=Lg_xLQT(Ad,Bd,C,Q,Qf,R,N,P,z);

x0=[-10 13]';
x(:,1)=x0;

%STEP 3 and 4;
for i=1:N
    %optimal control
    u(:,i)=-K(:,:,i)*x(:,i)+Lg(:,:,i)*g(:,:,i+1);
    %optimal state for LQT to track z
    x(:,i+1)=Ad*x(:,i)+Bd*u(:,i);
end

subplot(2,1,1);
plot(t(1:N+1),x);
title('state');

subplot(2,1,2);
plot(t(1:N),u);
title('control');
