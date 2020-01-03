function [q] = quaternionMultiplication(qb, qa)
% [q] = quaternionMultiplication(qb, qa)
% Computes the quaternion multiplication of the given quaternions
% Inputs:
%	qb: quaternion on the left
%   qa: quaternion on the right
% Outputs:
%	q: computed quaternion

q0a= qa(1);
q0b= qb(1)
qVa= qa(2:4);
qVb= qb(2:4);

res=zeros(4,4);
matr=[0,-qVb(3),qVb(2);
 qVb(3),0,-qVb(1);
  -qVb(2),qVb(1),0];
aux=q0b*eye(3)+matr;

res(1,1)=q0b;
res(1,2:4)=-qVb';
res(2:4,1)=qVb;
res(2:4,2:4)=aux;

qaVector=[q0a,qVa(1),qVa(2),qVa(3)]'
q=res*qaVector

end

