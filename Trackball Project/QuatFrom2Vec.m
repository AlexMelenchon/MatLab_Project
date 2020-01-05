function [q] = QuatFrom2Vec(vec1,vec2)
% [q] = QuatFrom2Vec(vec1,vec2)
% Computes the quaternion given two vectors
% Inputs:
%    vec1: first vector
%    vec2: second vector
% Outputs:
%    q: Result quaternion

%We firts normalize both imput vectors
vec1=vec1/sqrt((vec1(1)^2)+(vec1(2)^2)+(vec1(3)^2));
vec2=vec2/sqrt((vec2(1)^2)+(vec2(2)^2)+(vec2(3)^2));

%We then make the cross product to find a new vector w taht is
%perpendicular to both imput vectors
w=cross(vec1,vec2);

%We asign 1 + the dot product of the imput vectors to the real part of the
%quaternion, which gives us the rotation of the quaternion
d=1+dot(vec1,vec2);
q=[1+dot(vec1,vec2);w(1);w(2);w(3)];
end

