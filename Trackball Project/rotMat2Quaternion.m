function [q] = rotMat2Quaternion(R)
% [q] = rotMat2Quaternion(R)
% Computes a quaternion given a rotation matrix. 
% Inputs:
%	R: Rotation matrix
% Outputs:
%	q: generated quaternion

trace = R(1,1) + R(2,2) + R(3,3);
%First case : (q0^2 > qi^2; for i = 0,2,3), which is achieved if the trace of R >= 0
if (trace >= 0)
    %The calculate aux in order to not compute the same operation 4 times
    aux = sqrt(1 +trace);
    
        
    q0 =   0.5 * aux;
    q1 = 0.5 *(( R(3,2) - R(2,3) ) / aux);
    q2 = 0.5* (( R(1,3) - R(3,1) ) / aux );
    q3 = 0.5 *(( R(2,1) - R(1,2) ) / aux);
    
    q = [  q0; q1; q2; q3]; 
        
     
% Second case: (q1^2 > qi^2; for i = 0,2,3), which is achieved if trace(R) <
% 0 and r11 = max(r11, r22, r33)
elseif (trace < 0 && R(1,1) > R(2,2) && R(1,1) > R(3,3) )
    aux = sqrt(1 + R(1,1) - R(2,2) - R(3,3) );  
    
    q0 = 0.5 * ((R(3,2) - R(2,3)) / aux );
    q1 =    0.5 * aux;
    q2 =  0.5 * ( ( R(1,2) + R(2,1) ) / aux);
    q3 =    0.5 * ( ( R(1,3) + R(3,1) ) / aux );
    
    q = [  q0; q1; q2; q3]; 
        
%Third case: (q2^2 > qi^2; for i = 0,1,3), which is achieved if trace(R) <
% 0 and r22 = max(r11, r22, r33)
    elseif (trace < 0 && R(2,2) > R(1,1) && R(2,2) > R(3,3) )
    aux = sqrt(1 - R(1,1) + R(2,2) - R(3,3) );
    
    q0 = (0.5* ((R(1,3) - R(3,1)) / aux));
    q1 =  0.5*( (R(1,2) + R(2,1)) / aux);
    q2 =  0.5 * aux;
    q3 =   0.5*( (R(2,3) + R(3,2)) / aux);
    
    q = [  q0; q1; q2; q3]; 

%Fourth & last case: (q3^2 > qi^2; for i = 0,1,2), which is achieved if trace(R) <
% 0 and r33 = max(r11, r22, r33)
else
    aux = sqrt(1 - R(1,1) - R(2,2) + R(3,3));
    
    q0 = 0.5 *(( R(2,1) - R(1,2) ) / aux);
    q1 = 0.5 *(( R(1,3) + R(3,1) ) / aux);
    q2 = 0.5* (( R(2,3) + R(3,2) ) / aux);
    q3 =  0.5 * aux ;
    
    q = [ q0 ;q1;q2;q3];                          
                    
end


end

