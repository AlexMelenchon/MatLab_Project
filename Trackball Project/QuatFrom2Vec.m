function [q] = QuatFrom2Vec(vec1,vec2)
%Frome the 2 vec3 that are entered as parameters, this function extracts and 
%returns the quaternion rotation
vec1=vec1/sqrt((vec1(1)^2)+(vec1(2)^2)+(vec1(3)^2));
vec2=vec2/sqrt((vec2(1)^2)+(vec2(2)^2)+(vec2(3)^2));

w=cross(vec1,vec2);
q=[1+dot(vec1,vec2);w];
end

