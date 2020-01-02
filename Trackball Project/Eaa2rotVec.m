function [v] = Eaa2rotVec(a,u)
% [v] = Eaa2rotVec(a,u)
% Computes a rotation vector given an angle and axis of rotation. 
% Inputs:
%	a: angle of rotation
%	u: axis of rotation 
% Outputs:
%	v: generated rotation vector

v = a*u;

end

