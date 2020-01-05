function [a,u] = rotMat2Eaa(R)
% [a,u] = rotMat2Eaa(R)
% Computes the angle and principal axis of rotation given a rotation matrix R. 
% Inputs:
%    R: rotation matrix
% Outputs:
%    a: angle of rotation in degrees
%    u: axis of rotation 

% we calculate the trace & the angle
trace=R(1,1)+R(2,2)+R(3,3);
a=acosd((trace-1)/2);
aMod = mod(a,180);

% Regular case
if(aMod~=0)
    
Ux=(R-transpose(R))/(2*sind(a));
u=[Ux(3,2);Ux(1,3);Ux(2,1)];

%Critical cases: angle = 0 || angle = 180
else
    
    if (a == 0)
    u=[0;0;0]; % If the angle is 0, the axis is irrelevant
    end
    
    if (a == 180)
        %Since we know that: [U]x^2 = R+I/2 &  X^2 + Y^2 + Z^2 = 1; we can
        %compute the bouth equations to calculate the axis from the
        %rotation matrix.
        %First we calculate one using ONLY the first one; but this has a
        %problem, since we using a square root, we are missing the sign.
        %What we will do to solve this is compute the other equation in to
        %"clean" the matrix and be able to extract the other elements of
        %the axis in fuction of the ohter one.
        
        %First we check what option to choose from the trace (the one that is not -1)
        if(sqrt((R(1,1)+1)/2) ~= 0)
        u1 = sqrt((R(1,1)+1)/2);
        u2 = R(1,2)/(2*u1);
        u3 = R(1,3)/(2*u1);
        
        elseif (sqrt((R(2,2)+1)/2) ~= 0)
        u2 = sqrt((R(2,2)+1)/2);
        u1 = R(1,2)/(2*u2);
        u3 = R(2,3)/(2*u2);
        
        elseif (sqrt((R(3,3)+1)/2) ~= 0)
        u3 = sqrt((R(3,3)+1)/2);
        u1 = R(1,3)/(2*u3);
        u2 = R(2,3)/(2*u3);
        end
        
        %Create the axis
        u = [u1;u2;u3];
        

    end
    
end

end
