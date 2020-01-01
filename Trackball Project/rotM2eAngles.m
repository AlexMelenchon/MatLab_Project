function [yaw, pitch, roll] = rotM2eAngles(R)
% [yaw, pitch, roll] = rotM2eAngles(R)
% Computes the Euler angles (yaw, pitch, roll) given an input rotation matrix R.
% Inputs:
%    R: rotation matrix
% Outputs:
%    yaw: angle of rotation around the z axis
%    pitch: angle of rotation around the y axis
%    roll: angle of rotation around the x axis


pitch = asind(-R(3,1)); %We determine the pitch
  
if(sind(pitch) == 1 || sind(pitch) == -1) % If sin of theta is 1 or -1; we have to calculate the angles in a different way.

    roll = 0;  %Since roll and yaw are now cannot be distinguished (because sin(theta) = +-1), we can assume the value of one angle.

    %Then we calculate 
    if(sind(pitch) == 1)
        yaw = roll + atan2d(R(1,2), R(2,2));
    end
    if (sind(pitch) == -1)
        yaw = -roll + atan2d(-R(1,2), -R(2,2));
    end
    
else
    %We calculate roll & yaw.
roll = atan2d(R(3,2)/ cosd(pitch), R(3,3)/ cosd(pitch));
yaw = atan2d(R(2,1)/ cosd(pitch), R(1,1)/ cosd(pitch));

end

 end