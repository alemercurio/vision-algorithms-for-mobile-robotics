function scores = shi_tomasi(img, patch_size)
    sobel_x = [-1, 0, 1; 
               -2, 0, 2;
               -1, 0, 1];
    sobel_y = [-1, -2, -1; 
               0, 0, 0;
               1, 2, 1];
    
    img_x = padarray(conv2(img, sobel_x, 'valid'), [2, 2]); % sobel matrices are 3x3 -> 
    img_y = padarray(conv2(img, sobel_y, 'valid'), [2, 2]); % you need to skip first 2 rows and cols
    
    adder = ones(patch_size);
    
    M_11 = padarray(conv2(img_x.^2, adder, 'valid'), [patch_size-1, patch_size-1]);
    M_12 = padarray(conv2(img_x.*img_y, adder, 'valid'), [patch_size-1, patch_size-1]);
    M_22 = padarray(conv2(img_y.^2, adder, 'valid'), [patch_size-1, patch_size-1]);
    
    % shortcut for 2x2 symmetric matrix eigenvalues (and take the minimal)
    delta = (M_11.^2 + 4*M_12.^2 - 2*M_11.*M_22 + M_22.^2).^0.5;
    scores = 0.5*(M_11 + M_22 - delta);
    
end
