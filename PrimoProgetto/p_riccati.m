% Computes P riccati matrix and the optimal control K for LQ problem
% where u*=-K*x*
function [P,K] = p_riccati(A,B,Q,Qf,R,N)

P(:,:,N+1) = Qf;
for i=N:-1:1
    P(:,:,i) = Q+A'*P(:,:,i+1)*A-A'*P(:,:,i+1)*B*...
     (inv(R+B'*P(:,:,i+1)*B))*B'*P(:,:,i+1)*A;
end

for i=1:N
    K(:,:,i) = inv(R + B'*P(:,:,i+1)*B)*...
          B'*P(:,:,i+1)*A;
end
end


