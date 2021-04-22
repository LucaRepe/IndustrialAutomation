%function to compute p riccati matrix and k control matrix for LQR
%A,B matrixes of linear state dynamics, 
%Q, Qf cost of the state; R cost of the control;
%N number of time intervals; N+1 samples

function  [g, Lg] = Lg_xLQT(Ad,Bd,C,Q,Qf,R,N,P,z)
    %z is the vector to be tracked length N+1, dimension is the one y
    W = C'*Q;
    E = Bd*inv(R)*Bd';

    g(:,:,N+1) = C'*Qf*z(:,N+1);
    for i=N:-1:1
    g(:,:,i) = Ad'*(eye(size(Ad,1))-inv(inv(P(:,:,i+1))+E)*E)*g(:,:,i+1)+W*z(:,i);
    end

    for i=1:N
        Lg(:,:,i) = inv(R+Bd'*P(:,:,i+1)*Bd)*Bd';
    end
end
