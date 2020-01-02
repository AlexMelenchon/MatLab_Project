function [R] = quaternion2rotM(q)

q0 = q(1);
qV = q(2:4);

qV = qV/sqrt(qV'*qV);

R1 = [(q0^2 + qV(1)^2 -qV(2)^2 - qV(3)^2), 2*qV(1)*qV(2) - 2*q0*qV(3), 2*qV(1)* qV(3) + 2*q0*qV(2);];
R2 = [ 2*qV(1)*qV(2) + 2*q0*qV(3),( q0^2 - qV(1)^2 +qV(2)^2 - qV(3)^2), 2*qV(2)*qV(3) - 2 *q0*qV(1)];
R3 = [ 2*qV(1)*qV(3) - 2*q0*qV(2), 2*qV(2)*qV(3) + 2*q0*qV(1), q0^2-qV(1)^2-qV(2)^2 + qV(3)^2;];
R = [R1; R2; R3];

end