function [v] = RotMat2rotVec(R)
% [v] = RotMat2rotVec(R)
% Computes a rotation vector given a rotation matrix
% Inputs:
%	R: rotation matrix
% Outputs:
%	v: generated rotation vector


[a,u] = rotMat2Eaa(R);

v = a*u;

end

