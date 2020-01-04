function [R] = RotVec2RotMat(r)
% [R] = RotVec2RotMat(r)
% Computes the rotation matrix R given a rotation vector. 
% Inputs:
%	r: rotation vector
% Outputs:
%	R: generated rotation matrix

%Get the axis & angle from the vector--------
vNorm = norm(r);
angle = vNorm * (180 / pi);

%Check the critical cases------
if(vNorm ~= 0)
axis = r / vNorm;
else
axis = [0,0,0];
end
% Create the Skew-symmetric matrix
ux= [0, -axis(3),  axis(2);
     axis(3),0, -axis(1);
      -axis(2),  axis(1),0];

%Re-writting ofRodrigues’ Rotation Formula
R = eye(3) + sind(angle)* ux + (1- cosd(angle)) * (ux * ux);


end

