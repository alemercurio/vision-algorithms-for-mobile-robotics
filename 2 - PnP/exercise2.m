close all;
clear all;

img_index = 1;
undimg_path = sprintf('data/images_undistorted/img_%04d.jpg', img_index);
undimg = imread(undimg_path);

K = load('data/K.txt');

P = 0.01 * load('data/p_W_corners.txt');
num_corners = length(P);

p = load('data/detected_corners.txt');
p = p(img_index,:);
p = reshape(p, 2, 12)';
  
M = estimatePoseDLT(p, P, K);

p_reproj = reprojectPoints(P, M, K);

figure(1);
imshow(undimg); hold on;
plot(p(:,1), p(:,2), 'o'); hold on;
plot(p_reproj(:,1), p_reproj(:,2), '+');
legend('Original points','Reprojected points');

%% Produce a 3d plot containing the corner positions and a visualization of the camera axis

figure(2);
scatter3(P(:,1), P(:,2), P(:,3)); hold on;
axis equal;

camup([0 1 0]);
view([0 0 -1]);

% Position of the camera given in the world frame
R_C_W = M(1:3,1:3);
t_C_W = M(1:3,4);
rotMat = R_C_W';
pos = -R_C_W' * t_C_W;

scaleFactorArrow = .05;

axisX = quiver3(pos(1),pos(2),pos(3), rotMat(1,1),rotMat(2,1),rotMat(3,1), 'r', 'ShowArrowHead', 'on', 'AutoScale', 'on', 'AutoScaleFactor', scaleFactorArrow);
axisY = quiver3(pos(1),pos(2),pos(3), rotMat(1,2),rotMat(2,2),rotMat(3,2), 'g', 'ShowArrowHead', 'on', 'AutoScale', 'on', 'AutoScaleFactor', scaleFactorArrow);
axisZ = quiver3(pos(1),pos(2),pos(3), rotMat(1,3),rotMat(2,3),rotMat(3,3), 'b', 'ShowArrowHead', 'on', 'AutoScale', 'on', 'AutoScaleFactor', scaleFactorArrow);


