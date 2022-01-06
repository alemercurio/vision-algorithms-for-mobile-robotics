function disp_img = getDisparity(...
    left_img, right_img, patch_radius, min_disp, max_disp)
% left_img and right_img are both H x W and you should return a H x W
% matrix containing the disparity d for each pixel of left_img. Set
% disp_img to 0 for pixels where the SSD and/or d is not defined, and for d
% estimates rejected in Part 2. patch_radius specifies the SSD patch and
% each valid d should satisfy min_disp <= d <= max_disp.
    
    x_left = size(left_img, 1); 
    y_left = size(left_img, 2);

    patch_size = 2 * patch_radius + 1;
    
    left_img = padarray(left_img, [patch_radius, patch_radius+max_disp]);
    right_img =  padarray(right_img, [patch_radius, patch_radius+max_disp]);

    min_y = (1 + max_disp + patch_radius);

    parfor x=(1+patch_radius):(x_left)
        for y=min_y:y_left
            
            SSD = [];
            left_patch = single(left_img(x-patch_radius:x+patch_radius, y-patch_radius:y+patch_radius));
            right_strip = single(right_img(x-patch_radius:x+patch_radius, y-patch_radius-max_disp:y+patch_radius-min_disp));       
            lpvec = single(left_patch(:));
            rsvecs = single(zeros(patch_size^2, max_disp - min_disp + 1));
            for i = 1:patch_size
                rsvecs(((i-1)*patch_size+1):(i*patch_size), :) = ...
                    right_strip(:, i:(max_disp - min_disp + i));
            end
        
            SSD = pdist2(lpvec', rsvecs', 'squaredeuclidean');

            [min_ssd, neg_disp] = min(SSD);
            
            %reject outliers
            if (nnz(SSD <= 1.5 * min_ssd) < 3 && neg_disp ~= 1 && ...
                    neg_disp ~= length(SSD))                
                    z = [neg_disp-1 neg_disp neg_disp+1];
                    p = polyfit(z, SSD(z), 2);
                    % Minimum of p(1)z^2 + p(2)z + p(3), converted from
                    % neg_disp to disparity as above.
                    disp_img(x, y) = max_disp + p(2)/(2*p(1));
            end
        end
    end
end
