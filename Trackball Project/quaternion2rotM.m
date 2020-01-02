function [R] = quaternion2rotM(q)

q = q/sqrt(q'*q);

q0 = q(1);
qV = q(2:4);

qx = [0,-qV(3), qV(2);
        qV(3), 0, -qV(1);
        -qV(2), qV(1), 0];

R = (q0^2 - (qV'*qV))*eye(3) + 2*(qV*qV') + 2*q0*qx;

end