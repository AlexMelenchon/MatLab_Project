function [A]=SpaceCoordsToVec3(x,y,r)
%This function gets the 2D Mause coordinates and the sphere radius and returns a vector in the 3D
%surface of a Holroyd's arcball

if (x^2 + y^2)< 0.5*(r^2)% takes the sphere as the surface
  aux= sqrt((r^2)-(x^2)-(y^2));
    A=[x,y,aux]';
    
else% otherwise takes the hyperboloid as the surface
    aux=(r^2)/(2*sqrt((x^2)+(y^2)));
    vec=[x,y,aux]';
    m=sqrt((x^2)+(y^2)+(aux^2));
    A=(r*vec)/m;
    
end


end
