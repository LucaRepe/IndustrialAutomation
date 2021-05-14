clear all;
clc;

A=[-0.1 0 0
    0 -0.1 1
    -0.1 0 1];
B =[1 0
    2 0
    0 1];

C = eye(3);
D = zeros(3,2);

x0=[10
    5
    2];

Q=eye(3);
R = [1000 0
    0 1000];

sysc = ss(A,B,C,D);
sysd = c2d(sysc, 0.1);

Ad = sysd.A;
Bd = sysd.B;

t=0:0.1:100;

nSamples = length(t)-1;
u = zeros(2,nSamples);
x(:,1)=x0;

[K, P, e] = dlqr(Ad, Bd, Q, R);


for i=1:nSamples
    u(:,i)=-K*x(:,i);
    x(:,i+1)=Ad*x(:,i)+Bd*u(:,i);
end

plot(t(1:nSamples+1),x);