function [R] = eAngles2rotM(yaw, pitch, roll)
% [R] = eAngles2rotM(yaw, pitch, roll)
% Computes the rotation matrix R given the Euler angles (yaw, pitch, roll). 
% Inputs:
%	yaw: angle of rotation around the z axis
%	pitch: angle of rotation around the y axis
%	roll: angle of rotation around the x axis
% Outputs:
%	R: rotation matrix

%Create the matrix that repsetens the rotation for each euler angle
Ryaw = [cosd(yaw),sind(yaw), 0;
        -sind(yaw), cosd(yaw), 0;
        0, 0, 1];
Rpitch = [cosd(pitch), 0 , -sind(pitch);
           0,1,0;
            sind(pitch), 0, cosd(pitch)];
Rroll = [1,0,0;
         0, cosd(roll), sind(roll);
         0, -sind(roll), cosd(roll)];
     
%Then we multiply the rotation between each order in this order & we
%transpose them to match the desired matrix     
R = transpose(Ryaw) * transpose(Rpitch) * transpose(Rroll);

end




