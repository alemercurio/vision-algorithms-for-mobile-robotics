clear all
close all
clc

rotation_inv = 1;

num_scales = 3; % Scales per octave.
num_octaves = 5; % Number of octaves.
sigma = 1.6;
contrast_threshold = 0.04;
image_file_1 = 'images/img_1.jpg';
image_file_2 = 'images/img_2.jpg';
rescale_factor = 0.2; % Rescaling of the original image for speed.

images = {getImage(image_file_1, rescale_factor),...
    getImage(image_file_2, rescale_factor)};

kpt_locations = cell(1, 2);
descriptors = cell(1, 2);

for img_idx = 1:2
    pyramid = cell(1, num_octaves);
    blurred_images = cell(1, num_octaves);
    DoGs = cell(1, num_octaves);
    % Write code to compute:
    % 1)    image pyramid. Number of images in the pyarmid equals
    %       'num_octaves'.
    pyramid{1} = images{img_idx};
    for idx = 2:num_octaves
       pyramid{idx} = imresize(pyramid{idx - 1}, 0.5);
    end

    num_octaves = numel(pyramid);
    blurred_images = cell(1, num_octaves);

    for o=1:num_octaves
        im_1 = images{1}(1:o:end, 1:o:end);
        im_2 = images{2}(1:o:end, 1:o:end);
    
    %3D Volume, left and right side
        gaussian_stack = zeros([size(pyramid{o}) num_scales+3]);
        dog_stack = zeros(size(images{1},1), size(images{1}, 2), num_octaves);
    
    % 2)    blurred images for each octave. Each octave contains
    %       'num_scales + 3' blurred images.
        for i=1:(num_scales+3)
        current_sigma = 2^(i-2/num_scales)*sigma;
        gaussian_stack(:,:,i) = imgaussfilt(pyramid{o}, current_sigma);
        end
        blurred_images{o} = gaussian_stack;
    end

    for o=1:num_octaves
    % 3)    'num_scales + 2' difference of Gaussians for each octave.
        DoG =  zeros(size(blurred_images{o})-[0 0 1]);
        num_dogs_per_octave = size(DoG, 3);
        for dog_idx = 1:num_dogs_per_octave
           DoG(:, :, dog_idx) = abs(...
               blurred_images{o}(:, :, dog_idx + 1) - ...
               blurred_images{o}(:, :, dog_idx));
        end
    % 4)    Compute the keypoints with non-maximum suppression and
    %       discard candidates with the contrast threshold.  
        DoGs{o} = DoG;
    end

    tmp_kpt_locations = extractKeypoints(DoGs, contrast_threshold);
    
    % 5)    Given the blurred images and keypoints, compute the
    %       descriptors. Discard keypoints/descriptors that are too close
    %       to the boundary of the image. Hence, you will most likely
    %       lose some keypoints that you have computed earlier.

    [descriptors{img_idx}, kpt_locations{img_idx}] =...
            computeDescriptors(blurred_images, tmp_kpt_locations, rotation_inv);
end

% Finally, match the descriptors using the function 'matchFeatures' and
% visualize the matches with the function 'showMatchedFeatures'.
% If you want, you can also implement the matching procedure yourself using
% 'knnsearch'.
indexPairs = matchFeatures(descriptors{1}, descriptors{2},...
    'MatchThreshold', 100, 'MaxRatio', 0.7, 'Unique', true);
% Flip row and column to change to image coordinate system.
% Before         Now
% -----> y       -----> x
% |              |
% |              |
% ⌄              ⌄
% x              y
kpt_matched_1 = fliplr(kpt_locations{1}(indexPairs(:,1), :));
kpt_matched_2 = fliplr(kpt_locations{2}(indexPairs(:,2), :));

figure; ax = axes;
showMatchedFeatures(images{1}, images{2}, kpt_matched_1, kpt_matched_2, ...
    'montage','Parent',ax);
title(ax, 'Candidate point matches');
legend(ax, 'Matched points 1','Matched points 2');