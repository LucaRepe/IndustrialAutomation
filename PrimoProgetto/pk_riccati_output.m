% Function to compute p riccati matrix and k control matrix for LQR
% A,B matrixes of linear state dynamics, 
% Q, Qf cost of the state; R cost of the control;
% N number of time intervals; N+1 samples

function  [P, K] = pk_riccati_output(Ad,Bd,C,Q,Qf,R,N)

V = C'*Q*C;
P(:,:,N+1) = C'*Qf*C;
E = Bd*inv(R)*Bd';

    for i=N:-1:1
    P(:,:,i) = Ad'*P(:,:,i+1)*Ad-Ad'*P(:,:,i+1)*Bd*...
             (inv(R+Bd'*P(:,:,i+1)*Bd))*Bd'*P(:,:,i+1)*Ad +V;
    end

    for i=1:N
        K(:,:,i) = inv(R+Bd'*P(:,:,i+1)*Bd)*...
                   Bd'*P(:,:,i+1)*Ad;
    end
end
