function [q] = QuatFrom2Vec(vec1,vec2)
% [q] = QuatFrom2Vec(vec1,vec2)
% Computes the quaternion given two vectors
% Inputs:
%    vec1: first vector
%    vec2: secong vector
% Outputs:
%    q: Result quaternion


vec1=vec1/sqrt((vec1(1)^2)+(vec1(2)^2)+(vec1(3)^2));
vec2=vec2/sqrt((vec2(1)^2)+(vec2(2)^2)+(vec2(3)^2));

w=cross(vec1,vec2);
a=w(1);
b=w(2);
c=w(3);
d=1+dot(vec1,vec2);
q=[d;a;b;c];
end

