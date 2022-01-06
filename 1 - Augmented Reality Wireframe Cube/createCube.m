function [cubePoints] = createCube(T, K, x, y, size)
   offset_x = 0.04*x;
   offset_y = 0.04*y;
   s = 0.04*size;
   
   [X, Y, Z] = meshgrid(0:1, 0:1, -1:0);
   p_W_cube = [offset_x + X(:)*s, offset_y + Y(:)*s, Z(:)*s]';
   p_C_cube = T * [p_W_cube; ones(1,8)];
   p_C_cube = p_C_cube(1:3,:);
   
   cubePoints = K * p_C_cube;
   cubePoints = cubePoints  ./ cubePoints (3,:);
end
