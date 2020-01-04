function [R] = Eaa2rotMat(a,u)
% [R] = Eaa2rotMat(a,u)
% Computes the rotation matrix R given an angle and axis of rotation. 
% Inputs:
%	a: angle of rotation
%	u: axis of rotation 
% Outputs:
%	R: generated rotation matrix

%Make sure the vector is a colum vector----
u = u(:);

%If the axis is not 0, we normalize it----
if(max(u) ~= 0)
u = u/sqrt(u'*u);
end

identity = eye(3);

% Create the Skew-symmetric matrix
UX = [0,-u(3), u(2);
        u(3), 0, -u(1);
        -u(2), u(1), 0];

%Re-writting ofRodrigues’ Rotation Formula
R = identity + (sind(a)*UX) + (1-cosd(a))*UX^2;

end

