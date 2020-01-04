function [R] = quaternion2rotM(q)
% [R] =quaternion2rotM(q)
% Computes the rotation matrix R given the quaternion. 
% Inputs:
%	q: quaternion
% Outputs:
%	R: rotation matrix

%Make sure the quaternion is normalized
q = q/sqrt(q'*q);

%Divide the quaternion between variables to make the code easier----
q0 = q(1);
qV = q(2:4);

% Create the Skew-symmetric matrix
qx = [0,-qV(3), qV(2);
        qV(3), 0, -qV(1);
        -qV(2), qV(1), 0];

%Re-writting ofRodrigues’ Rotation Formula to compute the Rotation
%Matrix
R = (q0^2 - (qV'*qV))*eye(3) + 2*(qV*qV') + 2*q0*qx;

end