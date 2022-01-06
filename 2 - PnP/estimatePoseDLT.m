function M = estimatePoseDLT(p, P, K)

p_normalized = (K \ [p ones(length(p),1)]')';

num_corners = length(p_normalized);
Q = zeros(2*num_corners, 12);

for i=1:num_corners
    u = p_normalized(i,1);
    v = p_normalized(i,2);
    
    Q(2*i-1,1:3) = P(i,:);
    Q(2*i-1,4) = 1;
    Q(2*i-1,9:12) = -u * [P(i,:) 1];
    
    Q(2*i,5:7) = P(i,:);
    Q(2*i,8) = 1;
    Q(2*i,9:12) = -v * [P(i,:) 1];
end

[~,~,V] = svd(Q);
M = V(:,end);

M = reshape(M,4,3);

M = M';

if det(M(:,1:3))<0
    M=-M;
end

[U,~,V] = svd(M(:,1:3));

R = U*(V');

alpha = norm(R, 'fro')/norm(M(:,1:3), 'fro');

% Build M_tilde with the corrected rotation and scale
M = [R alpha * M(:,4)];

end