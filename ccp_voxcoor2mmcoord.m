function [mmcoor] = voxcoor2mmcoord(voxcoor,mat)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% Nii=nifti(filename);  % Get header info
% M = Nii.mat;  % The matrix in the header
% vox = [20 30 4] % an example voxel coordinate.

mmcoor = [];
if size(voxcoor,1) ~= 3
    voxcoor = voxcoor';
end
try
mmcoor = mat(1:3,:)*[voxcoor; ones(1,size(voxcoor,2))]; % mm coordinate
catch
  warning('check the input')
end

return

