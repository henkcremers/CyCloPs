%% clean-up 
clear all; close all; clc

%% load the Canlab (2018) RNS 
cd('/Volumes/WD2T/Tools/CCP/AtlasRois/CanLab2018')

CanLab2018 = [pwd '/CANlab_2018_combined_atlas_2mm.nii'];
%[CLInfo, dat] = iimg_read_img(CanLab2018,2);
%CL2108dat = iimg_get_data(CLInfo, CanLab2018);

% also create 4D images
nwa_atlas_3D4Dconv(CanLab2018)

% get the info 
nwa_atlas_info(CanLab2018)



