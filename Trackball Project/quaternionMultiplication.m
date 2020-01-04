function [q] = quaternionMultiplication(qb, qa)
% [q] = quaternionMultiplication(qb, qa)
% Computes the quaternion multiplication of the given quaternions
% Inputs:
%	qb: quaternion on the left
%   qa: quaternion on the right
% Outputs:
%	q: computed quaternion

%Divide the quaternion in multiple vars-----
q0b= qb(1)
qVb= qb(2:4);
qa = qa(:);

%Create the matrix used in the operations from the vector on the right----
matr=[0,-qVb(3),qVb(2);
 qVb(3),0,-qVb(1);
  -qVb(2),qVb(1),0];

%We compute the 4x4 matrix that will multiply the other quaternion----
aux=q0b*eye(3)+matr;
res(1,1)=q0b;
res(1,2:4)=-qVb';
res(2:4,1)=qVb;
res(2:4,2:4)=aux;

%We perform the quaternion multiplication & we normalize it before sending it
%off
qaVector=[qa(1),qa(2),qa(3),qa(4)]';
q=res*qaVector;
q = q/ sqrt(q' * q);


end

