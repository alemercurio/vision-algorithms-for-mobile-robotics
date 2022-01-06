close all;
clear all;
clc;

% load one image
IMG = imread("images_undistorted/img_0001.jpg");
IMGd = imread("images/img_0001.jpg");

% remove color
IMG = rgb2gray(IMG);
IMGd = rgb2gray(IMGd);

% load camera pose wrt world frame
poses = load("poses.txt");
pose = poses(1,:);

% load intrinsic parameters
K = load("data\K.txt");
D = load("data\D.txt");

% dimension of checkerboard square
step = 0.04;

x = 0:step:0.32;

y = 0:step:0.20;

z = 0;

% create checkerboard corners matrix
[X,Y,Z] = meshgrid(x,y,z);
G = [X,Y,Z];

T = poseVectorToTransformationMatrix(pose);

% matrix of corners pixel coordinates on the grid
P = [0 0 0]';
Pd = [0 0 0]';

for r = 1:size(X, 1) 
    for c = 1:size(X, 2)
        % lambda*[u, v, 1]' = K*T*[Xw, Yw, Zw, 1]'
        p = K*T*[X(r,c) Y(r,c) Z(r,c) 1]';
        lambda = p(3);
        p = p/lambda;
        P = [P p];
        
        %distorted 
        r2 = (p(1)-K(1,3))^2+(p(2)-K(2,3))^2;
        coeff = 1 + D(1)*r2 + D(2)*r2^2;
        pd = coeff*(p-K(:,3))+K(:,3);
        Pd = [Pd pd];
    end
end

x = P(1,2:length(P));
y = P(2,2:length(P));
figure(1)
imshow(IMG)
hold on
scatter(x, y, 'red', 'filled')

%distorted
xd = Pd(1,2:length(Pd));
yd = Pd(2,2:length(Pd));
figure(2)
imshow(IMGd)
hold on
scatter(xd, yd, 'red', 'filled')

%undistortion
IMGud = undistort_image(IMG, IMGd, K, D);
figure(3)
imshow(IMGud)
hold on

cube_pts = createCube(T, K, 3, 1, 2);

figure();
imshow(IMG); hold on;

lw = 3;

% base layer of the cube
line([cube_pts(1,1), cube_pts(1,2)],[cube_pts(2,1), cube_pts(2,2)], 'color', 'red', 'linewidth', lw);
line([cube_pts(1,1), cube_pts(1,3)],[cube_pts(2,1), cube_pts(2,3)], 'color', 'red', 'linewidth', lw);
line([cube_pts(1,2), cube_pts(1,4)],[cube_pts(2,2), cube_pts(2,4)], 'color', 'red', 'linewidth', lw);
line([cube_pts(1,3), cube_pts(1,4)],[cube_pts(2,3), cube_pts(2,4)], 'color', 'red', 'linewidth', lw);

% top layer
line([cube_pts(1,1+4), cube_pts(1,2+4)],[cube_pts(2,1+4), cube_pts(2,2+4)], 'color', 'red', 'linewidth', lw);
line([cube_pts(1,1+4), cube_pts(1,3+4)],[cube_pts(2,1+4), cube_pts(2,3+4)], 'color', 'red', 'linewidth', lw);
line([cube_pts(1,2+4), cube_pts(1,4+4)],[cube_pts(2,2+4), cube_pts(2,4+4)], 'color', 'red', 'linewidth', lw);
line([cube_pts(1,3+4), cube_pts(1,4+4)],[cube_pts(2,3+4), cube_pts(2,4+4)], 'color', 'red', 'linewidth', lw);

% vertical lines
line([cube_pts(1,1), cube_pts(1,1+4)],[cube_pts(2,1), cube_pts(2,1+4)], 'color', 'red', 'linewidth', lw);
line([cube_pts(1,2), cube_pts(1,2+4)],[cube_pts(2,2), cube_pts(2,2+4)], 'color', 'red', 'linewidth', lw);
line([cube_pts(1,3), cube_pts(1,3+4)],[cube_pts(2,3), cube_pts(2,3+4)], 'color', 'red', 'linewidth', lw);
line([cube_pts(1,4), cube_pts(1,4+4)],[cube_pts(2,4), cube_pts(2,4+4)], 'color', 'red', 'linewidth', lw);

hold off;
set(gca,'position',[0 0 1 1],'units','normalized')




