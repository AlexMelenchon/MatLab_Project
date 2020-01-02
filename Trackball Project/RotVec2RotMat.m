function [R] = RotVec2RotMat(r)
% [R] = RotVec2RotMat(r)
% Computes the rotation matrix R given a rotation vector. 
% Inputs:
%	r: rotation vector
% Outputs:
%	R: generated rotation matrix

vNorm = norm(rotVec);
angle = vNorm;
axis = r / vNorm;

ux= [0, -rotVec(3),  rotVec(2);
     rotVec(3),0, -rotVec(1);
      -rotVec(2),  rotVec(1),0];

%Re-writting ofRodrigues’ Rotation Formula
R = eye(3) + sind(angle)* ux + (1- cosd(angle)) * (ux * ux);


end

