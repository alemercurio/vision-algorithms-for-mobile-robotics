function [R_C_W, t_C_W, best_inlier_mask, max_num_inliers_history, num_iteration_history] ...
    = ransacLocalization(matched_query_keypoints, corresponding_landmarks, K)
% query_keypoints should be 2x1000
% all_matches should be 1x1000 and correspond to the output from the
%   matchDescriptors() function from exercise 3.
% best_inlier_mask should be 1xnum_matched (!!!) and contain, only for the
%   matched keypoints (!!!), 0 if the match is an outlier, 1 otherwise.

pixel_tolerance = 10;
k = 6;

% Initialize RANSAC.
best_inlier_mask = zeros(1, size(matched_query_keypoints, 2));
% (row, col) to (u, v)
matched_query_keypoints = flipud(matched_query_keypoints);
max_num_inliers_history = [];
num_iterations = 2000;
num_iteration_history = [];
max_num_inliers = 0;
i = 1;

while num_iterations > i

    [landmark_sample, idx] = datasample(...
        corresponding_landmarks, k, 2, 'Replace', false);
    keypoint_sample = matched_query_keypoints(:, idx);

    M_C_W = estimatePoseDLT(keypoint_sample', landmark_sample', K);
    R_C_W = M_C_W(:,1:3);
    t_C_W = M_C_W(1:3,4);
    
    projectedPoints = projectPoints(R_C_W(:,:,1)*corresponding_landmarks + ...
        repmat(t_C_W(:,:,1), ...
        [1 size(corresponding_landmarks, 2)]), K);
    difference = matched_query_keypoints - projectedPoints;
    errors = sum(difference.^2, 1);
    is_inlier = errors < pixel_tolerance^2;

    num_iteration_history(i) = num_iterations;
    max_num_inliers_history(i) = max_num_inliers;

    min_inlier_count = 6;

    if nnz(is_inlier) > max_num_inliers && ...
            nnz(is_inlier) >= min_inlier_count
        max_num_inliers = nnz(is_inlier);        
        best_inlier_mask = is_inlier;
    end

    i = i+1;
end

if max_num_inliers == 0
    R_C_W = [];
    t_C_W = [];
else
    M_C_W = estimatePoseDLT(...
        matched_query_keypoints(:, best_inlier_mask>0)', ...
        corresponding_landmarks(:, best_inlier_mask>0)', K);
    R_C_W = M_C_W(:, 1:3);
    t_C_W = M_C_W(:, end);
end
