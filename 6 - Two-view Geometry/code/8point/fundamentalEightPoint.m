function F = fundamentalEightPoint(p1,p2)
% fundamentalEightPoint  The 8-point algorithm for the estimation of the fundamental matrix F
%
% The eight-point algorithm for the fundamental matrix with a posteriori
% enforcement of the singularity constraint (det(F)=0).
% Does not include data normalization.
%
% Reference: "Multiple View Geometry" (Hartley & Zisserman 2000), Sect. 10.1 page 262.
%
% Input: point correspondences
%  - p1(3,N): homogeneous coordinates of 2-D points in image 1
%  - p2(3,N): homogeneous coordinates of 2-D points in image 2
%
% Output:
%  - F(3,3) : fundamental matrix

[~,NumPoints] = size(p1);

% Compute the measurement matrix Q of the linear homogeneous system whose
% solution is the vector representing the fundamental matrix.
Q = zeros(NumPoints,9);
for i=1:NumPoints
    Q(i,:) = kron(p1(:,i),p2(:,i)).';
end

% "Solve" the linear homogeneous system of equations Q*f = 0.
% The correspondences x1,x2 are exact <=> rank(Q)=8 -> there exist an exact solution
% If measurements are noisy, then rank(A)=9 => there is no exact solution, seek a least-squares solution.
[~,~,V] = svd(Q,0);
F = reshape(V(:,9),3,3);

% Enforce det(F)=0 by projecting F onto the set of 3x3 singular matrices
[u,s,v]=svd(F);
s(3,3)=0;
F=u*s*v';

end