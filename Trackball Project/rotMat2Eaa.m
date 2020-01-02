function [a,u] = rotMat2Eaa(R)
% [a,u] = rotMat2Eaa(R)
% Computes the angle and principal axis of rotation given a rotation matrix R. 
% Inputs:
%    R: rotation matrix
% Outputs:
%    a: angle of rotation in degrees
%    u: axis of rotation 

trace=R(1,1)+R(2,2)+R(3,3);
a=acosd((trace-1)/2);
aMod = mod(a,180);

if(mod(a,180)~=0)
    
Ux=(R-transpose(R))/(2*sind(a));
u=[Ux(3,2);Ux(1,3);Ux(2,1)];

else
    
    if (a == 0)
    u=[0;0;0]; % If the angle is 0, the axis is irrelevant
    end
    
    if (a == 180)
        %Since we know that: [U]x^2 = R+I/2 &  X^2 + Y^2 + Z^2 = 1; we can
        %do the following operations. 
        u1 = sqrt((R(1,1)+1)/2);
        u2 = R(1,2)/(2*u1);
        u3 = R(1,3)/(2*u1);
        u = [u1, u2, u3];
    end
    
end

end
