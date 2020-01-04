function [A]=SpaceCoordsToVec3(x,y,r)
% [A]=SpaceCoordsToVec3(x,y,r)
% Computes the vector w/ Holroyd’s arcball given three points in the space
% Inputs:
%    x: point in X
%    y: point in Y
%    z: point in Z
% Outputs:
%    A: Result vector

if (((x^2) + (y^2))< 0.5*r^2)% takes the sphere as the surface
  aux= sqrt((r^2)-(x^2)-(y^2));
    A=[x,y,aux]';
    
else% otherwise takes the hyperboloid as the surface
    
    aux= ((r^2)/(2*sqrt(x^2+y^2)));
    vec=[x,y,aux]';
    m= (x^2 + y^2 + aux^2)^0.5;
    m = norm(m);
    A=((r*vec)/m);
    
end


end
