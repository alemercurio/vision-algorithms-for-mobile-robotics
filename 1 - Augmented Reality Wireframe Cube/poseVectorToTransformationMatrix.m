function [transMat] = poseVectorToTransformationMatrix(pose)
% transform the pose input [wx, wy, wz, tx, ty, tz] 
% in a standard transformation matrix T=[R|t]
    rot = pose(1:3);
    trans = (pose(4:6))';
    rotMat = eul2rotm(rot, 'XYZ');
    transMat = [rotMat trans];
end

