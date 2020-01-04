function [v] = RotMat2rotVec(R)
% [v] = RotMat2rotVec(R)
% Computes a rotation vector given a rotation matrix
% Inputs:
%	R: rotation matrix
% Outputs:
%	v: generated rotation vector

%First we transform to Euler Principal Angle & Axis
[a,u] = rotMat2Eaa(R);

%Transform from deg to rad
a = a *pi / 180;

%Calculate the vector
v = a*u;

end

