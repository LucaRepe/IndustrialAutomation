clear all;
clc;

A = 5;
a = 1;
g = 9.81;

c = -a*(2*g)^0.5/A;
d = a*(2*g)^0.5;

A2 = [3 0 0
     0 -1 1
     -1 1 0];
 
B = [-1 0
    0 0
    0 1];

C = ones(2,3);
D = zeros(2,2);

sysc = ss(A2, B,C,D);
sysd = c2d(sysc, 0.1);

